module tb;

    // Sinais para conectar ao DUT (Device Under Test)
    logic [3:0] req;
    logic [3:0] grant;
    logic       available;
    logic [1:0] grant_num;

    // Instanciação do módulo 'arbitro'
    arbitro dut (.*);

    // Estímulos de teste
    initial begin
        $sdf_annotate("atrasos_arbitro.sdf", tb.dut,,"sdf_log.txt", "MINIMUM");

        $monitor("Tempo=%0t | req=%b | grant=%b | available=%b | grant_num=%d (%b)",
                 $time, req, grant, available, grant_num, grant_num);

        // Caso 1: Nenhum dispositivo solicita acesso
        req = 4'b0000; #10;

        // Caso 2: Apenas req[0] ativo
        req = 4'b0001; #10;

        // Caso 3: Apenas req[1] ativo
        req = 4'b0010; #10;

        // Caso 4: Apenas req[2] ativo (Exemplo do enunciado: grant='b0100 -> grant_num='d2)
        req = 4'b0100; #10;
        
        // Caso 5: Apenas req[3] ativo
        req = 4'b1000; #10;

        // Caso 6: Múltiplos pedidos (req[1] e req[3] ativos) -> deve dar grant para req[1]
        req = 4'b1010; #10;

        // Caso 7: Todos ativos -> prioridade máxima para req[0]
        req = 4'b0111; #10;

        $finish;
    end

endmodule