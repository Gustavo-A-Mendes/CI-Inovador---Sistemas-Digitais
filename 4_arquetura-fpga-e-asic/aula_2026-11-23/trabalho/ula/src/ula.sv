module ula (
    input   logic unsigned  [7:0]   a_i,    // Primeiro operando
    input   logic unsigned  [7:0]   b_i,    // Segundo operando
    input   logic                   m_i,    // Modo: 1 = lógico; 0 = aritmético
    input   logic           [2:0]   s_i,    // Seleção de operação
    output  logic           [7:0]   f_o     // Resultado
);
    
    typedef enum logic [2:0] { 
        OP_0    =   3'd0,
        OP_1    =   3'd1,
        OP_2    =   3'd2,
        OP_3    =   3'd3,
        OP_4    =   3'd4,
        OP_5    =   3'd5,
        OP_6    =   3'd6,
        OP_7    =   3'd7
    } ula_op_t;
    
    always_comb begin
        f_o = 8'd0;
        case(ula_op_t'(s_i))
            OP_0: begin
                if (m_i)    f_o = ( ~a_i );             // (M=1) -> not(A);
                else        f_o = ( a_i + b_i );        // (M=0) -> A + B
            end  
            OP_1: begin
                if (m_i)    f_o = ( ~(a_i | b_i) );     // (M=1) -> not(A or B);
                else        f_o = ( a_i - b_i );        // (M=0) -> A - B
            end  
            OP_2: begin
                if (m_i)    f_o = ( ~(a_i & b_i) );     // (M=1) -> not(A and B);
                else        f_o = ( a_i * b_i );        // (M=0) -> A * B
            end  
            OP_3: begin
                if (m_i)    f_o = ( ~(a_i ^ b_i) );     // (M=1) -> not(A xor B);
                else begin                              // (M=0) -> A / B
                    if (b_i == 8'd0)    // Tratativa para divisão por ZERO
                        f_o = 8'hFF;
                    else
                        f_o = ( a_i / b_i );
                end       
            end  
            OP_4: begin
                if (m_i)    f_o = ( a_i & b_i );        // (M=1) -> (A and B);
                else        f_o = ( a_i - 8'd1 );          // (M=0) -> A - 1
            end  
            OP_5: begin
                if (m_i)    f_o = ( a_i | b_i );        // (M=1) -> (A or B);
                else        f_o = ( b_i - 8'd1 );          // (M=0) -> B - 1
            end  
            OP_6: begin
                if (m_i)    f_o = ( a_i ^ b_i );        // (M=1) -> (A xor B);
                else        f_o = ( a_i + ~b_i );       // (M=0) -> A + not(B)
            end  
            OP_7: begin
                if (m_i)    f_o = ( ~b_i );             // (M=1) -> not(B);
                else        f_o = ( ~a_i + b_i );       // (M=0) -> not(A) + B
            end  
        endcase
    end
endmodule
