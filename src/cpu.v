`default_nettype none

module CPU (
    input wire [3:0] opcode,
    input wire [3:0] immediate,
    input wire [3:0] io_input,
    output wire [3:0] regA_o,
    output wire [3:0] regB_o,
    output wire [3:0] pc_out,
    output wire [3:0] regOut,
    input wire clk,
    input wire rst_n,
    output wire carry
  );

  wire _unused = &{io_input};

  reg [3:0] register_A;
  reg [3:0] register_B;
  reg [3:0] pc;
  reg [3:0] register_Out;

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      register_A <= 4'b0;
      register_B <= 4'b0;
      pc <= 4'b0;
      register_Out <= 4'b0;
    end
    else
    begin
      case (opcode)
        4'b0000: // ADD A,Im
          register_A <= register_A + immediate;
        4'b1010: // ADD B,Im
          register_B <= register_B + immediate;
        4'b1100: // MOV A,Im
          register_A <= immediate;
        4'b1110: // MOV B, Im
          register_B <= immediate;
        4'b1000: // MOV A, B
          register_A <= register_B;
        4'b0010: // MOV B, A
          register_B <= register_A;
        default:
          ;
      endcase
      pc <= pc + 1;
    end
  end

  assign regOut = register_Out;
  assign pc_out = pc;
  assign regA_o = register_A;
  assign regB_o = register_B;
  assign carry = 1'b0;

endmodule
