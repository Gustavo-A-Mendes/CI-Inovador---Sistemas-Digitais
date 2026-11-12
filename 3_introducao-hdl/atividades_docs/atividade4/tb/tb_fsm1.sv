`timescale 1ns / 1ps

module tb_top_level;

    // Sinais do Testbench
    logic clk_i;
    logic rst_n_i;
    logic B_i;
    logic LED_o;
    logic [2:0] state_o;

    // Instância do DUT. 
    // Usamos um truque de hierarquia do simulador para injetar o parâmetro 
    // diretamente no módulo interno 'c0' sem precisar repassá-lo pelo top_level!
    top_level1 dut (.*);
    
    // Sobrescrevemos o parâmetro do contador interno para simular rápido (contará até 3)
    // defparam dut.c0.N = 3; 

    // Geração de Clock (50MHz -> T = 20ns)
    initial begin
        clk_i = 1'b0;
        forever #10 clk_i = ~clk_i;
    end

    // --- CLASSE DE ESTÍMULOS ALEATÓRIOS (CRV) ---
    class double_click_stimulus;
        rand int press_time; // Clocks com o botão apertado
        rand int gap_time;   // Clocks entre o 1º e o 2º clique
        
        // Restrições (Constraints) simulando um dedo humano
        constraint c_human_behavior {
            press_time inside {[1 : 4]}; 
            gap_time   inside {[1 : 3]};
        }
    endclass

    // --- THREAD DE INJEÇÃO ---
    initial begin
        static double_click_stimulus stim = new();
        
        // Inicialização
        rst_n_i = 1'b0; B_i = 1'b0;
        #50;
        @(negedge clk_i) rst_n_i = 1'b1;

        $display("INFO: Iniciando bateria de CRV...");

        repeat (5) begin // Roda 5 cenários aleatórios
            assert(stim.randomize()) else $fatal("Erro no solver do CRV");
            
            // 1º Clique
            @(negedge clk_i) B_i = 1'b1;
            repeat(stim.press_time) @(negedge clk_i);
            
            // Solta o botão
            B_i = 1'b0;
            repeat(stim.gap_time) @(negedge clk_i);
            
            // 2º Clique
            B_i = 1'b1;
            repeat(stim.press_time) @(negedge clk_i);
            B_i = 1'b0;
            
            // Espera o FSM processar e o Timer estourar
            wait(state_o == 3'b011); // Entrou em S3
            wait(state_o == 3'b100); // Timer estourou, foi para S4
            
            repeat(3) @(negedge clk_i); // Respiro entre testes
        end
        
        $display("INFO: Teste CRV concluído.");
        $finish;
    end

    // --- SYSTEMVERILOG ASSERTIONS (SVA) ---
    // Contrato de Hardware: "É impossível o LED acender se a máquina não estiver no estado S3"
    property p_led_only_in_s3;
        @(posedge clk_i) disable iff (!rst_n_i)
        (LED_o == 1'b1) |-> (state_o == 3'b011);
    endproperty

    assert_led_behavior: assert property (p_led_only_in_s3)
        else $error("CRITICAL: LED acendeu fora do estado S3 no Delta Cycle atual!");

endmodule