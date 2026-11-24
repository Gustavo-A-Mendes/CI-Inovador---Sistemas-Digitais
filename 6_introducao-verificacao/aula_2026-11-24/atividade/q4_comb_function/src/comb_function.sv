module comb_function (
    input   logic a,
    input   logic b,
    input   logic c,
    output  logic y
);

    assign y = ~b & ~c | a & b;
    // assign y = ~b & ~c & a & b;  // Erro proposital: para teste de falha

endmodule