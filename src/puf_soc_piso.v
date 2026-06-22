
//********************************************************************************
// Title       : PUF Parallel input serial output
// Project     : ASIC Implementation of PUF and HDA (2nd ASIC run)
//********************************************************************************
// File        : puf_soc_piso.v
// Author      : Pau Ortega (Email: ortega@imse-cnm.csic.es)
// supervisor  : Macarena Martínez (Email: {macarena@imse-cnm.csic.es)
// Company     : IMSE-CNM (http://www.imse-cnm.csic.es)
// Created     : March 2024
// Standard    : Verilog 2012
//********************************************************************************
// Copyright (c) 2023 IMSE-CNME ()
//********************************************************************************
// Description:
// This module serially sends the data stored in assembler debug module.
//********************************************************************************

module puf_soc_piso #(
	parameter FRAME_SIZE = 16
) (
	input                  clk       , // clock
	input                  rst_n     , // active low reset
	input                  i_data_valid, // i_tx_mode : 1 for debugging frame, 0: for normal frame
	input                  i_tx_ready, // From Host, ready to recieve data
	input  [FRAME_SIZE-1:0] i_tx_data , // register data
	output                 o_debug_data , // serial output
	output                 o_debug_valid, // 1: when output is valid
	output                 o_debug_done   // 1: when output is valid
);

	wire [$clog2(FRAME_SIZE+1)-1:0] w_max_cnt; // maximum count value
	wire                         w_tx_en  ;
	wire                         w_ld_en  ;
	wire                        w_piso_en;
	// register declaration
	reg [        FRAME_SIZE-1:0] reg_data     ;
	reg [$clog2(FRAME_SIZE+1)-1:0] reg_shift_cnt; // shift counter
	reg                         reg_o_shift  ;
	reg                         reg_o_ready  ;
	reg                         reg_o_valid  ;
	reg                         reg_o_done   ;

	// valid ready handshake
	assign w_piso_en = i_data_valid & ~reg_o_done;
    //assign w_piso_en = i_data_valid;
	assign w_tx_en = w_piso_en & i_tx_ready & ~ reg_o_ready;
	assign w_ld_en = w_piso_en & reg_o_ready;
	
	// load and shift logic here
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			reg_data    <= {FRAME_SIZE{1'b0}};
			reg_o_shift <= 1'b0;
		end
		else	begin
			if (w_ld_en) begin // laod data
				reg_data <= i_tx_data;
				reg_o_shift <= reg_o_shift;
			end
			else	begin
				if (w_tx_en ) begin // 1: for  shift
					if (reg_shift_cnt==w_max_cnt) begin // to check shift count;
						reg_data    <= reg_data ;
						reg_o_shift <= reg_o_shift;
					end else begin
						reg_o_shift <= reg_data[0];
						reg_data    <= {1'b0,reg_data[FRAME_SIZE-1:1]};// shift right
					end
				end else	begin // shifting is not enable
					reg_o_shift <= 1'b0;
					reg_data    <= reg_data ;
				end
			end
		end
	end

    always@(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
            reg_o_valid <= 1'b0;
		end else begin
            if (w_ld_en) begin // laod data
                reg_o_valid <= 1'b0;
            end else begin
                if (w_tx_en ) begin   
                    if (reg_shift_cnt==w_max_cnt) begin
                        reg_o_valid <= 1'b0;
                    end else begin
                        reg_o_valid <= 1'b1;
                    end
                end else begin
                    reg_o_valid <= 1'b0;
                end
            end
        end
     end

	// shifting counter logic here
	always@(posedge clk or negedge rst_n ) begin
		if (!rst_n) begin
			reg_shift_cnt <= {$clog2(FRAME_SIZE){1'b0}};
		end
		else begin
			if (w_tx_en) begin
				if (reg_shift_cnt == w_max_cnt) begin
					reg_shift_cnt <= {$clog2(FRAME_SIZE){1'b0}};
				end else begin
					reg_shift_cnt <= reg_shift_cnt+1;
				end
			end
			else begin
				reg_shift_cnt <= reg_shift_cnt;
			end
		end
	end

	// ready logic here
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			reg_o_ready <= 1'b1;
		end else begin
			if (w_piso_en) begin  // laod  is assserted
				reg_o_ready <= 1'b0;
			end else begin
				if (reg_shift_cnt == w_max_cnt) begin
					reg_o_ready <= 1'b1;
				end else begin
					reg_o_ready <= reg_o_ready;
				end
			end
		end
	end  // always @(posedge clk or negedge rst_n)

// done logic here
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			reg_o_done <= 1'b0;
		end else begin
			if (reg_shift_cnt == w_max_cnt-1) begin //TBD
				reg_o_done <= 1'b1;
			end else begin
				reg_o_done <= reg_o_done;
			end
		end
	end

	assign w_max_cnt = FRAME_SIZE;
	// output assignment
	assign o_debug_valid = reg_o_valid ;
	assign o_debug_data  = reg_o_shift ;
	assign o_debug_done = reg_o_done  ;
endmodule 