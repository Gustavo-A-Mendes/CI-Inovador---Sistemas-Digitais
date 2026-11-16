interface dpath_mem_if;
    import neander_pkg::*;
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