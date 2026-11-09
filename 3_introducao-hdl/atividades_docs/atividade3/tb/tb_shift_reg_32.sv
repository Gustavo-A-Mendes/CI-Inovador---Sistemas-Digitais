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


module tb_shift_reg_32;
    logic clk, rst_n;   // Controle geral
    logic load, shift_left, shift_right;    // Controle do shift_reg_32
    
    logic [31:0] D, Q;                      // Entradas/Saídas do shift_reg_32
    logic SR_in, SL_in;
    
    // Instancia do módulo de teste:
    shift_reg_32 sr0 (.*);
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 1'b0; rst_n = 1'b0;  
        load = 1'b0; shift_left = 1'b0; shift_right = 1'b0;
        
        D = 32'd0; SR_in = 1'b0; SL_in = 1'b0;
        
        #100;   // respiro do GSR
        
        $dumpfile("tb_shift_reg_32_result.vcd");
        $dumpvars(0, tb_shift_reg_32);
        
        #5;
        
        // Teste do reg32:
        D = 32'h01234567; rst_n = 1'b1;
        #2;
        
        {load, shift_left, shift_right} = 3'b100;
        
        @( posedge clk );
        @( posedge clk );
        #3;
        
        {load, shift_left, shift_right} = 3'b001;
        SR_in = 1'b1;
        
        @( posedge clk );
        #3;
        SR_in = 1'b0;
        
        repeat(2) @ ( posedge clk );
        #3;
        
        {load, shift_left, shift_right} = 3'b010;
        SL_in = 1'b1;
        
        @( posedge clk );
        #3;
        
        {load, shift_left, shift_right} = 3'b110;
        SR_in = 1'b0;
        
        @( posedge clk );
        rst_n = 1'b0;
        #3;
        
        $finish;
    end
endmodule
