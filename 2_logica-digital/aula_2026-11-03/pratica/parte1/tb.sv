`timescale 1ns/10ps

module tb;

  logic RESULTADO; // Fios para ligar as saídas
  logic [3:0] X_s;      // Variáveis ligadas às entradas

  // Instância do multiplexador no arquivo da biblioteca .v linha 5279
  sistema_x sys_x(
    .X(X_s),
    .Q(RESULTADO)
  );

  always begin :estimulo_X
    #5ns;
    X_s = X_s + 1'b1;
  end

  initial begin
    $display("Iniciou...");
    #3;

    $display("Estimulos...");
    X_s = 0;
    #100ns;

    $display("Acabou o teste.");
    $finish;
  end
endmodule