`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2026 05:01:26 PM
// Design Name: 
// Module Name: design
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

module top_level (
    input   logic clk,
    input   logic reset,
    input   logic up_down,
    input   logic lr,
    input   logic sel,
    input   logic [7:0] data_in,
    output  logic [6:0] seg,
    output  logic [7:0] an
);

    logic [7:0] count, reg_lr_out, add_out, sub_out, mux_out, reg_mux_out; 
    logic [6:0] bcd_7seg [1:0];
    logic [6:0] reg_7seg_out [1:0];
    
    // Instâncias:
    
    // Contador:
    counter8_up_down c0(
        .clk(clk),
        .reset(reset), 
        .up_down(up_down), 
        .count(count)
    );
    
    // Registrador de entrada:
    reg8_lr rl0(
        .clk(clk),
        .reset(reset),
        .lr(lr),
        .d(data_in),
        .q(reg_lr_out)
    );
    
    // Somador:
    add a0(
        .a(count),
        .b(reg_lr_out),
        .q(add_out)
    );
    
    // Subtrador:
    sub s0(
        .a(count),
        .b(reg_lr_out),
        .q(sub_out)
    );
    
    // Multiplexador:
    mux2x1 m0(
        .a(add_out), 
        .b(sub_out), 
        .sel(sel), 
        .q(mux_out)
    );
    
    // Registrador da saída do mux:
    reg8 r0(
        .clk(clk),
        .reset(reset),
        .d(mux_out),
        .q(reg_mux_out)
    );
    
    // Conversores de Nibble p/ BCD, para display de 7segmentos:
    nibble_to_7seg n0(
        .nibble(reg_mux_out[3:0]),
        .seg_7(bcd_7seg[0])
    );
    
    nibble_to_7seg n1(
        .nibble(reg_mux_out[7:4]),
        .seg_7(bcd_7seg[1])
    );
    
    // Registradores do BCD:
    reg8 r1(
        .clk(clk),
        .reset(reset),
        .d(bcd_7seg[0]),
        .q(reg_7seg_out[0])
    );
    
    reg8 r2(
        .clk(clk),
        .reset(reset),
        .d(bcd_7seg[1]),
        .q(reg_7seg_out[1])
    );
    
    // ==========================================
    // LÓGICA DE MULTIPLEXAÇÃO DO DISPLAY
    // ==========================================
    
    logic digit_sel;
    display_active d_en(
        .clk(clk),
        .reset(reset),
        .digit_sel(digit_sel)
    );

    // Controlo dos Ânodos (Ativo em BAIXO: 0 liga, 1 desliga)
    assign an = (digit_sel == 1'b0) ? 8'b1111_1110 : // Liga apenas o dígito da direita
                                      8'b1111_1101 ; // Liga apenas o dígito da esquerda
    
    // Roteamento dos Segmentos 
    // O operador '~' (NOT) inverte os bits, pois o mostrador da placa acende com '0' e apaga com '1'
    assign seg = (digit_sel == 1'b0) ? ~reg_7seg_out[0] : 
                                       ~reg_7seg_out[1] ;
    
endmodule 
