module inv_gate_tb;
  logic a;
  logic y;
  
  // instantiating the module to map connections
  inv_gate invg( .a(a), .y(y) );
  
  initial
    begin
      a = 1'b0;
      #5

      a = 1'b1;
      #5

      $finish;
    end
  
    initial
    begin
      $display("                Tempo   Entradas    Saídas");
      $display("                           a           y  ");
      $display("                ====   ==========  =======");
      $monitor($time,"     %b              %b", a, y);
    end
  
endmodule

