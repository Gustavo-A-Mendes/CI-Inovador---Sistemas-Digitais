`timescale 1ns / 1ps

module tb_decodificador_uart;

    reg        clk;
    reg        reset;
    reg        RX;
    wire [7:0] dado;
    wire       dado_valido;
    wire       paridade;
    wire       inicio;

    // Instanciacao do DUT (Device Under Test)
    decodificador_uart dec_inst (
        .clk         (clk),
        .reset       (reset),
        .RX          (RX),
        .dado        (dado),
        .dado_valido (dado_valido),
        .paridade    (paridade),
        .inicio      (inicio)
    );

    // Geracao de clock (periodo = 100 ns -> igual ao periodo de 1 bit serial)
    initial begin
        clk = 1'b0;
        forever #50 clk = ~clk;
    end

    // Monitoramento automatico quando 'dado_valido' for ativado
    always @(posedge clk) begin
        if (!reset && dado_valido) begin
            $display("[%0t ns] Byte recebido: 0x%02H (paridade=%b)", $time, dado, paridade);
        end
    end

    task enviar_byte_uart;
        input [7:0] byte_tx;
        integer i;
        logic  bit_paridade;
        begin
            #1;
            bit_paridade=^(byte_tx);
            $display("[%0t ns] Enviando byte: 0x%02H (paridade=%b)", $time, byte_tx, bit_paridade);
            // 1. Start bit (nivel baixo por 1 ciclo de clock)
            @(negedge clk);
            RX = 1'b0;
            
            // 2. Bits de dados: LSB primeiro (bit 0 ate bit 7)
            for (i = 0; i < 8; i = i + 1) begin
                @(negedge clk);
                RX = byte_tx[i];
            end

            // 3. Bit de paridade ("P")
            @(negedge clk);
            RX = bit_paridade;

            // 4. Stop bit ("T" - nivel alto por 1 ciclo de clock)
            @(negedge clk);
            RX = 1'b1;
        end
    endtask

    // Sequencia principal de simulacao
    initial begin
        // Arquivo de formas de onda (compativel com GTKWave / Icarus Verilog)
        $dumpfile("test.vcd");
        $dumpvars(0, tb_decodificador_uart);

        // Estado inicial: linha RX em repouso (nivel alto) e reset ativo
        RX    = 1'b1;
        reset = 1'b1;
        repeat (2) @(posedge clk);

        // Libera o reset e aguarda "n" ciclos em repouso
        @(negedge clk);
        reset = 1'b0;
        repeat ($urandom_range(10, 4)) @(posedge clk);

        // Envio do 1o byte: 
        enviar_byte_uart(8'h58);

        // Intervalo em repouso (RX = 1) mínimo zero clocks
        //@(posedge clk);

        // Envio do 2o byte: 
        enviar_byte_uart(8'hA3);
        
        // Intervalo em repouso (RX = 1) mínimo zero clocks
        repeat ($urandom_range(20, 10)) @(posedge clk);

        // Envio do 3o byte: 
        enviar_byte_uart(8'h91);



        // Envio do 4o byte: 
        enviar_byte_uart(8'h44);
        $display("[%0t ns] Forca a gerar um 'nao stop' = erro! = nao deve gerar um 'recebido' para 0x44", $time);
        RX = 1'b0;
        // Intervalo em repouso (RX = 1) mínimo zero clocks
        repeat ($urandom_range(20, 10)) @(posedge clk);
        
        
        // Aguarda alguns ciclos finais para observar a saida e encerra
        repeat (5) @(posedge clk);
        $display("[%0t ns] Fim da simulacao.", $time);
        $finish;
    end

endmodule