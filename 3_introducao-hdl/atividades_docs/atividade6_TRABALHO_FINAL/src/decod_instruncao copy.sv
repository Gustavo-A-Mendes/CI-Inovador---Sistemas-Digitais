import neander_pkg::*;

module decod_instruncao (
    input   instructions_t  inst_code_i,
    input   logic   [1:0]   nz_i,
    input   logic   [7:0]   t_num_i,        // Tempo (Vetor One-Hot t0 a t7)
    output  ctrl_dpath_t    dpath_ctrl_o,
    output  ctrl_dpath_t    mem_ctrl_o
);

    // Matriz de instruções:
    /*
      - Sinais de controle necessitam de 15 bits:
            13 bits de controle do DATAPATH (10 bits individuais e 3 do opcode da ULA)
             2 bits de controle da MEMORIA (N e Z)
      - São 11 instruções (13 considerando as duas situações das instrução condicional JN e JZ)
      - Cada instrução requer até 7 tempos

        |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
        | tempo | STA   | LDA   | ADD   | OR    | AND   | NOT   | JMP   | JN.N  | JN.'N | JZ.Z  | JZ.'Z | NOP   | HTL   |
        |_______|_______|_______|_______|_______|_______|_______|_______|_______|_______|_______|_______|_______|_______|
        |  t0   | 0     | 0     | 0     | 0     | 0     | 0     | 0     | 0     | 0     | 0     | 0     | 0     | 0     |
        |  t1   | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  |
        |  t2   | 3     | 3     | 3     | 3     | 3     | 3     | 3     | 3     | 3     | 3     | 3     | 3     | 3     |
        |  t3   | 0     | 0     | 0     | 0     | 0     | 9; D  | 0     | 0     | 2; D  | 0     | 2; D  | D     |       |
        |  t4   | B; 2  | B; 2  | B; 2  | B; 2  | B; 2  ||||||||| B     | B     ||||||||| B     |||||||||||||||||||||||||
        |  t5   | 1     | 1     | 1     | 1     | 1     ||||||||| A; D  | A; D  ||||||||| A; D  |||||||||||||||||||||||||
        |  t6   | 4     | B     | B     | B     | B     |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        |  t7   | C; D  | 5; D  | 6; D  | 7; D  | 8; D  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


                    [ sel  | ld_rem | ld_pc | inc_pc | ld_ri | sel_rdm | ld_rdm | ld_ac | ld_nz | goto_t0 | op_code | w_en  | r_en  ]
        controle =      0       0       0       0       0       0           0       0       0       0         000       0       0

        |       |                    |
        | tempo |       STA          |
        |_______|____________________|
        |  t0   | 010_0000_0000_0000 |
        |  t1   | 000_1000_0000_0001 |
        |  t2   | 000_0100_0000_0000 |
        |  t3   | 010_0000_0000_0000 |
        |  t4   | 000_1000_0000_0001 |
        |  t5   | 110_0000_0000_0000 |
        |  t6   | 000_0001_0000_0000 |
        |  t7   | 000_0000_0000_0110 |


    */

    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================
    logic n, z;     // sinais de Status N e Z, da ULA
    assign n    = nz_i[0];
    assign z    = nz_i[1];

    // Declarando matrizes de memórias, com tamanho da palavra e quantidade de linhas dinâmicas:
    ctrl_dpath_t    rom_controle_dpath  [instructions_t'(0).first() : instructions_t'(0).last()][0:7];
    ctrl_mem_t      rom_controle_mem    [instructions_t'(0).first() : instructions_t'(0).last()][0:7];

    // ======================================================================
    //                            DEFININDO LÓGICA
    // ======================================================================

    // Inicializando ROM das instruções:
    instructions_t instrucao;

    always_comb begin
        
        // Concatena as structs de sinais de controle:
        rom_controle = {rom_controle_dpath, rom_controle_mem};

        // Zera matrizes de controle:
        foreach (rom_controle[i, j]) rom_controle[i][j] = '0;

        // Inicializa matriz:
        instrucao = instrucao.first();

        for (int i = 0; i < instrucao.num(); i++) begin
            unique case(instrucao)
                INST_NOP: begin
                    rom_controle[INST_NOP][0] = ();
                    rom_controle[INST_NOP][1] = ();
                    rom_controle[INST_NOP][2] = ();
                    rom_controle[INST_NOP][3] = ();
                    rom_controle[INST_NOP][4] = ();
                    rom_controle[INST_NOP][5] = ();
                    rom_controle[INST_NOP][6] = ();
                    rom_controle[INST_NOP][7] = ();
                end

                INST_STA: begin
                    rom_controle[INST_STA][0] = ();
                    rom_controle[INST_STA][1] = ();
                    rom_controle[INST_STA][2] = ();
                    rom_controle[INST_STA][3] = ();
                    rom_controle[INST_STA][4] = ();
                    rom_controle[INST_STA][5] = ();
                    rom_controle[INST_STA][6] = ();
                    rom_controle[INST_STA][7] = ();
                end

                INST_LDA: begin
                    rom_controle[INST_LDA][0] = ();
                    rom_controle[INST_LDA][1] = ();
                    rom_controle[INST_LDA][2] = ();
                    rom_controle[INST_LDA][3] = ();
                    rom_controle[INST_LDA][4] = ();
                    rom_controle[INST_LDA][5] = ();
                    rom_controle[INST_LDA][6] = ();
                    rom_controle[INST_LDA][7] = ();
                end

                INST_ADD: begin
                    rom_controle[INST_ADD][0] = ();
                    rom_controle[INST_ADD][1] = ();
                    rom_controle[INST_ADD][2] = ();
                    rom_controle[INST_ADD][3] = ();
                    rom_controle[INST_ADD][4] = ();
                    rom_controle[INST_ADD][5] = ();
                    rom_controle[INST_ADD][6] = ();
                    rom_controle[INST_ADD][7] = ();
                end

                INST_OR: begin
                    rom_controle[INST_OR][0] = ();
                    rom_controle[INST_OR][1] = ();
                    rom_controle[INST_OR][2] = ();
                    rom_controle[INST_OR][3] = ();
                    rom_controle[INST_OR][4] = ();
                    rom_controle[INST_OR][5] = ();
                    rom_controle[INST_OR][6] = ();
                    rom_controle[INST_OR][7] = ();
                end

                INST_AND: begin
                    rom_controle[INST_AND][0] = ();
                    rom_controle[INST_AND][1] = ();
                    rom_controle[INST_AND][2] = ();
                    rom_controle[INST_AND][3] = ();
                    rom_controle[INST_AND][4] = ();
                    rom_controle[INST_AND][5] = ();
                    rom_controle[INST_AND][6] = ();
                    rom_controle[INST_AND][7] = ();
                end

                INST_NOT: begin
                    rom_controle[INST_NOT][0] = ();
                    rom_controle[INST_NOT][1] = ();
                    rom_controle[INST_NOT][2] = ();
                    rom_controle[INST_NOT][3] = ();
                    rom_controle[INST_NOT][4] = ();
                    rom_controle[INST_NOT][5] = ();
                    rom_controle[INST_NOT][6] = ();
                    rom_controle[INST_NOT][7] = ();
                end

                INST_JMP: begin
                    rom_controle[INST_JMP][0] = ();
                    rom_controle[INST_JMP][1] = ();
                    rom_controle[INST_JMP][2] = ();
                    rom_controle[INST_JMP][3] = ();
                    rom_controle[INST_JMP][4] = ();
                    rom_controle[INST_JMP][5] = ();
                    rom_controle[INST_JMP][6] = ();
                    rom_controle[INST_JMP][7] = ();
                end

                INST_JN: begin
                    rom_controle[INST_JN][0] = ();
                    rom_controle[INST_JN][1] = ();
                    rom_controle[INST_JN][2] = ();
                    rom_controle[INST_JN][3] = ();
                    rom_controle[INST_JN][4] = ();
                    rom_controle[INST_JN][5] = ();
                    rom_controle[INST_JN][6] = ();
                    rom_controle[INST_JN][7] = ();
                end

                INST_JZ: begin
                    
                end

                INST_HLT: begin
                    
                end
            endcase

            instrucao = instrucao.next();
        end
    end
endmodule