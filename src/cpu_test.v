`default_nettype none

module tt_um_cpu_test(
    input  reg [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
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

  reg [3:0] registerA;
  reg [3:0] registerB;
  reg [7:0] registerOut;
  wire carry;
  wire [3:0] pc_out;

  reg [3:0] opcode;
  wire [3:0] immediate;

  assign opcode = ui_in[3:0];
  assign immediate = ui_in[7:4];
  assign uo_out[3:0] = registerA;
  assign uo_out[7:4] = registerB;

  CPU cpu(
        .opcode(opcode),
        .immediate(immediate),
        .regA_o(registerA),
        .regB_o(registerB),
        .pc_out(pc_out),
        .regOut(registerOut),
        .clk(clk),
        .carry(carry),
        .rst_n(rst_n)
      );
endmodule
