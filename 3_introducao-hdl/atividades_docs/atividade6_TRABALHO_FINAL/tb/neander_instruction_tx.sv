import neander_pkg::*;

class neander_instruction_tx;
    rand    instructions_t          opcode_i;
    rand    logic           [7:0]   operando_i;

    // constrain de restrição de opcode:
    constraint c_opcode_valido {
        op_code_i inside {
            INST_NOP,
            INST_STA,
            INST_LDA,
            INST_ADD,
            INST_OR,
            INST_AND,
            INST_NOT,
            INST_JMP,
            INST_JN,
            INST_JZ,
            INST_HLT,
        }
    }

    // constrain de dependência causal:
    constraint c_enderecamento_memoria {
        // Se a instrução NÃO acessar operando de memória -> Instrução de 1 byte
        (opcode_i inside {INST_NOP, INST_NOT, INST_HLT}) 
        -> (operando_i == 8'h00);
        
        // Se a instrução ACESSAR operando de memória -> Instrução de 2 byte
        (opcode_i inside {INST_STA, INST_LDA, INST_ADD, INST_OR, INST_AND}) 
        -> (operando_i inside {[8'h80 : 8'hFF]});

        // Caso contrário
        // -> (operando_i inside {[8'h00 : 8'h7F]});
    }

    // Método para imprimir a transação no console de forma elegante:
    function void print();
        $display("--------------------------------");
        $display("Opcode Sorteado: %s", opcode_i.name());
        $display("Operando Sorteado: 8'h%h", operando_i);
        $display("--------------------------------");
    endfunction
endclass //neander_instruction_tx