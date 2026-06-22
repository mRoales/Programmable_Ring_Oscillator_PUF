//********************************************************************************
// Title       : PUF Not gate
// Project     : ASIC Implementation of PUF
//********************************************************************************
// File        : puf_soc_ro_not.v
// Author      : sohail (Email: sohail@imse-cnm.csic.es)
// Company     : IMSE-CNM (http://www.imse-cnm.csic.es)
// Created     : Apr 2022
// Standard    : Verilog 2012
//********************************************************************************
// Copyright (c) 2022 IMSE-CNM ()
//********************************************************************************
// Description:
//********************************************************************************
(* keep_hierarchy*) module puf_soc_ro_not (
	input  i_not,
	output o_not
);
	not  #1(o_not,i_not);
endmodule // puf_soc_ro_not
