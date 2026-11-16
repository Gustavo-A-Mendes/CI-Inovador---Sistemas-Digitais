`timescale 1ns/1ps

import neander_pkg::*;

module neander_mem (
    input   logic           clk_i,
    
    ctrl_mem_if.slave       ctrl_mem_bus_i,     // (input control_sgn)
    dpath_mem_if.slave      dpath_mem_bus_i     // (input dpath_data, output mem_data)
);
    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================

    // FIOS MEMORIA:
    logic [7:0] addr_w, wdata_d, rdata_q;
    logic w_en_w, r_en_w;

    // FIOS INTERFACE CTRL-MEM: Sinais de Controle  (MEM <- Control)
    ctrl_mem_t controle;    // atalho para a struct ctrl_sgn
    assign controle = ctrl_mem_bus_i.ctrl_sgn;

    // FIOS INTERFACE DPATH-MEM: Entrada de Dados   (MEM <- Datapath):
    dpath_mem_t datapath;   // atalho para a struct dpath_data
    assign datapath = dpath_mem_bus_i.dpath_data;
    
    assign addr_w   = datapath.rem_q;
    assign wdata_d  = datapath.rdm_q;

    // FIOS INTERFACE DPATH-MEM: Saídas de Dados (MEM -> Datapath):
    mem_dpath_t memoria;    // atalho para a struct mem_data
    assign memoria = dpath_mem_bus_i.mem_data;
    
    assign memoria = '{
        mem_q   :   rdata_q,
    };

    // ======================================================================
    //                          INSTANCIANDO MEMÓRIA
    // ======================================================================
    
    // Instancia a memória SRAM:
    logic [7:0] sram [0:255];

    // ======================================================================
    //                            DEFININDO LÓGICA
    // ======================================================================
    always_ff @ ( posedge clk_i ) begin
        if (controle.w_en)    sram[addr_w] <= wdata_d;
    end 

    assign rdata_q = (controle.r_en) ? sram[addr_w] : 8'h00;
endmodule