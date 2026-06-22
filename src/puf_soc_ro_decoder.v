//********************************************************************************
// Title       : PUF decoder
// Project     : ASIC Implementation of PUF and HDA (2nd ASIC run)
//********************************************************************************
// File        : puf_soc_decoder.v
// Author      : Macarena Mart�nez (Email: {macarena@imse-cnm.csic.es)
// Company     : IMSE-CNM (http://www.imse-cnm.csic.es)
// Created     : Feb 2023
// Standard    : Verilog 2012
//********************************************************************************
// Copyright (c) 2023 IMSE-CNME ()
//********************************************************************************
module puf_soc_ro_decoder #(parameter MUX_LENGTH = 4) (
	input 		clk  ,
	input       rst_n   ,
	input       i_dcod_en  ,
	input      [$clog2(MUX_LENGTH)-1:0] i_sel_mux_0,
	input      [$clog2(MUX_LENGTH)-1:0] i_sel_mux_1,
	output  [        MUX_LENGTH-1:0] o_puf_en    
);

reg [MUX_LENGTH-1:0] o_puf_en_0, o_puf_en_1;

assign o_puf_en= o_puf_en_0 ^ o_puf_en_1;
	
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			o_puf_en_0 <= {MUX_LENGTH{1'b0}};
			o_puf_en_1 <= {MUX_LENGTH{1'b0}};
		end else begin
		  if (i_dcod_en) begin
			o_puf_en_0 <= {MUX_LENGTH{1'b0}};
			o_puf_en_1 <= {MUX_LENGTH{1'b0}};
			o_puf_en_0[i_sel_mux_0] <=1'b1; 
			o_puf_en_1[i_sel_mux_1] <=1'b1; 
		  end else begin
			o_puf_en_0 <= {MUX_LENGTH{1'b0}};
			o_puf_en_1 <= {MUX_LENGTH{1'b0}};
//            o_puf_en_0 <= o_puf_en_0;
//            o_puf_en_1 <= o_puf_en_1;
		  end
		end
	end

endmodule // 