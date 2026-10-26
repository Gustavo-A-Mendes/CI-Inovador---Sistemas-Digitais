module up_down_counter(
    input i_clk,
    input i_rst,
    input [1:0] i_sel,
    input [2:0] i_d,
    output reg [2:0] o_q
);

    always @(posedge i_clk)
    begin
        if (i_rst) o_q=0;
        else
        case(i_sel)
        2'b00: o_q<=i_d; //carga paralela
        2'b01: o_q<=o_q+1; //up
        2'b10: o_q<=o_q-1; //down
        2'b11: o_q<=o_q; 
        default: o_q<=o_q;
        endcase

    end
endmodule