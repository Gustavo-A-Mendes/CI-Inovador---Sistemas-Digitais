`timescale 1ns/10ps

module tb;

  wire RESULTADO; // Fios para ligar as saídas
  reg SEL_s, A_s, B_s;      // Variáveis ligadas às entradas

  // Instância do multiplexador no arquivo da biblioteca .v linha 5279
  MX2X1HVT mux0(
    .Y(RESULTADO),
    .S0(SEL_s),
    .A(A_s),
    .B(B_s)
  );

  always begin :estimulo_SEL
    #20ns;
    SEL_s = ~SEL_s;
  end

  always begin :estimulo_A
    #5ns;
    A_s = ~A_s;
  end

  always begin :estimulo_B
    #2.5ns;
    B_s = ~B_s;
  end

  initial begin
    $display("Iniciou...");
    #3;

    $display("Estimulos...");
    SEL_s = 0;
    A_s = 0;
    B_s = 0;
    #100ns;

    $display("Acabou o teste.");
    $finish;
  end
endmodule