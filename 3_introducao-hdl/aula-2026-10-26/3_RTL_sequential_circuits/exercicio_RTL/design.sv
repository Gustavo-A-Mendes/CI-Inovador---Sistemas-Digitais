module top_level(
    input   wire clk,
    input   wire reset,
    input   wire up_down,
    input   wire lr,
    input   wire sel,
    input   wire [7:0] data_in,
    output  wire [6:0] display [1:0]
  );

  wire [7:0] count, reg_lr_out, add_out, sub_out, mux_out, reg_mux_out, bcd_7seg [1:0];
  wire [6:0] reg_7seg_out [1:0];

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
  mux m0(
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

  assign display[0] = reg_7seg_out[0];
  assign display[1] = reg_7seg_out[1];
endmodule

// Contador Up-Down de 8bits, com reset síncrono:
module counter8_up_down (
    input wire clk,
    input wire reset,
    input wire up_down,
    output reg [7:0] count
  );

  always @(posedge clk) begin
    if (reset)          count <= 8'b0;
    else if (up_down)   count <= count + 1'b1;
    else                count <= count - 1'b1;
  end
endmodule

// Registrador de 8bits, com reset síncrono e sinal de load:
module reg8_lr (
    input wire clk,
    input wire reset,
    input wire lr,
    input wire [7:0] d,
    output reg [7:0] q
  );

  always @(posedge clk) begin
    if (reset)          q <= 8'b0;
    else if (lr)        q <= d;
    else                q <= q; // Implícito, não é obrigatório
  end
endmodule

// Registrador de 8bits, com reset síncrono:
module reg8 (
    input wire clk,
    input wire reset,
    input wire [7:0] d,
    output reg [7:0] q
  );

  always @(posedge clk) begin
    if (reset)          q <= 8'b0;
    else                q <= d;
  end
endmodule

// Somador de 8bits, sem Carry-out e Carry-in:
module add (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] q
  );

  assign q = a + b;
endmodule

// Subtrador de 8bits:
module sub (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] q
  );

  assign q = a - b;
endmodule

// MUX de 8bits:
module mux (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire sel,
    output wire [7:0] q
  );

  assign q = (sel == 1'b0) ? a : b;
endmodule

// Conversor de Nibble (sinal de 4bits) p/ 8bit, para display de 7segmentos:
module nibble_to_7seg (
    input wire [3:0] nibble,
    output wire [6:0] seg_7
  );
  
  /*
      ---- A ----
      |         |
      F         B
      |         |
      ---- G ----
      |         |
      E         C
      |         |
      ---- D ----

          gfe_dcba
      8'b0000_0000

  
  */

  assign seg_7 =  (nibble == 4'b0000) ? 7'b011_1111 // 8'b0111_1110 // 0
                : (nibble == 4'b0001) ? 7'b000_0110 // 8'b0011_0000 // 1
                : (nibble == 4'b0010) ? 7'b101_1011 // 8'b0110_1101 // 2
                : (nibble == 4'b0011) ? 7'b100_1111 // 8'b0111_1001 // 3
                : (nibble == 4'b0100) ? 7'b110_0110 // 8'b0011_0011 // 4
                : (nibble == 4'b0101) ? 7'b110_1101 // 8'b0101_1011 // 5
                : (nibble == 4'b0110) ? 7'b111_1101 // 8'b0101_1111 // 6
                : (nibble == 4'b0111) ? 7'b000_0111 // 8'b0111_0000 // 7
                : (nibble == 4'b1000) ? 7'b111_1111 // 8'b0111_1111 // 8
                : (nibble == 4'b1001) ? 7'b110_1111 // 8'b0111_1011 // 9
                : (nibble == 4'b1010) ? 7'b111_0111 // 8'b0111_0111 // A
                : (nibble == 4'b1011) ? 7'b111_1100 // 8'b0001_1111 // b
                : (nibble == 4'b1100) ? 7'b011_1001 // 8'b0100_1110 // C
                : (nibble == 4'b1101) ? 7'b101_1110 // 8'b0011_1101 // d
                : (nibble == 4'b1110) ? 7'b111_1001 // 8'b0100_1111 // E
                : (nibble == 4'b1111) ? 7'b111_0001 // 8'b0100_0111 // F
                                      : 7'b000_0000;  // default
endmodule