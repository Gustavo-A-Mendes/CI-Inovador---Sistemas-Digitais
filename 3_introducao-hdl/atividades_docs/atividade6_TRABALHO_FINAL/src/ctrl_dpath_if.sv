interface ctrl_dpath_if;
    import neander_pkg::*;
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