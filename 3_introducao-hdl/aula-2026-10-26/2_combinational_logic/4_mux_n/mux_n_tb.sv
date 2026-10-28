`timescale 1ns/1ps

module mux_n_tb;
  parameter N = 16;
  
  reg [N-1:0] d1, d2, d3, d4, y;
  reg [1:0] sel;
  
  mux_n #(.N(N)) mn0(
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .d4(d4),
    .sel(sel),
    .y(y)
  );
  
  initial begin
  
    // Criando dumpfile:
    $dumpfile("teste.vcd");
    $dumpvars;
    
    $monitor("time = %t \t d1 = %b \t d2 = %b \t d3 = %b \t d4 = %b \t sel = %b \t y = %b", $time, d1, d2, d3, d4, sel, y);
  
    // Teste de entradas:
    d1 = 10; d2 = 20; d3 = 30; d4 = 40; 
    
    sel = 2'b00;
    #2;
    
    sel = 2'b01;
    #2;
    
    sel = 2'b10;
    #2;
    
    sel = 2'b11;
    #2;
    
    $finish;
  end
  
  
endmodule