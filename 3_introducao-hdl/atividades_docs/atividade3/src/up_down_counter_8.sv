`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UNIVERSIDADE FEDERAL DO CEARÁ
// Engineer: GUSTAVO ALVES MENDES
// 
// Create Date: 11/06/2026 05:45:27 PM
// Design Name: 
// Module Name: up_down_counter
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


module up_down_counter_8(
    input   logic clk, rst_n,
    input   logic enable,       // habilita contagem
    input   logic up_down,      // define incremento ou decremento
    output  logic [7:0] Q
    );
    
    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n)         Q <= 8'b0000_0000;
        else if (enable) begin
            if (up_down)    Q <= Q + 1'b1;
            else            Q <= Q - 1'b1;
        end
        else
            Q <= Q;  // Retenção da saída
    end
endmodule
