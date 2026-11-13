// ================================================================================
// ================================================================================

//                             DESCRIÇÃO DO SISTEMA

// ================================================================================
// ================================================================================
  - Largura de dados de 8 bits
  - Largura de endereço de 8 bits
  - Dados representados em complementos de 2

  - Endereçamento direto apenas (também conhecido como absoluto)

  - Na instruções de desvio o endereço contido na instrução corresponde à posição de memória da instrução a ser executada

// ================================================================================
// ================================================================================

//                          DESCRIÇÃO DOS COMPONENTES

// ================================================================================
// ================================================================================
 1. AC -> Acumulador de programa de 8 bits (necessário um registrador de 8 bits)
 2. PC -> Apontador de programa de 8 bits (necessário um registrador de 8 bits e um contador)
 3. Reg_NZ -> Registrador de estado com 2 bits, para os códigos de condição: negativo (N) e zero (Z)
              (Pode ser dois flip flops também)
 4. MEM -> Memória de 256 posições de 8 bits

// ================================================================================
// ================================================================================

//                              FORMATO DA INSTRUÇÃO

// ================================================================================
// ================================================================================
  - Formada por 1 ou 2 bytes, ou seja, ocupam uma ou duas posições na memória

  7              4 3                    0
  _______________________________________
  |     codigo    |     don't care      |
  |_______________|_____________________|

  _______________________________________
  |          endereço direto            |
  |_____________________________________|

  *Na instrução de 1 byte, os 4 bits mais significativos contém o código da instrução.
  *Na instrução de 2 bytes, o primeiro byte (mais significativo) contém o código. E o segundo byte (menos significativo), um endereço.
   Essas são instruções que fazem referência à memória

// ================================================================================
// ================================================================================

// Conjunto de Instruções é composto por 11 instruções, codificadas em 4 bits:

// ================================================================================
// ================================================================================
    |        |           |                                  |
    | Código | Instrução |         Comentário               |
    |________|___________|__________________________________|
    |  0000  |  NOP      | Nenhum Operação                  |
    |  0001  |  STA  end | Armazena acumulador (store)      |
    |  0010  |  LDA  end | Carrega acumulador (load)        |
    |  0011  |  ADD  end | Soma                             |
    |  0100  |  OR   end | "OU" lógico                      |
    |  0101  |  AND  end | "E" lógico                       |
    |  0110  |  NOT      | Inverte (complementa) acumulador |
    |  1000  |  JMP  end | Desvio incondicional (jump)      |
    |  1001  |  JN   end | Desvio condicional (jump on N)   |
    |  1010  |  JZ   end | Desvio condicional (jump on Z)   |
    |  1111  |  HLT      | Término de execução (halt)       |

    *end significa "endereço direto". 
    *Nas instruções de STA, LDA, ADD, OR e AND, end corresponde ao endereço de operando.
    *Nas instruções de JMP, JN e JZ, end corresponde ao endereço de desvio.

// ================================================================================
// ================================================================================

//                              AÇÕES EXECUTADAS

// ================================================================================
// ================================================================================
    |           |                                  |
    | Instrução |         Comentário               |
    |___________|__________________________________|
    |  NOP      | Nenhum Operação                  |
    |  STA  end | MEM(end) <- AC                   |
    |  LDA  end | AC <- MEM(end)                   |
    |  ADD  end | AC <- MEM(end) + AC              |
    |  OR   end | AC <- MEM(end) OR AC             |
    |  AND  end | AC <- MEM(end) AND AC            |
    |  NOT      | AC <- NOT AC                     |
    |  JMP  end | PC <- end                        |
    |  JN   end | IF N=1 THEN PC <- end            |
    |  JZ   end | IF Z=1 THEN PC <- end            |
    |  HLT      | Término de execução              |

// ================================================================================
// ================================================================================

//                              CÓDIGOS DE CONDIÇÃO

// ================================================================================
// ================================================================================
  - N (negativo): sinal do resultado
        1 - resultado é negativo
        0 - resultado é positivo (ou, formalmente, não negativo)
  - Z (zero): indica resultado igual a zero
        1 - resultado é igual a zero
        0 - resultado é diferente de zero

    *As instruções lógicas e aritméticas (ADD, NOT, AND, OR) e a instrução de transferência LDA afetam os códigos de condição N e Z.
    *As demais instruções (STA, JMP, JN, JZ, NOP e HLT) não afetam.

// ================================================================================
// ================================================================================

//                              ETAPAS DE INSTRUÇÃO
//                          (B) Busca / (E) Execução:

// ================================================================================
// ================================================================================


// Tamanho: 1 Byte
NOP:
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  Nenhuma operação

// Tamanho: 2 Byte
STA:                            
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC)
        PC <- PC + 1
        MEM(end) <- AC

// Tamanho: 2 Byte
// Atualiza N e Z
LDA:                            
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC)
        PC <- PC + 1
        AC <- MEM(end); 

// Tamanho: 2 Byte
// Atualiza N e Z
ADD:                            
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC)
        PC <- PC + 1
        AC <- AC + MEM(end)

// Tamanho: 2 Byte
// Atualiza N e Z
OR:                            
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC)
        PC <- PC + 1
        AC <- AC or MEM(end)

// Tamanho: 2 Byte
// Atualiza N e Z
AND:                            
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC)
        PC <- PC + 1
        AC <- AC and MEM(end)

// Tamanho: 1 Byte
// Atualiza N e Z
NOT:                            
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  AC <- NOT(AC)

// Tamanho: 2 Byte
JMP:                            
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC)
        PC <- end

// Tamanho: 2 Byte
// Se N = 1
JN:                             
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC)
        PC <- end
// Se N = 0
JN:                             
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC) // esta transferência a rigor é desnecessária
        PC <- PC + 1

// Tamanho: 2 Byte
// Se Z = 1
JZ:                             
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC)
        PC <- end
// Se Z = 0
JZ:                             
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  end <- MEM(PC) // esta transferência a rigor é desnecessária
        PC <- PC + 1

HLT:
    B:  RI <- MEM(PC)
        PC <- PC + 1
    E:  Parar o processamento

// ================================================================================
// ================================================================================

//                          PROCESSO DE TRANSFERÊNCIA

// ================================================================================
// ================================================================================
x <- MEM(y):
    1. REM <- y:    Transferência do endereço y para o (R)eg. de (E)ndereços da (M)emória
    2. Read:        Ativação de uma operação de Leitura da Memória
    3. x <- RDM:    Transferência do (R)eg. de (D)ados da (M)emória para x

MEM(y) <- x:
    1. REM <- y:    Transferência do endereço y para o (R)eg. de (E)ndereços da (M)emória
    2. x <- RDM:    Transferência do dado x para o (R)eg. de (D)ados da (M)emória
    3. Write:   Ativação de uma operação de Escrita da Memória


// ================================================================================
// ================================================================================

//                             ETAPAS DE TRANFERÊNCIA
//                           (B) Busca / (E) Execução

// ================================================================================
// ================================================================================

// Tamanho: 1 Byte
NOP:
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  Nenhuma operação

// Tamanho: 2 Byte
STA:                            
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  REM <- PC
        [Read]
        PC <- PC + 1
        REM <- RDM
        RDM <- AC
        Write

// Tamanho: 2 Byte
// Atualiza N e Z
LDA:                            
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  REM <- PC
        [Read]
        PC <- PC + 1
        REM <- RDM
        [Read]
        AC <- RDM
        Atualiza N e Z

// Tamanho: 2 Byte
// Atualiza N e Z
ADD:                            
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  REM <- PC
        [Read]
        PC <- PC + 1
        REM <- RDM
        [Read]
        AC <- AC + RDM
        Atualiza N e Z

// Tamanho: 2 Byte
// Atualiza N e Z
OR:                            
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  REM <- PC
        [Read]
        PC <- PC + 1
        REM <- RDM
        [Read]
        AC <- AC or RDM
        Atualiza N e Z

// Tamanho: 2 Byte
// Atualiza N e Z
AND:                            
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  REM <- PC
        [Read]
        PC <- PC + 1
        REM <- RDM
        [Read]
        AC <- AC and RDM
        Atualiza N e Z

// Tamanho: 1 Byte
// Atualiza N e Z
NOT:                            
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  AC <- not(AC)
        Atualiza N e Z

// Tamanho: 2 Byte
JMP:                            
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  REM <- PC
        [Read]
        PC <- RDM

// Tamanho: 2 Byte
// Se N = 1
JN:                             
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  REM <- PC
        [Read]
        PC <- RDM
// Se N = 0
JN:                             
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  PC <- PC + 1

// Tamanho: 2 Byte
// Se Z = 1
JZ:                             
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  REM <- PC
        [Read]
        PC <- RDM
// Se Z = 0
JZ:                             
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  PC <- PC + 1

HLT:
    B:  REM <- PC
        [Read]
        PC <- PC + 1
        RI <- RDM
    E:  Parar o processamento

// ================================================================================
// ================================================================================

//                  SUGESTÕES DE IMPLEMENTAÇÃO DOS COMPONENTES

// ================================================================================
// ================================================================================

// PC:
O incremento pode ser feito usando:
//   - Operação de soma da ULA
//   - Um somador próprio
  - Contador (incrementa sempre que acionado)

// Regitradores:
Para cada registrador, é necessário um cinal de "carga" (load) correspondente, que indica quando o valor da sua entrada deve ser armazenado.

// Sinais de condição:
Para atualizar N e Z durante a operação de LDA, acrescentou-se uma operação de tranferência por meio da ULA.
  - Operação PASS: Q <= Y

// ULA
As entradas X e Y da ULA, assim como operações de not(X) e Y, foram escolhidas a fim de simplificar as tranferências. Com isso, a entrada X está permanentemente ligada à saída do acumulador AC, e a entrada Y da ULA está ligada ao RDM

//
O único registrador que recebe dados de duas fontes é o REM. Para solucionar esse conflito, utiliza-se um multiplexador que seleciona entre:
  - PC  (sel = 0)
  - RDM (sel = 1)

// ================================================================================
// ================================================================================

//                              SINAIS DE CONTROLE

// ================================================================================
// ================================================================================
    |   |                       |                               |
    |ID |     tranferência      |         Sinais de controle    |
    |___|_______________________|_______________________________|
    | 0 | REM <- PC             | sel = 0; ld_rem = 1           |
    | 1 | REM <- RDM            | sel = 1; ld_rem = 1           |
    | 2 | PC <- PC + 1          | inc_pc = 1                    |
    | 3 | RI <- RDM             | ld_ri = 1                     |
    | 4 | RDM <- AC             | ld_rdm = 1                    |
    | 5 | AC <- RDM;        N; Z| ULA(Y); ld_ac = 1; ld_nz = 1  |
    | 6 | AC <- AC + RDM;   N; Z| ULA(ADD); ld_ac = 1; ld_nz = 1|
    | 7 | AC <- AC or RDM;  N; Z| ULA(OR); ld_ac = 1; ld_nz = 1 |
    | 8 | AC <- AC and RDM; N; Z| ULA(AND); ld_ac = 1; ld_nz = 1|
    | 9 | AC <- not(AC);    N; Z| ULA(NOT); ld_ac = 1; ld_nz = 1|
    | A | PC <- RDM             | ld_pc = 1                     |
    | B | RDM <- MEM(REM)       | r_en = 1                      |
    | C | MEM(REM) <- RDM       | w_en = 1                      |
    | D | goto t0               | goto_t0 = 1                   |

    *sinais de controle de 14 bits:
        sel     -> seletor MUX
        ld_rem  -> "carga" REM
        ld_pc   -> "carga" PC
        inc_pc  -> incrementa PC
        ld_ri   -> "carga" RI
        ld_rdm  -> "carga" RDM
        ld_ac   -> "carga" AC
        ld_nz   -> "carga" NZ
        r_en    -> habilita leitura (read)
        w_en    -> habilita escrita (write)
        goto_t0 -> goto t0
        
        opcode = 000    -> ULA(ADD)
        opcode = 001    -> ULA(AND)
        opcode = 010    -> ULA(OR)
        opcode = 011    -> ULA(NOT)
        opcode = 100    -> ULA(Y)

// ================================================================================
// ================================================================================

//                       TEMPORIZAÇÃO DOS SINAIS DE CONTROLE

// ================================================================================
// ================================================================================

    |       |       |       |       |       |       |       |
    | tempo | STA   | LDA   | ADD   | OR    | AND   | NOT   |
    |_______|_______|_______|_______|_______|_______|_______|
    |  t0   | 0     | 0     | 0     | 0     | 0     | 0     |
    |  t1   | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  |
    |  t2   | 3     | 3     | 3     | 3     | 3     | 3     |
    |  t3   | 0     | 0     | 0     | 0     | 0     | 9; D  |
    |  t4   | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  |||||||||
    |  t5   | 1     | 1     | 1     | 1     | 1     |||||||||
    |  t6   | 4     | B     | B     | B     | B     |||||||||
    |  t7   | C; D  | 5; D  | 6; D  | 7; D  | 8; D  |||||||||

    |       |       |       |       |       |       |       |       |
    | tempo | JMP   | JN.N  | JN.'N | JZ.Z  | JZ.'Z | NOP   | HTL   |
    |_______|_______|_______|_______|_______|_______|_______|_______|
    |  t0   | 0     | 0     | 0     | 0     | 0     | 0     | 0     |
    |  t1   | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  |
    |  t2   | 3     | 3     | 3     | 3     | 3     | 3     | 3     |
    |  t3   | 0     | 0     | 2; D  | 0     | 2; D  | D     |       |
    |  t4   | B     | B     ||||||||| B     |||||||||||||||||||||||||
    |  t5   | A; D  | A; D  ||||||||| A; D  |||||||||||||||||||||||||
    |  t6   |||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    |  t7   |||||||||||||||||||||||||||||||||||||||||||||||||||||||||

// ================================================================================
// ================================================================================

//                       GERADOR DE TEMPORIZAÇÃO

// ================================================================================
// ================================================================================
O gerador de tempo pode ser feito por:
 1. Um registrador contador, que geral os sinais de tempo (t0 a t7) a partir do sinal de CLOCK
//  2. Uma lógica combinacional com os sinais de tempo, sinais do decodificador de instruções, e os sinais dos flipflops NZ

O registrador contador pode ser implementado de duas formas:
//  1. Com 3 flip-flos JK e um decodificador 3-8
 2. Um registrador de deslocamento, formado por 8 flip-flops D.
  - Na estrutura do gerador de tempo com registrador de deslocamento, o sinal goto_t0 força o valor lógico 1 no FF_t0.
  - Caso contrário, cada FF copia o valor do seu antecessor. Dessa forma tem-se sempre um FF em 1, e os demais em 0.