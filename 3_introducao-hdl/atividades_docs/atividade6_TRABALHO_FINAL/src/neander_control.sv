`timescale 1ns/1ps

import neander_pkg::*;

module neander_control (
    input   logic           clk_i,
    input   logic           rst_n_i,
    ctrl_dpath_if.master    ctrl_dpath_bus_i,   // (input status_sgn, output ctrl_sgn)
    ctrl_mem_if.master      ctrl_mem_bus_i     // (output ctrl_sgn)
);

    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================
    
    // FIOS CONTROL:
    logic [7:0] t;
    logic [2:0] t_num;

    // FIOS CONTROLE:
    logic sel_mpx_w, ld_rem_w, ld_pc_w, inc_pc_w, ld_ri_w, sel_rdm_w, ld_rdm_w, ld_ac_w, ld_nz_w, goto_t0_w;
    ula_op_t opcode_w;

    logic r_en_w, w_en_w;

    // FIOS INTERFACE CTRL-DPATH: Sinais de Status      (Controle <- Datapath)
    dpath_ctrl_t datapath;  // atalho para a struct status_sgn
    assign datapath = ctrl_dpath_bus_i.status_sgn;

    // FIOS INTERFACE CTRL-DPATH: Sinais de Controle    (Controle -> Datapath)
    dpath_ctrl_t controle;  // atalho para a struct status_sgn
    assign controle = ctrl_dpath_bus_i.ctrl_sgn;

    // Atribuição com '{...} obriga o compilador verificar se todos os campos da struct foram preenchidos
    assign controle = '{   
        sel_mpx :   sel_mpx_w,
        ld_rem  :   ld_rem_w,
        ld_pc   :   ld_pc_w,
        inc_pc  :   inc_pc_w,
        ld_ri   :   ld_ri_w,
        sel_rdm :   sel_rdm_w,
        ld_rdm  :   ld_rdm_w,
        ld_ac   :   ld_ac_w,
        ld_nz   :   ld_nz_w,
        goto_t0 :   goto_t0_w,
        opcode  :   opcode_w,
    };
    
    // FIOS INTERFACE CTRL-MEM: Sinais de Controle (Controle -> MEM)
    dpath_ctrl_t memoria;   // atalho para a struct ctrl_sgn
    assign memoria = ctrl_mem_bus_i.ctrl_sgn;

    assign memoria = '{
        w_en    :   w_en_w,
        r_en    :   r_en_w,
    }

    // ======================================================================
    //                          INSTANCIANDO MÓDULOS
    // ======================================================================
    
    // // Declarando matrizes de memórias, com tamanho da palavra e quantidade de linhas dinâmicas:
    // ctrl_dpath_t    rom_controle_dpath  [instructions_t'(0).first() : instructions_t'(0).last()][0:7];
    // ctrl_mem_t      rom_controle_mem    [instructions_t'(0).first() : instructions_t'(0).last()][0:7];

    // Gerador tempo:
    gerador_tempo gt0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .goto_t0_i(controle.goto_t0),
        .t_o(t),
        .t_num(t_num)
    );

    decod_instruncao dec0(
        .inst_code_i(datapath.inst_code),
        .nz_i(datapath.nz_i),
        .t_num_i(t_num),
        .dpath_ctrl_o(),
        .mem_ctrl_o()
    );
endmodule