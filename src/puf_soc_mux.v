//********************************************************************************
// Title       : PUF mux
// Project     : ASIC Implementation of PUF and HDA (2nd ASIC run)
//********************************************************************************
// File        : puf_soc_mux.v
// Author      : Pau Ortega (Email: ortega@imse-cnm.csic.es)
// supervisor  : Macarena Mart�nez (Email: {macarena@imse-cnm.csic.es)
// Company     : IMSE-CNM (http://www.imse-cnm.csic.es)
// Created     : Feb 2023
// Standard    : Verilog 2012
//********************************************************************************
// Copyright (c) 2023 IMSE-CNME ()
// Description: MUX 2048:1 that selects one of the active ROs. There are two instances
// of this module.
//********************************************************************************
(* keep_hierarchy*) module puf_soc_mux #(
	parameter MUX_SZ = 2048
) (
	input 	   [MUX_SZ-1:0] i_data ,
	input      [$clog2(MUX_SZ)-1:0] i_sel_mux,
	output	   o_mux
);
	assign o_mux = i_data[i_sel_mux];


endmodule // puf_soc_mux