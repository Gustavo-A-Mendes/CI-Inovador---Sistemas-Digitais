`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UNIVERSIDADE FEDERAL DO CEARÁ
// Engineer: GUSTAVO ALVES MENDES
// 
// Create Date: 11/06/2026 05:45:27 PM
// Design Name: 
// Module Name: shift_reg32
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


module shift_reg_32 (
    input   logic clk, rst_n,
    input   logic [31:0] D,                         // Entrada paralela
    input   logic SR_in, SL_in,                     // Entradas seriais
    input   logic load, shift_left, shift_right,    // Sinais de controle
    output  logic [31:0] Q                          // Saida paralela
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        
        if (!rst_n)         Q <= 32'h0000_0000;
        else begin
            case ({load, shift_left, shift_right})
                3'b100:     Q <= D;                 // Carregar (paralelo)
                3'b010:     Q <= {Q[30:0], SL_in};  // Shift para esquerda
                3'b001:     Q <= {SR_in, Q[31:1]};  // Shift para direita
                default:    Q <= Q; // Retenção da saída
            endcase
        end 
    end
endmodule
