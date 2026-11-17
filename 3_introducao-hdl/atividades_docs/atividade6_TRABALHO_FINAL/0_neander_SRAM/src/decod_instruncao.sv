`timescale 1ns/1ps

import neander_pkg::*;

module decod_instruncao (
    input   instructions_t  inst_code_i,
    input   logic   [1:0]   nz_i,
    input   logic   [7:0]   t_i,        // Tempo (Vetor One-Hot t0 a t7)
    output  ctrl_dpath_t    dpath_ctrl_o,
    output  ctrl_mem_t    mem_ctrl_o
);

    // Matriz de instruções:
    /*
        |   |                       |                                   |
        |ID |     tranferência      |         Sinais de controle        |
        |___|_______________________|___________________________________|
        | 0 | REM <- PC             | sel_rem = 0; ld_rem = 1           |
        | 1 | REM <- RDM            | sel_rem = 1; ld_rem = 1           |
        | 2 | PC <- PC + 1          | inc_pc = 1                        |
        | 3 | RI <- RDM             | ld_ri = 1                         |
        | 4 | RDM <- AC             | ld_rdm = 1; sel_rdm = 1           |
        | 5 | AC <- RDM;        N; Z| ULA(Y); ld_ac = 1; ld_nz = 1      |
        | 6 | AC <- AC + RDM;   N; Z| ULA(ADD); ld_ac = 1; ld_nz = 1    |
        | 7 | AC <- AC or RDM;  N; Z| ULA(OR); ld_ac = 1; ld_nz = 1     |
        | 8 | AC <- AC and RDM; N; Z| ULA(AND); ld_ac = 1; ld_nz = 1    |
        | 9 | AC <- not(AC);    N; Z| ULA(NOT); ld_ac = 1; ld_nz = 1    |
        | A | PC <- RDM             | ld_pc = 1                         |
        | B | RDM <- MEM(REM)       | r_en = 1; ld_rdm = 1; sel_rdm = 0 |
        | C | MEM(REM) <- RDM       | w_en = 1                          |
        | D | goto t0               | goto_t0 = 1                       |

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

    */

    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================
    logic flag_n, flag_z;     // sinais de Status N e Z, da ULA
    assign flag_n   = nz_i[1];
    assign flag_z   = nz_i[0];

    // ======================================================================
    //                            DEFININDO LÓGICA
    // ======================================================================

    always_comb begin
        
        // Valores Default:
        dpath_ctrl_o = '{
            op_code :   OP_PASS,
            default :   0
        };

        mem_ctrl_o = '{
            default :   0
        };

        // Definindo fase de FETCH:
        if (t_i[0]) begin       // REM <- PC
            dpath_ctrl_o.sel_rem =  1'b0;   // Seleciona PC na entrada
            dpath_ctrl_o.ld_rem  =  1'b1;   // Habilita carga do REM
        end
        else if (t_i[1]) begin  // PC <- PC + 1; RDM <- MEM(REM)
            dpath_ctrl_o.inc_pc  =  1'b1;   // Incrementa PC
            dpath_ctrl_o.sel_rdm =  1'b0;   // Seleciona entrada de memória no RDM
            dpath_ctrl_o.ld_rdm  =  1'b1;   // Habilita carga do RDM
            mem_ctrl_o.r_en      =  1'b1;   // Habilita leitura da memória
        end
        else if (t_i[2]) begin  // RI <- RDM
            dpath_ctrl_o.ld_ri   =  1'b1;   // Habilita carga em RI
        end

        //
        else begin
            unique case(inst_code_i)
                INST_NOP: begin
                    if (t_i[3])
                        dpath_ctrl_o.goto_t0 =  1'b1;    // Reinicia temporização
                end

                INST_STA: begin
                    if (t_i[3]) begin       // REM <- PC
                        dpath_ctrl_o.sel_rem =  1'b0;
                        dpath_ctrl_o.ld_rem  =  1'b1;
                    end
                    else if (t_i[4]) begin  // PC <- PC + 1; RDM <- MEM(REM)
                        dpath_ctrl_o.inc_pc  =  1'b1;
                        dpath_ctrl_o.sel_rdm =  1'b0;
                        dpath_ctrl_o.ld_rdm  =  1'b1;
                        mem_ctrl_o.r_en      =  1'b1;
                    end
                    else if (t_i[5]) begin  // REM <- RDM
                        dpath_ctrl_o.sel_rem =  1'b1;   // Seleciona RDM na entrada
                        dpath_ctrl_o.ld_rem  =  1'b1;
                    end
                    else if (t_i[6]) begin  // RDM <- AC
                        dpath_ctrl_o.sel_rdm =  1'b1;   // Seleciona entrada de AC no RDM
                        dpath_ctrl_o.ld_rdm  =  1'b1;
                    end
                    else if (t_i[7]) begin  // MEM(REM) <- RDM; goto t0
                        dpath_ctrl_o.goto_t0 =  1'b1;
                        mem_ctrl_o.w_en      =  1'b1;  // Habilita escrita na memória
                    end
                end

                INST_LDA: begin
                    if (t_i[3]) begin       // REM <- PC
                        dpath_ctrl_o.sel_rem =  1'b0;
                        dpath_ctrl_o.ld_rem  =  1'b1;
                    end
                    else if (t_i[4]) begin  // PC <- PC + 1; RDM <- MEM(REM)
                        dpath_ctrl_o.inc_pc  =  1'b1;
                        dpath_ctrl_o.sel_rdm =  1'b0;
                        dpath_ctrl_o.ld_rdm  =  1'b1;                        
                        mem_ctrl_o.r_en      =  1'b1;
                    end
                    else if (t_i[5]) begin  // REM <- RDM
                        dpath_ctrl_o.sel_rem =  1'b1;   // Seleciona RDM na entrada
                        dpath_ctrl_o.ld_rem  =  1'b1;
                    end
                    else if (t_i[6]) begin  // RDM <- MEM(REM)
                        dpath_ctrl_o.sel_rdm =  1'b0;
                        dpath_ctrl_o.ld_rdm  =  1'b1;                        
                        mem_ctrl_o.r_en      =  1'b1;
                    end
                    else if (t_i[7]) begin  // AC <- RDM; N; Z; goto t0
                        dpath_ctrl_o.ld_ac   =  1'b1;   // Habilita carga de AC
                        dpath_ctrl_o.ld_nz   =  1'b1;   // Habilita carga de NZ
                        dpath_ctrl_o.goto_t0 =  1'b1;
                        dpath_ctrl_o.op_code =  OP_PASS;    // ULA opera em PASS
                    end
                end

                INST_ADD, INST_OR, INST_AND, INST_SUB: begin
                    if (t_i[3]) begin       // REM <- PC
                        dpath_ctrl_o.sel_rem =  1'b0;
                        dpath_ctrl_o.ld_rem  =  1'b1;
                    end
                    else if (t_i[4]) begin  // PC <- PC + 1; RDM <- MEM(REM)
                        dpath_ctrl_o.inc_pc  =  1'b1;
                        dpath_ctrl_o.sel_rdm =  1'b0;
                        dpath_ctrl_o.ld_rdm  =  1'b1;
                        mem_ctrl_o.r_en      =  1'b1;
                    end
                    else if (t_i[5]) begin  // REM <- RDM
                        dpath_ctrl_o.sel_rem =  1'b1;   // Seleciona RDM na entrada
                        dpath_ctrl_o.ld_rem  =  1'b1;
                    end
                    else if (t_i[6]) begin  // RDM <- MEM(REM)
                        dpath_ctrl_o.sel_rdm =  1'b0;
                        dpath_ctrl_o.ld_rdm  =  1'b1;
                        mem_ctrl_o.r_en      =  1'b1;
                    end
                    else if (t_i[7]) begin  // AC <- AC + RDM; N; Z; goto t0
                        dpath_ctrl_o.ld_ac   =  1'b1;
                        dpath_ctrl_o.ld_nz   =  1'b1;
                        dpath_ctrl_o.goto_t0 =  1'b1;
                        // operação da ULA
                        dpath_ctrl_o.op_code =  (inst_code_i == INST_ADD) ? OP_ADD :
                                                (inst_code_i == INST_SUB) ? OP_SUB :
                                                (inst_code_i == INST_OR)  ? OP_OR  : OP_AND;
                    end
                end

                INST_NOT: begin
                    if (t_i[3]) begin   // ~(AC); N; Z; goto t0
                        dpath_ctrl_o.ld_ac   =  1'b1;
                        dpath_ctrl_o.ld_nz   =  1'b1;
                        dpath_ctrl_o.goto_t0 =  1'b1;
                        dpath_ctrl_o.op_code =  OP_NOT; // ULA opera em NOT
                    end
                end

                INST_JMP: begin
                    if (t_i[3]) begin       // REM <- PC
                        dpath_ctrl_o.sel_rem =  1'b0;
                        dpath_ctrl_o.ld_rem  =  1'b1;
                    end
                    else if (t_i[4]) begin  // RDM <- MEM(REM)
                        dpath_ctrl_o.sel_rdm =  1'b0;
                        dpath_ctrl_o.ld_rdm  =  1'b1;
                        mem_ctrl_o.r_en      =  1'b1;
                    end
                    else if (t_i[5]) begin  // PC <- RDM; goto t0
                        dpath_ctrl_o.ld_pc   =  1'b1;   // Habilita carga paralela de PC
                        dpath_ctrl_o.goto_t0 =  1'b1;
                    end
                end

                INST_JN: begin
                    if (flag_n) begin
                        if (t_i[3]) begin       // REM <- PC
                            dpath_ctrl_o.sel_rem =  1'b0;
                            dpath_ctrl_o.ld_rem  =  1'b1;
                        end
                        else if (t_i[4]) begin  // RDM <- MEM(REM)
                            dpath_ctrl_o.sel_rdm =  1'b0;
                            dpath_ctrl_o.ld_rdm  =  1'b1;
                            mem_ctrl_o.r_en      =  1'b1;
                        end
                        else if (t_i[5]) begin  // PC <- RDM; goto t0
                            dpath_ctrl_o.ld_pc   =  1'b1;
                            dpath_ctrl_o.goto_t0 =  1'b1;
                        end
                    end
                    else begin
                        if (t_i[3]) begin   // PC <- PC + 1; goto t0
                            dpath_ctrl_o.inc_pc  =  1'b1;
                            dpath_ctrl_o.goto_t0 =  1'b1;
                        end
                    end
                end

                INST_JZ: begin
                    if (flag_z) begin
                        if (t_i[3]) begin       // REM <- PC
                            dpath_ctrl_o.sel_rem =  1'b0;
                            dpath_ctrl_o.ld_rem  =  1'b1;
                        end
                        else if (t_i[4]) begin  // RDM <- MEM(REM)
                            dpath_ctrl_o.sel_rdm =  1'b0;
                            dpath_ctrl_o.ld_rdm  =  1'b1;
                            mem_ctrl_o.r_en      =  1'b1;
                        end
                        else if (t_i[5]) begin  // PC <- RDM; goto t0
                            dpath_ctrl_o.ld_pc   =  1'b1;
                            dpath_ctrl_o.goto_t0 =  1'b1;
                        end
                    end
                    else begin
                        if (t_i[3]) begin   // PC <- PC + 1; goto t0
                            dpath_ctrl_o.inc_pc  =  1'b1;
                            dpath_ctrl_o.goto_t0 =  1'b1;
                        end
                    end
                end

                INST_HLT: begin
                    if (t_i[3]) begin
                        dpath_ctrl_o.hlt =  1'b1;
                    end
                end
                default: begin
                    dpath_ctrl_o.goto_t0 = 1'b1; // Aborta a operação e reinicia a máquina
                    dpath_ctrl_o.hlt     = 1'b0;
                    dpath_ctrl_o.op_code = OP_PASS;
                end
            endcase
        end
    end
endmodule