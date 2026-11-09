`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UNIVERSIDADE FEDERAL DO CEARÁ
// Engineer: GUSTAVO ALVES MENDES
// 
// Create Date: 08.11.2026 02:48:10
// Design Name: 
// Module Name: tb_atividade3
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


module tb_lfsr_generator_8;

    logic clk, rst_n;       // Controle geral
    logic [7:0] Q;          // Saída do lfsr_generator
    
    // Instancia dos módulos de teste:
    lfsr_generator_8 lfsr0 (.*);
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 1'b0; rst_n = 1'b0;
        
        #100;   // respiro do GSR

        $dumpfile("tb_lfsr_generator_result.vcd");
        $dumpvars(0, tb_lfsr_generator_8);
        
        #5;

        rst_n = 1'b1;
        
        repeat(20) @( posedge clk );
        #3;
         
        $finish;
    end
endmodule
