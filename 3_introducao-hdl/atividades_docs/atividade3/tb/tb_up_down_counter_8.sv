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


module tb_up_down_counter_8;

    logic clk, rst_n;               // Controle geral
    logic enable, up_down;          // Controle do up_down_counter
    logic [7:0] Q;                  // Saída do up_down_counter
    
    // Instancia dos módulos de teste:
    up_down_counter_8 udc0 (.*);
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 1'b0; rst_n = 1'b0;
        enable = 1'b0; up_down = 1'b0;
        
        #100;   // respiro do GSR
        
        $dumpfile("tb_up_down_counter_result.vcd");
        $dumpvars(0, tb_up_down_counter_8);
        
        #5;
        
        rst_n = 1'b1;
        
        @( posedge clk );
        #3;
        enable = 1'b1; up_down = 1'b1;
        
        repeat(7) @( posedge clk );
        #3;
        up_down = 1'b0;
        
        repeat(10) @( posedge clk );
        #3;
         
        $finish;
    end
endmodule
