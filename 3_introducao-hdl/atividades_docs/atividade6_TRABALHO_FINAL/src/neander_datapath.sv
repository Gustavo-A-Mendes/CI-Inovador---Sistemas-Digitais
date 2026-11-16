`timescale 1ns/1ps

import neander_pkg::*;

module neander_datapath (
    input   logic               clk_i,
    input   logic               rst_n_i,
    
    ctrl_dpath_if.slave         ctrl_dpath_bus_i,   // (input ctrl_sgn, output datapath_sigh)
    dpath_mem_if.master         dpath_mem_bus_i     // (input mem_data, output datapath_sigh)
);
    
    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================
    
    // FIOS DATAPATH:
    logic [7:0] pc_q, rem_q, rdm_q, ac_q, ri_q, nz_q;    // Fios sequenciais
    logic [7:0] mpx_out_w, ula_out_w, nz_w;              // Fios combinacionais

    logic r_en_w, w_en_w, goto_t0_w;

    // FIOS INTERFACE CTRL-DPATH: Sinais de controle (Datapath <- Control)
    ctrl_dpath_t controle;      // atalho para a struct ctrl_sgn
    assign controle = ctrl_dpath_bus_i.ctrl_sgn;

    // FIOS INTERFACE CTRL-DPATH: Sinais de Status  (Datapath -> Controle)
    dpath_ctrl_t dpath2ctrl;    // atalho para a struct status_sgn
    assign dpath2ctrl = ctrl_dpath_bus_i.status_sgn;
    
    // Atribuição com '{...} obriga o compilador verificar se todos os campos da struct foram preenchidos
    assign dpath2ctrl = '{
        nz          :   nz_q,
        inst_code   :   instructions_t'(ri_q[7:4]),
    };
    
    // FIOS INTERFACE DPATH-MEM: Entrada de Dados (Datapath <- MEM):
    dpath_mem_t memoria;        // atalho para a struct mem_data
    assign memoria = dpath_mem_bus_i.mem_data;

    // FIOS INTERFACE DPATH-MEM: Saídas de Dados (MEM <- Datapath):
    mem_dpath_t dpath2mem;      // atalho para a struct dpath_data
    assign dpath2mem = dpath_mem_bus_i.dpath_data;

    assign dpath_mem_bus_i.dpath_data = '{
        rem_q   : rem_q,
        rdm_q   : rdm_q,
    };

    // ======================================================================
    //                          INSTANCIANDO MÓDULOS
    // ======================================================================
    
    // PC:
    pc PC0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .ld_pc_i(controle.ld_pc),
        .inc_pc_i(controle.inc_pc),
        .pc_i(rdm_q),
        .pc_o(pc_q)
    );

    // REM - Reg. de Endereço da Memória:
    assign mpx_out_w = (controle.sel_mpx) ? rdm_q : pc_q;
    rem REM0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .load_i(controle.ld_rem),
        .rem_d(mpx_out_w),
        .rem_q(rem_q)
    );

    // RDM - Reg. de Dados da Memória:
    rdm RDM0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .rdm_ac_i(ac_q),
        .rda_mem_i(memoria.mem_q),
        .sel_i(controle.sel_rdm),
        .load_i(controle.ld_rdm),
        .rdm_q(rdm_q)
    );

    // AC - Acumulador:
    ac AC0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .load_i(controle.ld_ac),
        .ac_d(ula_out_w),
        .ac_q(ac_q)
    );

    // RI - Reg. de Instrução:
    ri RI0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .load_i(controle.ld_ri),
        .ri_d(rdm_q),
        .ri_q(ri_q)
    );

    // ULA - Unidade Lógica Aritmética:
    ula ULA0(
        .x_i(ac_q),
        .y_i(rdm_q),
        .op_code_i(controle.op_code),
        .ula_o(ula_out_w),
        .nz_o(nz_w)
    );

    // NZ - Registrador de Sinais de Status
    nz NZ0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .load_i(controle.ld_nz),
        .nz_d(nz_w),
        .nz_q(nz_q)
    );
    
endmodule