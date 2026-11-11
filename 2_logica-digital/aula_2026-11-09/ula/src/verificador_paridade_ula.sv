module verificador_paridade_ula (
    input   logic ENP,
    input   logic [7:0] A,
    input   logic P,
    input   logic ENV,
    output  logic [8:0] Q,
    output  logic E
    );
    
    logic [8:0] Q_codified;

    // instancia do codificador de paridade:
    paridade_ula pula0(.A(A), .EN(ENP), .Q(Q_codified));

    always_comb begin
        E = 1'b0;

        if (!ENP)    Q = 9'd0;
        else begin
            Q = Q_codified;
            if (ENV)    E = (P != Q_codified[8]);
            else        E = 1'b0;
        end
    end
endmodule