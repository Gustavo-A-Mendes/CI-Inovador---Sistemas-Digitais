`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 12:25:56 PM
// Design Name: 
// Module Name: design
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// ======================================================================
// ======================================================================
//
//                              PACKAGES
//
// ======================================================================
// ======================================================================
package neander_pkg;
    typedef enum logic [2:0] { 
        OP_ADD  =   3'b000,
        OP_AND  =   3'b001,
        OP_OR   =   3'b010,
        OP_NOT  =   3'b011,
        OP_PASS =   3'b100,
        OP_SUB  =   3'b101
    } ula_op_t;

    typedef enum logic [3:0] { 
        INST_NOP    =   4'b0000,    // 8'h00
        INST_STA    =   4'b0001,    // 8'h10
        INST_LDA    =   4'b0010,    // 8'h20
        INST_ADD    =   4'b0011,    // 8'h30
        INST_OR     =   4'b0100,    // 8'h40
        INST_AND    =   4'b0101,    // 8'h50
        INST_NOT    =   4'b0110,    // 8'h60
        INST_SUB    =   4'b0111,    // 8'h70
        INST_JMP    =   4'b1000,    // 8'h80
        INST_JN     =   4'b1001,    // 8'h90
        INST_JZ     =   4'b1010,    // 8'hA0
        INST_HLT    =   4'b1111     // 8'hF0
    } instructions_t;
    
    typedef struct packed {
        logic           sel_rem;    // seletor mux MPX para entrada REM
        logic           ld_rem;     // carga REM
        logic           ld_pc;      // carga PC
        logic           inc_pc;     // incrementa PC
        logic           ld_ri;      // carga RI
        logic           sel_rdm;    // seletor entrada RDM
        logic           ld_rdm;     // carga RDM
        logic           ld_ac;      // carga AC
        logic           ld_nz;      // carga NZ
        logic           goto_t0;    // goto t0, temporizador
        ula_op_t        op_code;    // código das operações da ULA
        logic           hlt;        // Para o processamento (halt)
    } ctrl_dpath_t;

    typedef struct packed {
        logic   [1:0]   nz;         // sinais de status N e Z
        instructions_t  inst_code;  // código das instruções do NEANDER
    } dpath_ctrl_t;

    typedef struct packed {
        logic           w_en;       // habilita escrita memória
        logic           r_en;       // habilita leitura memória
    } ctrl_mem_t;
    
    typedef struct packed {
        logic   [7:0]   rdm_q;      // saída do RDM
        logic   [7:0]   rem_q;      // saída do REM    
    } dpath_mem_t;

    typedef struct packed {
        logic   [7:0]   mem_q;
    } mem_dpath_t;
endpackage

import neander_pkg::*;
// ======================================================================
// ======================================================================
//
//                              INTERFACES
//
// ======================================================================
// ======================================================================

// CTRL <-> DATAPATH:
interface ctrl_dpath_if;
    ctrl_dpath_t    ctrl_sgn;   // fios do sinal de controle
    dpath_ctrl_t    status_sgn; // fios do sinal de status

    /*
        MASTER: Direção dos sinais do módulo que "comanda"
        SLAVE:  Direção dos sinais no módulo que "obedece"
    */

    // Controle: GERA os sinais de controle e ESCUTA os sinais de status do DATAPATH
    modport master ( 
        output ctrl_sgn,
        input status_sgn
    );

    // Datapath: GERA os sinais de status e ESCUTA os sinais de controle do CONTROLE
    modport slave ( 
        input ctrl_sgn,
        output status_sgn
    );
endinterface //datapath_if

// CTRL  -> MEMORIA:
interface ctrl_mem_if;
    ctrl_mem_t ctrl_sgn;     // fios para o sinais de controle da memória

    modport master ( output ctrl_sgn );
    modport slave ( input ctrl_sgn );
endinterface //mem_ctrl_if

// DATAPATH <-> MEMORIA:
interface dpath_mem_if;
    dpath_mem_t     dpath_data;   // fios do sinal de status
    mem_dpath_t     mem_data;       // fios de dados

    /*
        MASTER: Direção dos sinais do módulo que "comanda"
        SLAVE:  Direção dos sinais no módulo que "obedece"
    */

    // Controle: GERA os sinais de controle e ESCUTA os sinais de status do DATAPATH
    modport master ( 
        output dpath_data,
        input mem_data
    );

    // Datapath: GERA os sinais de status e ESCUTA os sinais de controle do CONTROLE
    modport slave ( 
        input dpath_data,
        output mem_data
    );
endinterface //datapath_if

// ======================================================================
// ======================================================================
//
//                              TOP_LEVEL
//
// ======================================================================
// ======================================================================
module neander (
    input   logic           clk_i,
    input   logic           rst_n_i,
    output  logic           hlt_o,
    output  logic   [7:0]   ac_o,
    output  logic   [7:0]   pc_o,
    output  logic   [7:0]   rem_o,
    output  logic   [7:0]   rdm_o,
    output  logic   [7:0]   ri_o,
    output  logic   [7:0]   mem_out_o,
    output  logic           mem_wen_o,
    output  logic           mem_ren_o,
    output  logic   [7:0]   t_o,
    output  logic   [3:0]   inst_code_o,
    output  logic   [2:0]   op_code_o
);
    
    // Instanciando Interfaces:
    ctrl_dpath_if   ctrl_dpath_bus();
    ctrl_mem_if     ctrl_mem_bus();
    dpath_mem_if    dpath_mem_bus();

    // ======================================================================
    //                          INSTANCIANDO MÓDULOS
    // ======================================================================

    // Controle:
    neander_control ND_CTRL0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .ctrl_dpath_bus_i(ctrl_dpath_bus.master),   // Conecta o Controle no MASTER
        .ctrl_mem_bus_i(ctrl_mem_bus.master),       // Conecta o Controle no MASTER
        .t_o(t_o)
    );

    // Datapath:
    neander_datapath ND_DPATH0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .ctrl_dpath_bus_i(ctrl_dpath_bus.slave),    // Conecta o Controle no SLAVE
        .dpath_mem_bus_i(dpath_mem_bus.master),     // Conecta o Controle no MASTER
        .pc_o(pc_o),
        .ac_o(ac_o),
        .ri_o(ri_o)
    );

    // BRAM:
    neander_mem ND_MEM0(
//    mem_vivado ND_MEM0(
        .clk_i(clk_i),
        .ctrl_mem_bus_i(ctrl_mem_bus.slave),        // Conecta o Controle no SLAVE
        .dpath_mem_bus_i(dpath_mem_bus.slave)       // Conecta o Controle no SLAVE
    );

    assign hlt_o        = ctrl_dpath_bus.ctrl_sgn.hlt;
    assign op_code_o    = ula_op_t'(ctrl_dpath_bus.ctrl_sgn.op_code);
    assign inst_code_o  = instructions_t'(ctrl_dpath_bus.status_sgn.inst_code);
    assign rem_o        = dpath_mem_bus.dpath_data.rem_q;
    assign rdm_o        = dpath_mem_bus.dpath_data.rdm_q;
    assign mem_out_o    = dpath_mem_bus.mem_data.mem_q;
    assign mem_wen_o    = ctrl_mem_bus.ctrl_sgn.w_en;
    assign mem_ren_o    = ctrl_mem_bus.ctrl_sgn.r_en;
endmodule

// ======================================================================
// ======================================================================
//
//                  DECLARAÇÃO CONTROLE | DATAPATH | MEMORIA
//
// ======================================================================
// ======================================================================

// CONTROLE:
module neander_control (
    input   logic               clk_i,
    input   logic               rst_n_i,
    ctrl_dpath_if.master        ctrl_dpath_bus_i,   // (input status_sgn, output ctrl_sgn)
    ctrl_mem_if.master          ctrl_mem_bus_i,     // (output ctrl_sgn)

    // Saída de sinais internos dos registrador(es):
    output  logic       [7:0]   t_o
);

    // ======================================================================
    //                        MACROS DE ROTEAMENTO
    // ======================================================================
    `define STATUS_IN  ctrl_dpath_bus_i.status_sgn
    `define CTRL_OUT   ctrl_dpath_bus_i.ctrl_sgn
    `define MEM_OUT    ctrl_mem_bus_i.ctrl_sgn

    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================
    
    // FIOS CONTROL:
    logic [7:0] t_q;

    // ======================================================================
    //                          INSTANCIANDO MÓDULOS
    // ======================================================================

    // Gerador tempo:
    gerador_tempo GT0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .goto_t0_i(`CTRL_OUT.goto_t0),
        .hlt_i(`CTRL_OUT.hlt),
        .t_q(t_q)
    );

    decod_instruncao DEC0(
        .inst_code_i(`STATUS_IN.inst_code),
        .nz_i(`STATUS_IN.nz),
        .t_i(t_q),
        .dpath_ctrl_o(`CTRL_OUT),
        .mem_ctrl_o(`MEM_OUT)
    );

    assign t_o = t_q;
    
    `undef STATUS_IN
    `undef CTRL_OUT
    `undef MEM_OUT
endmodule

// ======================================================================
// DATAPATH:
module neander_datapath (
    input   logic               clk_i,
    input   logic               rst_n_i,
    
    ctrl_dpath_if.slave         ctrl_dpath_bus_i,   // (input ctrl_sgn, output status_sgn)
    dpath_mem_if.master         dpath_mem_bus_i,    // (input mem_data, output dpath_data)
    
    // Saídas dos sinais internos de registradores:
    output  logic       [7:0]   pc_o,   
    output  logic       [7:0]   ac_o,   
    output  logic       [7:0]   ri_o   
);
    // ======================================================================
    //                        MACROS DE ROTEAMENTO
    // ======================================================================
    `define CTRL_IN     ctrl_dpath_bus_i.ctrl_sgn
    `define STATUS_OUT  ctrl_dpath_bus_i.status_sgn
    `define MEM_IN      dpath_mem_bus_i.mem_data
    `define DPATH_OUT   dpath_mem_bus_i.dpath_data

    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================
    
    // FIOS DATAPATH:
    logic [7:0] pc_q, rdm_q, ac_q, ri_q;    // Fios sequenciais
    logic [7:0] mpx_out_w, ula_out_w;                    // Fios combinacionais
    logic [1:0] nz_w;

    // FIOS INTERFACE CTRL-DPATH: Sinais de Status  (Datapath -> Controle)
    assign `STATUS_OUT.inst_code =  instructions_t'(ri_q[7:4]);

    // FIOS INTERFACE DPATH-MEM: Saídas de Dados (MEM <- Datapath):
    assign `DPATH_OUT.rdm_q =   rdm_q;

    // ======================================================================
    //                          INSTANCIANDO MÓDULOS
    // ======================================================================
    
    // PC:
    pc PC0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .ld_pc_i(`CTRL_IN.ld_pc),
        .inc_pc_i(`CTRL_IN.inc_pc),
        .pc_d(rdm_q),
        .pc_q(pc_q)
    );

    // REM - Reg. de Endereço da Memória:
    assign mpx_out_w = (`CTRL_IN.sel_rem) ? rdm_q : pc_q;
    rem REM0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .load_i(`CTRL_IN.ld_rem),
        .rem_d(mpx_out_w),
        .rem_q(`DPATH_OUT.rem_q)
    );

    // RDM - Reg. de Dados da Memória:
    rdm RDM0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .rdm_ac_i(ac_q),
        .rdm_mem_i(`MEM_IN.mem_q),
        .sel_i(`CTRL_IN.sel_rdm),
        .load_i(`CTRL_IN.ld_rdm),
        .rdm_q(rdm_q)
    );

    // AC - Acumulador:
    ac AC0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .load_i(`CTRL_IN.ld_ac),
        .ac_d(ula_out_w),
        .ac_q(ac_q)
    );

    // RI - Reg. de Instrução:
    ri RI0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .load_i(`CTRL_IN.ld_ri),
        .ri_d(rdm_q),
        .ri_q(ri_q)
    );

    // ULA - Unidade Lógica Aritmética:
    ula ULA0(
        .x_i(ac_q),
        .y_i(rdm_q),
        .opcode_i(`CTRL_IN.op_code),
        .ula_o(ula_out_w),
        .nz_o(nz_w)
    );

    // NZ - Registrador de Sinais de Status
    nz NZ0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .load_i(`CTRL_IN.ld_nz),
        .nz_d(nz_w),
        .nz_q(`STATUS_OUT.nz)
    );
    
    assign pc_o = pc_q;
    assign ac_o = ac_q;
    assign ri_o = ri_q;
    
    `undef CTRL_IN
    `undef STATUS_OUT
    `undef MEM_IN
    `undef DPATH_OUT
endmodule

// ======================================================================
// MEMORIA:
module neander_mem (
    input   logic           clk_i,
    
    ctrl_mem_if.slave       ctrl_mem_bus_i,     // (input control_sgn)
    dpath_mem_if.slave      dpath_mem_bus_i     // (input dpath_data, output mem_data)
);  
    localparam MEM_FILE = "program_sub_matrix.mem";

    // ======================================================================
    //                        MACROS DE ROTEAMENTO
    // ======================================================================
    `define CTRL_IN    ctrl_mem_bus_i.ctrl_sgn
    `define DPATH_IN  dpath_mem_bus_i.dpath_data
    `define MEM_OUT    dpath_mem_bus_i.mem_data
    
    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================

    // FIOS MEMORIA:
    logic [7:0] addr_w, wdata_d;
    logic [7:0] rdata_q;


    // FIOS INTERFACE DPATH-MEM: Entrada de Dados   (MEM <- Datapath):
    assign addr_w   = `DPATH_IN.rem_q;
    assign wdata_d  = `DPATH_IN.rdm_q;


    // ======================================================================
    //                          INSTANCIANDO MEMÓRIA
    // ======================================================================
    
    // Instancia a memória BRAM:
    // logic [7:0] bram [0:255];
    (* ram_style = "block" *) logic [7:0] bram [0:255];
    
    initial begin
        $readmemh(MEM_FILE, bram);
    end
    // ======================================================================
    //                            DEFININDO LÓGICA
    // ======================================================================
    always_ff @ ( negedge clk_i ) begin
        if (`CTRL_IN.w_en)    bram[addr_w] <= wdata_d;
        else if (`CTRL_IN.r_en)    rdata_q <= bram[addr_w];
    end 

    assign `MEM_OUT.mem_q = rdata_q;

    `undef CTRL_IN
    `undef DPATH_IN
    `undef MEM_OUT
endmodule

// ======================================================================
// ======================================================================
//
//                  DECLARAÇÃO MODULOS DE DEPENDÊNCIA
//
// ======================================================================
// ======================================================================

// DECODIFICADOR DE INSTRUÇÃO:
module decod_instruncao (
    input   instructions_t  inst_code_i,
    input   logic   [1:0]   nz_i,
    input   logic   [7:0]   t_i,        // Tempo (Vetor One-Hot t0 a t7)
    output  ctrl_dpath_t    dpath_ctrl_o,
    output  ctrl_mem_t      mem_ctrl_o
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

// ======================================================================
// TEMPORIZADOR:
module gerador_tempo (
    input   logic           clk_i,
    input   logic           rst_n_i,    // Reset global
    input   logic           goto_t0_i,  // Sinal de controle
    input   logic           hlt_i,
    output  logic   [7:0]   t_q         // Vetor One-Hot de tempos (t0 a t7)
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)               t_q <= 8'b0000_0001;    // Reset global: força tempo para t0
        else if (goto_t0_i)         t_q <= 8'b0000_0001;    // Retorno ao t0
        else begin 
            if (t_q[7])             t_q <= 8'b0000_0001;    // Se 1 estiver no final (t7), move o 1 de volta para o início (t0), 
            else if (!hlt_i)        t_q <= t_q << 1;        // desloca para direita
            // se hlt_i == 1 => Retençao do estado
        end
    end
endmodule

// ======================================================================
// AC:
module ac (
    input   logic           clk_i,
    input   logic           rst_n_i,
    input   logic           load_i,
    input   logic   [7:0]   ac_d,
    output  logic   [7:0]   ac_q
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       ac_q <= 8'h00;
        else if (load_i)    ac_q <= ac_d;    
    end
endmodule

// ======================================================================
// PC:
module pc (
    input   logic           clk_i,
    input   logic           rst_n_i,    // Reset global
    input   logic           ld_pc_i,    // Habilita carga paralela
    input   logic           inc_pc_i,   // Habilita incremento
    input   logic   [7:0]   pc_d,       // Entrada paralela
    output  logic   [7:0]   pc_q        // Saída paralela do registrado
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       pc_q <= 8'h00;          // Reset global
        else if (ld_pc_i)   pc_q <= pc_d;           // Carga paralela
        else if (inc_pc_i)  pc_q <= pc_q + 1'b1;    // Incremento
    end
endmodule

// ======================================================================
// REM:
module rem (
    input   logic           clk_i,
    input   logic           rst_n_i,
    input   logic           load_i,
    input   logic   [7:0]   rem_d,
    output  logic   [7:0]   rem_q
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       rem_q <= 8'h00;
        else if (load_i)    rem_q <= rem_d;    
    end
endmodule

// ======================================================================
// RDM:
module rdm (
    input   logic           clk_i,
    input   logic           rst_n_i,    // Reset global

    input   logic   [7:0]   rdm_ac_i,   // Entrada do registrador
    input   logic   [7:0]   rdm_mem_i,  // Entrada vinda da memória

    input   logic           sel_i,      // Seleciona entrada. 0 -> MEM; 1 -> AC
    input   logic           load_i,     // Habilita carga RDM

    output  logic   [7:0]   rdm_q       // Saída do registrador
);

    // Mulplexador na entrada do RDM:
    logic [7:0] rdm_d;
    assign rdm_d = (sel_i) ?  rdm_ac_i : rdm_mem_i;

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       rdm_q <= 8'h00;     // Reset global
        else if (load_i)    rdm_q <= rdm_d;  // Carga de AC 
    end
endmodule

// ======================================================================
// RI:
module ri (
    input   logic           clk_i,
    input   logic           rst_n_i,
    input   logic           load_i,
    input   logic   [7:0]   ri_d,
    output  logic   [7:0]   ri_q
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       ri_q <= 8'h00;
        else if (load_i)    ri_q <= ri_d;    
    end
endmodule

// ======================================================================
// NZ:
module nz (
    input   logic           clk_i,
    input   logic           rst_n_i,
    input   logic           load_i,
    input   logic   [1:0]   nz_d,
    output  logic   [1:0]   nz_q
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       nz_q <= 2'b00;
        else if (load_i)    nz_q <= nz_d;    
    end
endmodule

// ======================================================================
// ULA:
module ula (
    input   logic       [7:0]   x_i,
    input   logic       [7:0]   y_i,
    input   ula_op_t            opcode_i,
    output  logic       [7:0]   ula_o,
    output  logic       [1:0]   nz_o
);
    // sinais internos para os sinais de condição:
    logic n, z;

    always_comb begin
        ula_o = 8'h00;  // Valor default

        unique case(opcode_i)
            OP_ADD  :   ula_o = x_i + y_i;
            OP_AND  :   ula_o = x_i & y_i;
            OP_OR   :   ula_o = x_i | y_i;
            OP_NOT  :   ula_o = ~x_i;
            OP_PASS :   ula_o = y_i;
            OP_SUB  :   ula_o = x_i - y_i;
            default :   ula_o = y_i;
        endcase

        n = ula_o[7];           // Em complemento de 2, o bit mais significativo é o bit de sinal
        z = (ula_o == 8'b0);    // Saída da ULA é igual a 0
    end

    assign nz_o = {n, z};
endmodule
