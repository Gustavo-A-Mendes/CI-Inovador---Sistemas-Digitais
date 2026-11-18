`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2026 02:24:20 PM
// Design Name: 
// Module Name: mem_vivado
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


module mem_vivado (
    input  logic                clk_i,
    
    ctrl_mem_if.slave           ctrl_mem_bus_i,     // (input control_sgn)
    dpath_mem_if.slave          dpath_mem_bus_i     // (input dpath_data, output mem_data)
);
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
    logic [7:0] addr, din;
//    logic spo_interno;
    

    // FIOS INTERFACE DPATH-MEM: Entrada de Dados   (MEM <- Datapath):
    assign addr   = `DPATH_IN.rem_q;
    assign din    = `DPATH_IN.rdm_q;
    
    // A BRAM precisa estar habilitada (ena = 1) sempre que houver leitura OU escrita
    logic   [7:0]   dout_bram;
    logic           mem_enable;
    
    assign mem_enable = `CTRL_IN.r_en | `CTRL_IN.w_en;

    // Instância do IP Block Memory Generator
    blk_mem_gen_0 bram (
        .clka  (~clk_i),
        .ena   (mem_enable),       // Habilita a BRAM para ler ou escrever
        .wea   (`CTRL_IN.w_en),    // 1 = Escrita | 0 = Leitura
        .addra (addr),
        .dina  (din),
        .douta (dout_bram)
    );
    
    // A saída já é registrada internamente pela BRAM
    assign `MEM_OUT.mem_q = dout_bram;
    
    `undef CTRL_IN
    `undef DPATH_IN
    `undef MEM_OUT
endmodule
