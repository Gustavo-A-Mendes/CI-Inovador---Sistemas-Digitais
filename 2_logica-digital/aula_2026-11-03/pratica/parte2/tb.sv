`timescale 1ns/10ps

module tb;

  logic RESULTADO; // Fios para ligar as saídas
  logic [3:0] X_s;      // Variáveis ligadas às entradas
  logic [3:0] REF;
  // Instância do multiplexador no arquivo da biblioteca .v linha 5279
  sistema_y sys_x(
    .X(X_s),
    .REF(REF),
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
    X_s = 0; REF = 4'b1101;
    #100ns;

    $display("Acabou o teste.");
    $finish;
  end
endmodule