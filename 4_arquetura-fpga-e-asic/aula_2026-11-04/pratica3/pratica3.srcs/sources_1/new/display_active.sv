`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2026 04:42:43 PM
// Design Name: 
// Module Name: display_active
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


module display_active #(
    parameter W = 17
) (
    input   logic clk, reset,
    output  logic digit_sel
    );
    
    // Divisor de Clock (Reduz os 100 MHz da placa para ~763 Hz)
    logic [W-1:0] clk_div;
    always @(posedge clk or posedge reset) begin
        if (reset)  clk_div <= 0;
        else        clk_div <= clk_div + 1'b1;
    end
        
    // Seletor de Dígito (Alterna entre 0 e 1 na velocidade do bit mais significativo do clk_div)
    assign digit_sel = clk_div[16];
endmodule
