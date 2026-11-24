module and_gate (
    input   logic a, 
    input   logic b, 
    output  logic y
);
    // Lógica da porta AND
    assign y = a & b;
    // assign y = a | b;   // Erro proposital: para teste de falha
    
    // Bloco de Verificação Formal 
    `ifdef FORMAL
        always_comb begin
            // Propriedade 1: A saída 'y' deve ser sempre igual a (a & b)
            assert (y == (a & b));
            
            // Propriedade 2: Se qualquer entrada for 0, a saída nunca pode ser 1
            if (a == 1'b0 || b == 1'b0) begin
                assert (y == 1'b0);
            end
            // Propriedade 3: Se ambas as entradas forem 1, a saída deve ser 1
            if (a == 1'b1 && b == 1'b1) begin
                assert (y == 1'b1);
            end
        end
    `endif
endmodule