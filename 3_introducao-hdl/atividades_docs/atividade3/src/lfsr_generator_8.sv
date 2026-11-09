`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UNIVERSIDADE FEDERAL DO CEARÁ 
// Engineer: GUSTAVO ALVES MENDES
// 
// Create Date: 08.11.2026 02:41:10
// Design Name: 
// Module Name: lfsr_generator_8
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


module lfsr_generator_8(
    input   logic clk, rst_n,
    output  logic [7:0] Q 
    );
    
    logic feedback;
    
    // Lógica combinacional da equação de realimentação (D7 = Q4 ⊕ Q3 ⊕ Q2 ⊕ Q0)
    assign feedback = Q[4] ^ Q[3] ^ Q[2] ^ Q[0];
    
    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n)     Q <= 8'b0000_0001;
        else begin
            Q <= {feedback, Q[7:1]};
        end
    end
endmodule
