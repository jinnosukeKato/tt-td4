/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_td4 (
    input  reg [7:0] ui_in,    // Dedicated inputs
    output reg [7:0] uo_out,   // Dedicated outputs
    input  reg [7:0] uio_in,   // IOs: Input path
    output reg [7:0] uio_out,  // IOs: Output path
    output reg [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
  );

  // 未使用端子の接続（使わない入力ビットを潰す）
  wire _unused = &{ena, ui_in[5:4], 1'b0};

  // memory in
  reg [3:0] mem_address; // メモリのアクセス先アドレス
  wire [3:0] opcode_in; // メモリへのオペコード入力
  wire [3:0] immediate_in; // メモリへの即値入力
  wire mem_write; // メモリへの書き込み信号（反転）

  // memory out
  wire [3:0] opcode_out;// メモリからのオペコード出力
  wire [3:0] immediate_out; // メモリからの即値出力

  // 出力を内部信号に接続（最適化で消されないように可視化）
  // RegA を下位 4bit、RegB を上位 4bit に出力
  // 双方向ポートは uio[7] のみ Carry を出す例。その他は入力のまま。
  wire [3:0] io_input;
  wire [3:0] register_A;
  wire [3:0] register_B;
  wire [3:0] register_out;
  wire [3:0] pc;
  wire       carry;

  // モード関連
  reg is_read_mode;
  reg is_load_mode;
  assign is_read_mode = ui_in[6];
  assign is_load_mode = ui_in[7];
  assign mem_write = ~is_read_mode & is_load_mode;

  // 各モジュールへの入力
  assign opcode_in = ui_in[3:0];
  assign io_input = ui_in[3:0];
  assign immediate_in = uio_in[3:0];

  CPU cpu(
        .opcode(opcode_out),
        .immediate(immediate_out),
        .io_input(io_input),
        .regA_o(register_A),
        .regB_o(register_B),
        .pc_out(pc),
        .regOut(register_out),
        .carry(carry),
        .clk(clk),
        .rst_n(rst_n)
      );

  Memory memory(
           .address(mem_address),
           .opcode_in(opcode_in),
           .immediate_in(immediate_in),
           .opcode_out(opcode_out),
           .immediate_out(immediate_out),
           .write(mem_write),
           .clk(clk),
           .rst_n(rst_n)
         );

  // 各モードでの接続先の選択
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      uio_out[6:4] <= 0;
    end
    else if (is_load_mode & is_read_mode)
    begin
      // read mode
      uo_out[3:0] <= opcode_out;
      uo_out[7:4] <= immediate_out;
      mem_address <= uio_in[7:4];
    end
    else if (is_load_mode)
    begin
      // load mode
      mem_address <= uio_in[7:4];
    end
    else
    begin
      // execution mode
      uio_oe <= 8'hFF; // uioを全ピンoutputに設定
      uio_out[3:0] <= register_out;
      uio_out[7] <= carry;
      uo_out <= {register_A, register_B};
      mem_address <= pc;
      uio_oe <= 0; // uioを全ピンinputに設定
    end
  end

endmodule
