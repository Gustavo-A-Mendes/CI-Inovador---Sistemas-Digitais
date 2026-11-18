`timescale 1ns/1ps

import neander_pkg::*;

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