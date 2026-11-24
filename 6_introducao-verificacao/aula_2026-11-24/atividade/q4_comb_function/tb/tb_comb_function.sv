module tb_comb_function();
    logic a, b , c;
    logic y;
    comb_function dut(a, b , c , y ); // instanciar o dut
    
    initial // podemos utilizar o bloco procedural initial
    begin
        a = 0; b = 0; c = 0; #10;
        if (y !== 1) $display("000 failed."); // verificando se a saída está correta
        c = 1; #10;
        if (y !== 0) $display("001 failed.");
        b = 1; c = 0; #10;
        if (y !== 0) $display("010 failed.");
        c = 1; #10;
        if (y !== 0) $display("011 failed.");
        a = 1; b = 0; c = 0; #10;
        if (y !== 1) $display("100 failed.");
        c = 1; #10;
        if (y !== 0) $display("101 failed.");
        b = 1; c = 0; #10;
        if (y !== 1) $display("110 failed.");
        c = 1; #10;
        if (y !== 1) $display("111 failed.");
    end
endmodule