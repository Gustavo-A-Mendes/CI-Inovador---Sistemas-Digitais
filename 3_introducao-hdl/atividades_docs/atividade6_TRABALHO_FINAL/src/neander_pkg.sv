package neander_pkg
    typedef enum logic [2:0] { 
        OP_ADD     = 3'b000,
        OP_AND     = 3'b001,
        OP_OR      = 3'b010,
        OP_NOT     = 3'b011,
        OP_PASS    = 3'b100
    } ula_op_t;

    typedef enum logic [3:0] { 
        INST_NOP    =   4'b0000,
        INST_STA    =   4'b0001,
        INST_LDA    =   4'b0010,
        INST_ADD    =   4'b0011,
        INST_OR     =   4'b0100,
        INST_AND    =   4'b0101,
        INST_NOT    =   4'b0110,
        INST_JMP    =   4'b1000,
        INST_JN     =   4'b1001,
        INST_JZ     =   4'b1010,
        INST_HLT    =   4'b1111
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