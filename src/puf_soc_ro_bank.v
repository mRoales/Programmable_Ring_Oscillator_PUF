//********************************************************************************
// Title       : PUF RO bank
// Project     : ASIC Implementation of PUF and HDA (2nd ASIC run)
//********************************************************************************
// File        : puf_soc_ro_bank.v
// Author      : Pau Ortega (Email: ortega@imse-cnm.csic.es)
// supervisor  : Macarena Mart�nez (Email: {macarena@imse-cnm.csic.es)
// Company     : IMSE-CNM (http://www.imse-cnm.csic.es)
// Created     : Apr 2023
// Standard    : Verilog 2012
//********************************************************************************
// Copyright (c) 2022 IMSE-CNME ()
// Description: Instantiation of all RO involved in the design, parametrizable.
//********************************************************************************
module puf_soc_ro_bank #(
	parameter PUF_LENGTH   = 4, // Num total ROs
	parameter PUF_LENGTH_CONFIG   = 2,
	parameter NO_PUF_STAGE = 8
) (
	input  [PUF_LENGTH-1:0] i_puf_en, // i_puf_en
	input [$clog2(NO_PUF_STAGE)-1:0] i_n_inv,
	output [PUF_LENGTH-1:0] o_puf_ro
);

	genvar ii;
// Instantiation of puf ro
	generate
		for ( ii = 0; ii < PUF_LENGTH_CONFIG; ii= ii + 1 ) begin
			puf_soc_ro #(
			        .NO_PUF_STAGE(NO_PUF_STAGE),
			        .IS_DINAMIC(1)
			)inst_puf_soc_ro(
					.i_en (i_puf_en[ii]),
					.i_n_inv(i_n_inv),
					.o_ro (o_puf_ro[ii])
				);
		end
		
		
        puf_soc_ro #(
                .NO_PUF_STAGE(NO_PUF_STAGE),
                .IS_DINAMIC(0)
        )inst_puf_soc_ro_F0(
                .i_en (i_puf_en[PUF_LENGTH_CONFIG]),
                .i_n_inv(i_n_inv),
                .o_ro (o_puf_ro[PUF_LENGTH_CONFIG])
        );
		
		
        puf_soc_ro #(
                .NO_PUF_STAGE(1),
                .IS_DINAMIC(0)
        )inst_puf_soc_ro_F1(
                .i_en (i_puf_en[PUF_LENGTH_CONFIG+1]),
                .i_n_inv(i_n_inv),
                .o_ro (o_puf_ro[PUF_LENGTH_CONFIG+1])
		);
		
	endgenerate

endmodule