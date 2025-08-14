/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_td4 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
  );

  // 出力を内部信号に接続（最適化で消されないように可視化）
  // RegA を下位 4bit、RegB を上位 4bit に出力
  // 双方向ポートは uio[7] のみ Carry を出す例。その他は入力のまま。
  wire [3:0] pc;
  wire [3:0] register_A;
  wire [3:0] register_B;
  wire [3:0] register_out;
  wire       carry;

  assign uo_out[3:0] = register_A;
  assign uo_out[7:4] = register_B;

  // 未使用入力群（ena, ui_in[7:4], uio_in[7:4]) を畳み込んで 1bit 出力し、シンクを作る
  wire unused_in_fold = ^{ena, ui_in[7:4], uio_in[7:4]};
  assign uio_out     = {carry, unused_in_fold, 6'b0};
  assign uio_oe      = 8'b1100_0000; // uio[7], uio[6] を出力、他は入力

  // memory in
  wire [3:0] opcode_in; // メモリへのオペコード入力
  wire [3:0] immediate_in; // メモリへの即値入力
  wire mem_write; // メモリへの書き込み信号（反転）

  assign opcode_in = ui_in[3:0];
  assign immediate_in = uio_in[3:0];
  assign mem_write = ~ui_in[6];

  // memory out
  wire [3:0] opcode_out;// メモリからのオペコード出力
  wire [3:0] immediate_out; // メモリからの即値出力

  // 未使用端子の接続（使わない入力ビットを潰す）
  wire _unused = &{ena, ui_in[5:4], ui_in[7], uio_in[7:4], 1'b0};

  CPU cpu(
        .opcode(opcode_out),
        .immediate(immediate_out),
        .regA_o(register_A),
        .regB_o(register_B),
        .pc_out(pc),
        .regOut(register_out),
        .carry(carry),
        .clk(clk),
        .rst_n(rst_n)
      );

  Memory memory(
           .address(pc),
           .opcode_in(opcode_in),
           .immediate_in(immediate_in),
           .opcode_out(opcode_out),
           .immediate_out(immediate_out),
           .write(mem_write),
           .clk(clk),
           .rst_n(rst_n)
         );

endmodule
