module and_gate (
    input   logic a, 
    input   logic b, 
    output  logic y
);
    // Lógica da porta AND
    assign y = a & b;
    // assign y = a | b;    // Erro proposital: para teste de falha
endmodule