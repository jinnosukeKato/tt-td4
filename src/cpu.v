`default_nettype none

module CPU (
    input wire [3:0] opcode,
    input wire [3:0] immediate,
    input reg [3:0] regA_i,
    input reg [3:0] regB_i,
    output reg [3:0] regA_o,
    output reg [3:0] regB_o,
    output wire [3:0] pc,
    output wire [3:0] regOut,
    input wire clk,
    output wire carry
  );

  wire reg_val = 4'b0000;
  wire imm_val = 4'b0000;
  reg [3:0] alu_result;

  always @(posedge clk)
  begin
    case (opcode)
      4'b0000: // ADD A,Im
      begin
        alu_result = (regA_i + immediate);
        regA_o <= alu_result;
      end
      4'b0101: // ADD B,Im
      begin
        alu_result = (regB_i + immediate);
        regB_o <= alu_result;
      end
      4'b0011: // MOV A,Im
      begin
        alu_result = immediate;
        regA_o <= alu_result;
      end
      4'b0111: // MOV B, Im
      begin
        alu_result = immediate;
        regB_o <= alu_result;
      end
    endcase
  end

  assign regOut = alu_result;

endmodule
