interface ctrl_mem_if;
    import neander_pkg::*;
    ctrl_mem_t ctrl_sgn;     // fios para o sinais de controle da memória

    modport master ( output ctrl_sgn );
    modport slave ( input ctrl_sgn );
endinterface //mem_ctrl_if