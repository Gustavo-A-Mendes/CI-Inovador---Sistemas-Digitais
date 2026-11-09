module multiplexador_ula (
    input   logic [2:0] A, B,
    input   logic OP,
    output  logic [3:0] Q
);

    assign Q = (OP) ? (A+B) : (A-B);
endmodule