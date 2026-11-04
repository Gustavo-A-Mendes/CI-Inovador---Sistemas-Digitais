`timescale 1ns/1ps
module tb_ram;

  parameter AW = 4,
            DW = 8;

  reg clk=0, we=0;
  reg [AW-1:0] addr=0;
  reg [DW-1:0] din=0;
  wire [DW-1:0] dout;
  
  always #5 clk=~clk;
  
  ram_async_read #(.AW(AW), .DW(DW))dut(clk,we,addr,din,dout);
  
  initial begin
    $dumpfile("ram_async_read.vcd");
    $dumpvars(0, tb_ram);

    @(negedge clk); 
    we=1; addr=3; din=8'hA5;
    
    @(posedge clk); 
    #1;
    if(dout !== 8'hA5) $display("ERRO");
    
    @(negedge clk); 
    we=0;
    if(dout === 8'hA5) $display("PASSOU");

    $finish;
  end
endmodule