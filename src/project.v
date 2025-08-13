/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
  );

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

  wire [3:0] address = uio_in[7:4]; // メモリのアドレス
  wire [3:0] opcode_in = ui_in[3:0]; // メモリへのオペコード入力
  wire [3:0] immediate_in = uio_in[3:0]; // メモリへの即値入力
  wire mem_write = ~ui_in[6]; // メモリへの書き込み信号（反転）

  wire [3:0] opcode_out;// メモリからのオペコード出力
  wire [3:0] immediate_out; // メモリからの即値出力

  assign uo_out[3:0] = opcode_out;
  assign uo_out[7:4] = immediate_out;

  Memory memory(
           .address(address),
           .opcode_in(opcode_in),
           .immediate_in(immediate_in),
           .opcode_out(opcode_out),
           .immediate_out(immediate_out),
           .write(mem_write),
           .clk(clk),
           .rst_n(rst_n)
         );

endmodule
