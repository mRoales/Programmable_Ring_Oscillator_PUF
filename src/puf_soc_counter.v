//********************************************************************************
// Title       : PUF Counter
// Project     : ASIC Implementation of PUF and HDA (2nd ASIC run)
//********************************************************************************
// File        : puf_soc_counter.v
// Author      : Pau Ortega (Email: ortega@imse-cnm.csic.es)
// supervisor  : Macarena Martínez (Email: {macarena@imse-cnm.csic.es)
// Company     : IMSE-CNM (http://www.imse-cnm.csic.es)
// Created     : March 2023
// Standard    : Verilog 2012
//********************************************************************************
// Copyright (c) 2023 IMSE-CNME ()
//********************************************************************************
// Description:
//	Counter logic, its an CNT_BIT_SIZE puf_soc_counter with active low reset
// clk        : user clock pin
// rst_n      : active low reset
// i_cnt_en   : enable to start counting
// o_valid    : activ high for valid output
// o_cnt      : CNT_BIT_SIZE puf_soc_counter output value
// o_cnt_full : parametrize puf_soc_counter value
//********************************************************************************


module puf_soc_counter #(
    parameter CNT_BIT_SIZE = 14,
    parameter CONT_MAX = 8063  // Hardcoded Threshold Value for Tiny tapeout Requirements
) (
	input                         clk       ,
	input                         rst_n     ,
	input                         i_cnt_en  ,
	// input      [CNT_BIT_SIZE-1:0] i_cnt_max ,
	input                         i_op_mode ,
	input                         i_full    , //Indicates that the other counter is full
	output reg                    o_valid   ,
	output reg [CNT_BIT_SIZE-1:0] o_cnt     ,
	output reg                    o_cnt_full
);
	wire                    w_cnt_en    ;
	//reg  [CNT_BIT_SIZE-1:0] r_cnt_max   ;
	reg                     r_max_en    ;
	reg  [             1:0] r_op_mode   ;
	reg  [             1:0] r_full      ;
	reg  [CNT_BIT_SIZE-1:0] r_o_cnt     ;
	reg                     r_o_cnt_full;
	// enable signal for counter
	assign w_cnt_en = i_cnt_en && ~(r_o_cnt_full) && ~(r_full[1]) && ~(r_op_mode[1]) ;

	// puf_soc_counter logic
	always@(posedge  clk or negedge rst_n) begin
		if(!rst_n) begin
			r_o_cnt   <= {CNT_BIT_SIZE{1'b0}};
			r_max_en  <= 1'b0 ;
		end
		else begin
			if (w_cnt_en) begin
				r_o_cnt   <= r_o_cnt + 1;
				r_max_en  <= 1'b1 ;
			end else begin
				r_o_cnt   <= r_o_cnt;
				r_max_en  <= r_max_en;
			end
		end
	end
	// generate full signal
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			r_o_cnt_full <= 1'b0;
		end else begin
			if ((r_o_cnt == CONT_MAX-1) && r_max_en) begin
				r_o_cnt_full <= 1'b1;
			end else begin
				r_o_cnt_full <= r_o_cnt_full;
			end
		end
	end

	// Double flop the op_mode pulse
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			r_op_mode <= {2{1'b0}};
		end else begin
			r_op_mode[0] <= i_op_mode 	;
			r_op_mode[1] <= r_op_mode[0];
		end
	end
	
	// Double flop the i_full input
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			r_full <= {2{1'b0}};
		end else begin
			r_full[0] <= i_full 	;
			r_full[1] <= r_full[0];
		end
	end


	// Final output
	always @(posedge clk or negedge rst_n) begin 
			if(~rst_n) begin
				o_cnt      <= {CNT_BIT_SIZE{1'b0}};
				o_cnt_full <= 1'b0;
				o_valid 	 <= 1'b0;
			end else begin
				if (r_full[1] || r_o_cnt_full || r_op_mode[1]) begin
					o_cnt      <= r_o_cnt 		;
					o_valid 	 <= 1'b1;
					o_cnt_full <= r_o_cnt_full;
				end else begin
					o_cnt      <= o_cnt;
					o_cnt_full <= o_cnt_full;
					o_valid 	 <= 1'b0 	; 
				end
			end
		end

	// assign o_cnt_full = (o_cnt == i_cnt_max) ? 1'b1 : 1'b0;
endmodule // puf_soc_counter
