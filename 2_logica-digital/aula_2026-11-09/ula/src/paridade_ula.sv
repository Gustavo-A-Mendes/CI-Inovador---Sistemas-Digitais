module tb_paridade_ula (
    input   logic [7:0] A,
    input   logic EN,
    output  logic [8:0] Q
); 

    logic bit_par;
    assign bit_par = ^A;

    assign Q = (EN) ? {bit_par, A};
endmodule