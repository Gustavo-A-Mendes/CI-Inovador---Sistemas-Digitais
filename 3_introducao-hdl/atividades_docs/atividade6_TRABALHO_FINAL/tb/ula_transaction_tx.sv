import neander_pkg::*;

class ula_transaction_tx;
    rand    logic       [7:0]   x_i,
    rand    logic       [7:0]   y_i,
    rand    ula_op_t            opcode_i,

    // constraint que restringe os opcodes válidos:
    constraint c_opcode_validos {
        opcode_i inside {
            OP_ADD, 
            OP_AND,
            OP_OR,
            OP_NOT,
            OP_PASS,
        };
    }

    // constraint para evitar falso Z
    constraint c_previne_falso_z {
        (opcode_i == OP_PASS) -> (y_i != 8'h0);
    }
endclass //ula_transaction