module comb_function (
    input   logic a, 
    input   logic b, 
    input   logic c, 
    output  logic y
);
    // Lógica do circuito
    assign y = (~b & ~c) | (a & b);
    // assign y = (~b & ~c) & (a & b);  // Erro proposital: para teste de falha
    
    // Verificação Formal embutida (sem testbench) 
    `ifdef FORMAL
        always_comb begin
            assert (y == ((~b & ~c) | (a & b)));
        end
    `endif
endmodule