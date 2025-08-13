`default_nettype none

module CPU (
    input wire [3:0] opcode,
    input wire [3:0] immediate,
    output wire [3:0] regA_o,
    output wire [3:0] regB_o,
    output wire [3:0] pc_out,
    output wire [3:0] regOut,
    input wire clk,
    input wire rst_n,
    output wire carry
  );

  wire reg_val = 4'b0000;
  wire imm_val = 4'b0000;
  reg [3:0] alu_result;

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
      alu_result <= 4'b0;
    end
    else
    begin
      case (opcode)
        4'b0000: // ADD A,Im
        begin
          alu_result <= (register_A + immediate);
          register_A <= alu_result;
        end
        4'b0101: // ADD B,Im
        begin
          alu_result <= (register_B + immediate);
          register_B <= alu_result;
        end
        4'b0011: // MOV A,Im
        begin
          alu_result <= immediate;
          register_A <= alu_result;
        end
        4'b0111: // MOV B, Im
        begin
          alu_result <= immediate;
          register_B <= alu_result;
        end
        default:
          alu_result <= 4'b0;
      endcase
    end
  end

  assign regOut = alu_result;
  assign pc_out = pc;
  assign regA_o = register_A;
  assign regB_o = register_B;
  assign carry = 4'b0;

endmodule
