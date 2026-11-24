module tb_and_gate;
    
    // Sinais internos para conectar ao DUT
    logic a;
    logic b;
    logic y;
    
    // Instanciação do Design Under Test (DUT)
    and_gate dut (
        .a(a),
        .b(b),
        .y(y)
    );
    
    // Bloco de estímulos
    initial begin
        a = 0; b = 0;
        $strobe("Tempo = %0t | a = %b, b = %b => y = %b", $time, a, b, y);
        #10;
        if (y !== 0) $display("00 failed.");
        
        a = 0; b = 1;
        $strobe("Tempo = %0t | a = %b, b = %b => y = %b", $time, a, b, y);
        #10;
        if (y !== 0) $display("01 failed.");
        
        a = 1; b = 0;
        $strobe("Tempo = %0t | a = %b, b = %b => y = %b", $time, a, b, y);
        #10;
        if (y !== 0) $display("10 failed.");
        
        a = 1; b = 1;
        $strobe("Tempo = %0t | a = %b, b = %b => y = %b", $time, a, b, y);
        #10;
        if (y !== 1) $display("11 failed.");
        
        $finish;
    end
endmodule