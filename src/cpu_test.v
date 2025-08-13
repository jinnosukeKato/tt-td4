`default_nettype none

module tt_um_cpu_test(
    input  reg [7:0] ui_in,    // Dedicated inputs
    output reg [7:0] uo_out,   // Dedicated outputs
    input  reg [7:0] uio_in,   // IOs: Input path
    output reg [7:0] uio_out,  // IOs: Output path
    output reg [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
  );

  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, rst_n, 1'b0};

  always @(negedge rst_n)
  begin
    uo_out[3:0] <= 4'b0;
  end

  wire [3:0] regA;
  wire [3:0] regB;
  wire carry;
  wire [3:0] pc_wire;
  CPU cpu(
        .opcode(ui_in[3:0]),
        .immediate(ui_in[7:4]),
        .regA_i(4'b0),
        .regB_i(4'b0),
        .regA_o(regA),
        .regB_o(regB),
        .pc(pc_wire),
        .regOut(uo_out[7:4]),
        .clk(clk),
        .carry(carry)
      );
endmodule
