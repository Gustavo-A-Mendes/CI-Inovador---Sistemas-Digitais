/*
        ANÁLISE PARA MONTAGEM DO TESTBENCH:

        O módulo refere-se a um sistema de semáforo completo, com:
          - Sinal para rua 1
          - Sinal para rua 2
          - Sinal para pedestre
        
        Este sinal é temporizado, alternando entre os estados de maneira automática,
        de acordo com o tempo especificado pelo projeto, EM SEGUNDOS. 
        Com o pedestre sempre em VERMELHO.

        Em caso do botão de pedestre ser apertado, o fluxo dos sinais das ruas para (ambos em vermelho)
        e o pedestre vai para VERDE. Após o tempo estipulado ele volta para o estado inicial.

        Sinal       Tempo_Verde     Tempo_Amarelo       Tempo_Vermelho
        ______________________________________________________________
        rua1            20                5                   35
        rua2            30                5                   25
        pedestre        15                --                  --

        ESTADOS:
            S0  -->  rua1:VERDE     rua2:VERMELHO       pedestre:VERMELHO
            S1  -->  rua1:AMARELO   rua2:VERMELHO       pedestre:VERMELHO
            S2  -->  rua1:VERMELHO  rua2:VERDE          pedestre:VERMELHO
            S3  -->  rua1:VERMELHO  rua2:AMARELO        pedestre:VERMELHO
            S4  -->  rua1:VERMELHO  rua2:VERMELHO       pedestre:VERDE
    */

/*
    DEFININDO TIMESCALE
    
    Durante o testbench, temos controle de tempo usando o símbolo "#", onde #1 é "uma unidade de tempo". 
    Aqui definimos unidade/resolução dessa unidade de tempo.

    Por padrão, nossa escala tem a unidade de tempo equivalente a 1 NANOSSEGUNDO e resolução de 1 PICOSSEGUNDO (1ns/1ps)

    Contudo, como nossa escala de teste vai estar em segundos, alguns sinais que variam em uma escala menor (o clock, por exemplo)
    vão ter sua leitura prejudicada. Além de que a simulação pode não dar conta de simular tudo. 
    
    Portanto, temos duas opções viáveis aqui:
        1. Usar uma escala mais alta. Uma sugestão seria por em uma escala de 1s/1ms ou 1ms/1us
        2. Reduzir a escala do sistema. Nesse caso, como nossa frequência é de 100MHz (Tclk = 10ns)
           podemos reduzir a escala para MICROSSEGUNDOS (us)

    Vamos usar a opção 1, e usar a escala de 1s/1ms.
*/
`timescale 1s/1ms

module tb_semaforo_completo;

    /*
        VALOR DA CONTAGEM DO GERADOR DE PULSO:

        No gerador de pulso de 1 segundo, temos um contador que conta até 1s.

        Para um clock de 100MHz (período de 10ns), o contador incrementa a cada 10ns,
        precisando de 100_000_000 de ciclos de clock para contar até 1s.

        Com nosso timescale ajustado para 1s/1ms, poderiamos usar um clock de teste de 10Hz (período de 100ms),
        e o valor_maximo de contagem seria reduzido para 10.
    */ 
    parameter MAX_COUNT_TB = 27'd10;


    /*
        INSTANCIANDO BLOCO DE TESTE:

        Para chamar o bloco que você quer testar, temos a seguinte sintaxe:

        nome_modulo #(parametros) nome_instancia (entradas_e_saidas_do_modulo)

        nome_modulo     -> nome usado para declarar o módulo (no meu caso, semaforo_completo)
        #(parametros)   -> (Opcional) área reservada para manipular parâmetros declarados internamente no módulo
        
        nome_instancia  -> "apelido" que você dá para a sua instancia. Ele deve ser único, ou seja, 
                           se você tiver várias instancias, todas devem ter nome diferente.
        
        (entradas_e_saida_modulo)   ->  aréa para definir a conexão dos pinos de entradas e saída do módulo instanciado.
                                        A ideia é você conectar esse sinais aos sinais declarados no testbench.
                                        OBS.: não precisa ter o mesmo nome que os sinais internos do módulo.
                           
    */
    logic           clk_tb, reset_tb, pedestre_tb;
    logic   [2:0]   sinal_rua1_tb, sinal_rua2_tb;
    logic   [1:0]   sinal_pedestre_tb;

    semaforo_completo #(
        .MAX_COUNT(MAX_COUNT_TB)
    ) sf(
        .clk(clk_tb),
        .reset(reset_tb),
        .pedestre(pedestre_tb),
        .sinal_rua1(sinal_rua1_tb),
        .sinal_rua2(sinal_rua2_tb),
        .sinal_pedestre(sinal_pedestre_tb)
    );

    /*
        MONTAGEM DO TESTBENCH

        Em um testbench simples, podemos dividir em três etapas:

         1. Geração do pulso de clock (caso o circuito seja síncrono)
                Aqui, você inicializa o sinal de clock (normalmente em nivel baixo)
                e define o loop de atualização dele:
                  - Initial ->  para a inicialização
                  - Always  ->  para o loop (ou podemos usar a estrutura "forever" dentro do initial para definir o loop)
                initial
         2. Geração dos estímulos
                Define a manipulação dos sinais de entradas, definindo inclusive o tempo de cada estado desses sinais.
        
         3. (Opcional) Exibição dos valores ($monitor ou $display)
                Caso deseje-se observar os resultados no terminal, podemos usar comandos para exibir mensagens desejadas:
                  - $display() -->  Equivalente a um "print()". Você define o texto a ser escrito.
                                    Ex.:
            $display("t=%t \t clk=%b, rst=%b, p=%b, sgn_r1=%b, sgn_r2=%b, sgn_p=%b", $time, clk_tb, reset_tb, pedestre_tb, sinal_rua1_tb, sinal_rua2_tb, sinal_pedestre_tb);
                    
                                    É executado apenas na linha que foi chamado.
                  
                  - $monitor() -->  Exibe texto igual ao $display.
                                    Ex.:
            $monitor("t=%t \t clk=%b, rst=%b, p=%b, sgn_r1=%b, sgn_r2=%b, sgn_p=%b", $time, clk_tb, reset_tb, pedestre_tb, sinal_rua1_tb, sinal_rua2_tb, sinal_pedestre_tb);

                                    Porém tem um comportamente diferente na sua execução, pois ele só precisa ser chamado 1 única vez, 
                                    e sempre que alguma das variáveis que ele está "monitorando" mudar, ele vai ser executado novamente.

            OBS.: Nesse exemplo estamos monitorando o clock também. Nessa prática do, se usarmos a escala de 1ns/1ps, e desejarmos rodar o teste com fidelidade ao tempo do semáforo, em segundos, o resultado com o $monitos vai ser muito extenso, por ele vai exibir valores a cada 5ns, enquanto o nosso sistema só tem alguma mudança real, após vários segundos. 
            
            Então nesse caso, o ideal seria usar uma escala maior, caso desejemos usar o terminal para exibir o teste. 
            Ou colocar um $display que execute em loop, com um período definido (vamos testar esse jeito).
                                 
    */

    // 1. Geração do pulso de clock:
    // (`timescale 1ns/1ps) --> CLOCK de 100MHz (Tclk = 10ns)           --> pulso de  5ns (#5)
    // (`timescale 1s/1ms)  --> CLOCK de 10Hz   (Tclk = 100ms ou 0.1s)  --> pulso de 50ms (#0.05)
    initial begin
        clk_tb = 1'b0;
        forever begin
            #0.05 clk_tb = ~clk_tb;
        end
    end

    // 2. Gerando os estímulos:
    /*
        A geração de estímulo é, basicamente, a manipulação de valores para os sinais conectados às ENTRADAS do módulo instanciado.
        Nessa manipulação, você tem o controle para definir o valor desses sinais e o tempo que cada um fica ativo, 
        usando os marcadores de tempo:
          - símbolo "#"  --> determina quantas "unidades de tempo" ele vai esperar ( Ex.#1, #5, #0.2, ...)
          
          - símbolo "##" --> determina quantos "ciclos de clock" ele vai esperar (Ex. ##2, ##5, ##7, ...)

          - @(posedge)   --> espera 1 pulso de clock.

          - repeat(N) @(posedge clk) --> espera N pulsos de clock. (semelhante ao símbolo "##")

          - wait(condicao) --> espera até que certa condição ocorra. (Ex. wait(pedestre == 1'b1) )

        O comportamento que quero demostrar é:
          - O contador de tempo está incrementando em 1s.
          - O sistema está fluindo entre os estados de acordo com o esperado, respeitando a temporização definida.
          - O botão do pedestre parando o fluxo da rua e ativando o sinal do pedestre pelo tempo dado, retornando
            ao estado inicial (S0) após isso.
    */
    
    initial begin

        $sdf_annotate("../src/atrasos_meu_design.sdf", tb_semaforo_completo.sf, , "sdf_log.txt", "MAXIMUM");

        /*
            PASSO 1: INICIALIZAR SINAIS

            É uma boa prática atribuir um valor inicial para os sinais que serão manipulados, 
            para iniciar o teste com valores "limpos".

            OBS.: Como já inicializei o clock no initial anterior, ele não precisa estar aqui,
                  mas eu poderia ter deixado para inicializar o clock aqui, e lá em cima, 
                  ficado apenas a geração do pulso.
        */
        reset_tb = 1'b1;       // sinal reset inicia "ligado" (no sinal de ativação dele, seja 1 ou 0) (boa prática)
        pedestre_tb = 1'b0;    // sinal de pedestre inicia desligado
        @(posedge clk_tb);

        /*
            TESTES COM ESTÍMULOS

            Agora vamos começar as manipulações dos estímulos.

            Aqui vamos trabalhar com o "menor esforço necessário", isto é, em vez de testar CADA SITUAÇÃO POSSÍVEL, 
            vamos apenas "mostrar o suficiente", para comprovar o comportamento desejado.
        */

        // COMPORTAMENTO 1: FLUXO DOS SINAIS DAS RUAS
        /*
            Para testar um ciclo completo dos sinais das ruas funcionando, basta eu dar o devido tempo:
            1s = 1_000_000_000ns
            1s = 1_000ms

            Um ciclo completo são 60s
            Então vamos dar tempo suficiente para ver isso ocorrer, uns 70s:
        */
        reset_tb = 1'b0;
        #70;

        // COMPORTAMENTO 2: ACIONAMENTO DO SINAL DO PEDESTRE
        /*
            Ao acionar do sinal do pedestre, o sinal dele fica acionado por 15s e, após isso, indo para o estado inicial. 
            Então, para testarmos isso, temos que: 
              - Atualizar o sinal de entrada "pedestre"
              - Dar o tempo suficiente para vermos se ele funcionar (ligado por 15s e voltando para S0)

            Vamos adicionar mais 20s no teste.

            OBS.1: Idealmente, o sinal de pedestre é acionado por um breve momento, depois é desativado. 
                  Então vamos fazer ele ativa por 1s apenas. Os 20s adicionados serão "quebrados": 
                    - 1s para o botão de pedestre ativo
                    - 19s para o botão de pedestre desativado
        */
        pedestre_tb = 1'b1; // Acionado por 1s
        #1;

        pedestre_tb = 1'b0; 
        #19;

        /*
            FINALIZAÇÃO DO TESTE

            Você deve dizer quando o seu teste deve encerrar, usando a chamada 
                $finish;

            Pensando em funções de linguagens de programação (como C ou Python), seria o equivalente ao "return" no fim da função

            Ele sempre deve ser acessível em seu fluxo de teste. Nesse exemplo, que foi um teste "linear", sem loops, basta por no final.
            Mas caso houvesse loops em seu teste, você deveria garantir que seu loop tivesse uma condição para chegar ao "$finish"
            ou um critério de quebra para sair do loop.
        */
        $finish;
    end

    /*
        EXIBIÇÃO DOS SINAIS NO TERMINAL
    */
    always begin
        // Exibir teste no terminal:
        $display("t=%t \t clk=%b, rst=%b, p=%b, sgn_r1=%b, sgn_r2=%b, sgn_p=%b, tempo=%d", 
                    $time, 
                    clk_tb, 
                    reset_tb, 
                    pedestre_tb, 
                    sinal_rua1_tb, 
                    sinal_rua2_tb, 
                    sinal_pedestre_tb,
                    sf.tempo);

        #1;
    end
    /*
        EXTRA:
        
        O testbench pode conter outras etapas de funcionamento. Por exemplo, é comum querermos gerar o dumpfile, 
        arquivo necessário para algumas ferramentas de simulação para poder visualizar a forma de onda do teste.

        O importante é saber/entender que cada bloco "initial" ou "always" existente no código, funcionando de forma PARALELA.
        Portanto, é preciso estar atento a esse comportamento para que não haja nenhuma na lógica do teste. Por exemplo:

            // initial para teste:
            initial begin
                Definindo estímulos...
            end

            // initial para finalizar simulação:
            initial begin
                $finish
            end
        
        Nesse caso, o bloco de teste começa junto com o de finalização da simulação. 
        Dessa forma, o testbench vai encerrar instantaneamente, sem realizar as manipulações das entradas.
    */
endmodule