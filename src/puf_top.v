`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2026 08:56:16
// Design Name: 
// Module Name: puf_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module puf_top #(
	parameter PUF_LENGTH_CONFIG   = 2,// nº of programmable RO used in the bank
	parameter PUF_LENGTH   = 4, // Num total ROs
	parameter MUX_LENGTH = 4,    // nº of total RO used in the bank
	parameter MUX_SZ = 4,       // nº of RO inputs of the Muxs (same as MUX & PUF_LENGTH)
	parameter NO_PUF_STAGE = 8, // nº of programmable stages
	parameter CNT_BIT_SIZE = 16, // Size of the counter
	parameter CONT_MAX = 8063,  // Hardcoded Threshold Value for Tiny tapeout Requirements 8063
	parameter NO_COUNTER = 2    // Number of counters to be instantiated
) (
	input 		clk  ,
	input       rst_n   ,
    input      [$clog2(MUX_LENGTH)-1:0] i_sel_mux_0,    // Challenge selector for Mux 0 and Decoder
	input      [$clog2(MUX_LENGTH)-1:0] i_sel_mux_1,    // Challenge selector for Mux 1 and Decoder
	input [$clog2(NO_PUF_STAGE)-1:0]    i_n_inv,        // RO stage selector (common to all of the Programmable RO)
	
	input                               i_enable,      // Enables the Decoder
	
	input                               i_tx_ready, // 1: to accept serial data

	input                               i_op_mode ,        // '1' capture the instant value of the counter
	
	output [MUX_LENGTH-1:0]     o_puf_ro,                //  For debug purposes
	output  [NO_COUNTER-1:0] o_valid   ,        // Valid counter serial value
	output   [NO_COUNTER-1:0] o_cnt_data,                // Serialized Values Output
	output     [NO_COUNTER-1:0] o_debug_done       // Communicates the End Of Transmission
    );
    
    wire [PUF_LENGTH-1:0] w_puf_en;
    wire [NO_COUNTER-1:0] wo_count;
    
puf_soc_ro_bank #(
	.PUF_LENGTH(PUF_LENGTH),
	.PUF_LENGTH_CONFIG(PUF_LENGTH_CONFIG),
	.NO_PUF_STAGE(NO_PUF_STAGE)
) inst_ro_bank (
	.i_puf_en(w_puf_en), // i_puf_en
	.i_n_inv(i_n_inv),                         // <-- NEED TO BE SERIALIZED
	.o_puf_ro(o_puf_ro[PUF_LENGTH-1 : 0])      // We assign only the Programmables ROs to this bank
);

puf_soc_ro_decoder #(.MUX_LENGTH(MUX_LENGTH))
    inst_ro_decoder (
	.clk(clk)  ,
	.rst_n(rst_n)   ,
	.i_dcod_en (i_enable)  ,
	.i_sel_mux_0(i_sel_mux_0),
	.i_sel_mux_1(i_sel_mux_1),
	.o_puf_en(w_puf_en)            // Activates the ROs
);

puf_soc_mux #(
    .MUX_SZ(MUX_SZ)
) inst_mux0(
	.i_data(o_puf_ro) ,
	.i_sel_mux(i_sel_mux_0),
	.o_mux(wo_count[0])
);

puf_soc_mux #(
    .MUX_SZ(MUX_SZ)
) inst_mux1(
	.i_data(o_puf_ro) ,
	.i_sel_mux(i_sel_mux_1),
	.o_mux(wo_count[1])
);

wire full_1_to0, full_0_to1;
wire [NO_COUNTER-1:0] count_valid;
wire [CNT_BIT_SIZE-1: 0]  o_cnt_array [NO_COUNTER-1:0];

puf_soc_counter #(
    .CNT_BIT_SIZE(CNT_BIT_SIZE),
    .CONT_MAX(CONT_MAX)  // Hardcoded Threshold Value for Tiny tapeout Requirements
) inst_counter0 (
	.clk(wo_count[0]),
	.rst_n(rst_n),
	.i_cnt_en(i_enable)  ,
	.i_op_mode(i_op_mode) ,
	.i_full(full_1_to0)    , //Indicates that the other counter is full
	.o_valid(count_valid[0])   ,
	.o_cnt(o_cnt_array[0])     ,
	.o_cnt_full(full_0_to1)
);

puf_soc_counter #(
    .CNT_BIT_SIZE(CNT_BIT_SIZE),
    .CONT_MAX(CONT_MAX)  // Hardcoded Threshold Value for Tiny tapeout Requirements
) inst_counter1 (
	.clk(wo_count[1]),
	.rst_n(rst_n),
	.i_cnt_en(i_enable)  ,
	.i_op_mode(i_op_mode) ,
	.i_full(full_0_to1)    , //Indicates that the other counter is full
	.o_valid(count_valid[1])   ,
	.o_cnt(o_cnt_array[1])     ,
	.o_cnt_full(full_1_to0)
);

wire w_data_valid = count_valid[0] & count_valid[1];  // We start transmitting when both counters stopped
puf_soc_piso #(
	.FRAME_SIZE(CNT_BIT_SIZE)
) inst_piso0 (
	.clk(clk)       , // clock
	.rst_n(rst_n)     , // active low reset
	.i_data_valid(w_data_valid), // Data valid, ready to serially send
	.i_tx_ready(i_tx_ready), // From Host, ready to recieve data
	.i_tx_data(o_cnt_array[0]) , // register data
	.o_debug_data(o_cnt_data[0]) , // serial output
	.o_debug_valid(o_valid[0]), // 1: when output is valid
	.o_debug_done(o_debug_done[0])   // 1: when output is valid
);

puf_soc_piso #(
	.FRAME_SIZE(CNT_BIT_SIZE)
) inst_piso1 (
	.clk(clk)       , // clock
	.rst_n(rst_n)     , // active low reset
	.i_data_valid(w_data_valid), // Data valid, ready to serially send
	.i_tx_ready(i_tx_ready), // From Host, ready to recieve data
	.i_tx_data(o_cnt_array[1]) , // register data
	.o_debug_data(o_cnt_data[1]) , // serial output
	.o_debug_valid(o_valid[1]), // 1: when output is valid
	.o_debug_done(o_debug_done[1])   // 1: when output is valid
);

endmodule
