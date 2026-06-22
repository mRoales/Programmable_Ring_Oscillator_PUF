//********************************************************************************
// Title       : RO
// Project     : ASIC Implementation of PUF and HDA (2nd ASIC run)
//********************************************************************************
// File        : puf_soc_ro.v
// Author      : Pau Ortega (Email: ortega@imse-cnm.csic.es)
// supervisor  : Macarena Martínez (Email: {macarena@imse-cnm.csic.es)
// Company     : IMSE-CNM (http://www.imse-cnm.csic.es)
// Created     : Feb 2024
// Standard    : Verilog 2012
//********************************************************************************
// Copyright (c) 2023 IMSE-CNME ()
// Description: RO generation. Instantiation of not gates. It has a fixed part and a 
// configurable part that allows to select a range of not gates involved in the RO through
// an input signal. 
//********************************************************************************
(* dont_touch = "true" *)
module puf_soc_ro #(
    parameter NO_PUF_STAGE = 8,
    parameter IS_DINAMIC = 1    // We select if we want to generate a Dinamic or a Fixed RO
) (
    input  wire i_en,
    input  wire [$clog2(NO_PUF_STAGE)-1:0] i_n_inv,
    output wire o_ro
);

    // Cables internos protegidos contra optimizaciones de síntesis
    (* dont_touch = "true" *) wire  w_ring [NO_PUF_STAGE:0];
    (* dont_touch = "true" *) wire  w_ring2 [NO_PUF_STAGE-1:0];
    (* dont_touch = "true" *) wire  w_ring3 [NO_PUF_STAGE-1:0];
    (* dont_touch = "true" *) wire  w_ring4 [NO_PUF_STAGE-1:0];
    (* dont_touch = "true" *) wire  w_ring5 [NO_PUF_STAGE-1:0];
    (* dont_touch = "true" *) wire  w_ring6 [NO_PUF_STAGE-1:0];
    (* dont_touch = "true" *) wire  w_ring7 [NO_PUF_STAGE-1:0];
    (* dont_touch = "true" *) wire  w_ring8 [NO_PUF_STAGE-1:0];
    (* dont_touch = "true" *) wire  w_ring_extra [59:0];
    (* dont_touch = "true" *) wire  w_ring_extra2 [59:0];	
	// nand gate level instantiation 
	nand n1 (w_ring_extra[0], i_en, o_ro);


    genvar i;
    // Inversores fijos (siempre presentes en el Oscilador en Anillo)
    generate
        for (i = 0; i < 60; i = i + 1) begin : gen_fixed_ro
            if (i == 60 - 1) begin
                (* keep = "true", dont_touch = "true" *) 
                puf_soc_ro_not ro1 (
                    .i_not(w_ring_extra[i]),
                    .o_not(w_ring[0])
                );
            end else begin
                (* keep = "true", dont_touch = "true" *) 
                puf_soc_ro_not ro1 (
                    .i_not(w_ring_extra[i]),
                    .o_not(w_ring_extra[i+1])
                );
            end
        end
    endgenerate

    // Multiplexor de realimentación
generate
        if (IS_DINAMIC == 1) begin : gen_mux_dinamic
            // Se genera SOLO si es dinámico Y la etapa NO está deshabilitada
            assign o_ro = w_ring[i_n_inv];
        end
        else if (IS_DINAMIC == 0 && NO_PUF_STAGE == 1) begin : gen_fixed_min
            // Se genera si es estático pero la etapa sigue activa (Lazo fijo al bit 0)
            assign o_ro = w_ring[0];
        end
        else begin : gen_n_puf
            assign o_ro = w_ring[NO_PUF_STAGE-1];  
        end
endgenerate     

    // Parte configurable, pasos de 8 inversores lógicos
    generate
        for (i = 0; i < NO_PUF_STAGE-1; i = i + 1) begin : gen_configurable_ro		
            (* keep = "true", dont_touch = "true" *) 
            puf_soc_ro_not ro2 (
                .i_not(w_ring[i]),
                .o_not(w_ring2[i])
            );
            (* keep = "true", dont_touch = "true" *) 
            puf_soc_ro_not ro3 (
                .i_not(w_ring2[i]),
                .o_not(w_ring3[i])
            );
            (* keep = "true" , dont_touch = "true" *) 
            puf_soc_ro_not ro4 (
                .i_not(w_ring3[i]),
                .o_not(w_ring4[i])
            );
            (* keep = "true", dont_touch = "true" *) 
            puf_soc_ro_not ro5 (
                .i_not(w_ring4[i]),
                .o_not(w_ring5[i])
            );
            (* keep = "true", dont_touch = "true" *) 
            puf_soc_ro_not ro6 (
                .i_not(w_ring5[i]),
                .o_not(w_ring6[i])
            );
            (* keep = "true", dont_touch = "true" *) 
            puf_soc_ro_not ro7 (
                .i_not(w_ring6[i]),
                .o_not(w_ring7[i])
            );
            (* keep = "true", dont_touch = "true" *) 
            puf_soc_ro_not ro8 (
                .i_not(w_ring7[i]),
                .o_not(w_ring8[i])
            );
            (* keep = "true", dont_touch = "true" *) 
            puf_soc_ro_not ro9 (
                .i_not(w_ring8[i]),
                .o_not(w_ring[i+1])
            );				
        end
    endgenerate

endmodule
