`timescale 1ns/1ps

module tb_paridade_ula;

    logic [7:0] A;
    logic EN;
    logic [8:0] Q;

    // Instancia do módulo
    paridade_ula pula0(.*);

    initial begin
        A = 8'd0; EN = 1'b0;

        #10;

        $dumpfile("paridade_result.vcd");
        $dumpvars(0, tb_paridade_ula);

        // Estimulos:
        EN = 1'b1;

        A = 8'd0000_0011;   // Q = 0_0000_0011
        #10;

        A = 8'd0010_0011;   // Q = 0_0000_0011
        #10;

        A = 8'd1101_0011;   // Q = 0_0000_0011
        #10;

        A = 8'd0100_1111;   // Q = 0_0000_0011
        #10;

        $finish;
    end

endmodule