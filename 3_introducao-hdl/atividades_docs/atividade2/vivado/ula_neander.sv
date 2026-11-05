`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UNIVERSIDADE FEDERAL DO CEARÁ
// Engineer: GUSTAVO ALVES MENDES
// 
// Create Date: 11/05/2026 10:03:06 AM
// Design Name: 
// Module Name: ula_neander
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


module ula_neander(
        input   logic [7:0] AC, RDM,
        input   logic [2:0] sel_ula,
        output  logic [7:0] resultado,
        output  logic N, Z 
    );
    
    always_comb begin 
        case (sel_ula) 
            3'b000: resultado = AC;
            3'b001: resultado = AC + RDM;
            3'b010: resultado = AC | RDM;
            3'b011: resultado = AC & RDM;
            3'b100: resultado = ~AC;
            default: resultado <= 8'bx;
        endcase
    end
    
    assign N = resultado[7];
    assign Z = (resultado == 8'b0);
        
endmodule
