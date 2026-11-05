`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UNIVERSIDADE FEDERAL DO CEARÁ
// Engineer: GUSTAVO ALVES MENDES
// 
// Create Date: 11/05/2026 10:13:16 AM
// Design Name: 
// Module Name: tb_ula_neander
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


module tb_ula_neander;
    
    parameter MAX_SIZE = 100;
    
    logic [7:0] AC, RDM, resultado;
    logic [2:0] sel_ula;
    logic N, Z;
    
    logic [18:0] test_values [0:MAX_SIZE-1];
    
    // Instância da ULA NEANDER:
    ula_neander ula0(.*);
    
    
    // Gera arquivo dump, com os sinais do testbench e o design top_level:
    initial begin
        $dumpfile("tb_ULA_neander.vcd");
        $dumpvars(0, tb_ula_neander, ula_neander);
    end
    
    
    // Leitura de estímulos das entradas:
    initial begin
    
        // inicialização da memória:
        for (int i = 0; i < MAX_SIZE; i++) 
            test_values[i] = 19'bx;
            
        // Leitura dos valores de estímulos das entradas:
        $readmemb("input_values.mem", test_values);
        
        for (int i = 0; (i < MAX_SIZE) && (test_values[i] !== 19'bx); i++) begin
            AC = test_values[i][18:11]; RDM = test_values[i][10:3]; sel_ula = test_values[i][2:0];
            
            #5;
            
            $display("%tns \tAC = %b (%d) \tRDM = %b (%d) \tsel_ula = %b \tresultado = %b (%d) \t Z = %b \tN = %b", $realtime, AC, AC, RDM, RDM, sel_ula, resultado, resultado, Z, N);
        end
        
        $finish; 
    end
    
endmodule
