`default_nettype none

module CPU (
    input wire [3:0] opcode,
    input wire [3:0] immediate,
    input wire [3:0] io_input,
    input wire exec_mode,
    output reg  [3:0] register_A,
    output reg  [3:0] register_B,
    output reg  [3:0] pc,
    output reg  [3:0] register_OUT,
    input wire clk,
    input wire rst_n,
    output reg register_carry
  );

  // opcode definitions (4-bit)
  localparam ADD_A    = 4'b0000; // ADD A, Im
  localparam ADD_B    = 4'b1010; // ADD B, Im
  localparam MOV_A_IM = 4'b1100; // MOV A, Im
  localparam MOV_B_IM = 4'b1110; // MOV B, Im
  localparam MOV_A_B  = 4'b1000; // MOV A, B
  localparam MOV_B_A  = 4'b0010; // MOV B, A
  localparam JMP      = 4'b1111; // JMP Im
  localparam JNC      = 4'b0111; // JNC Im
  localparam IN_A     = 4'b0100; // IN A
  localparam IN_B     = 4'b0110; // IN B
  localparam OUT_B    = 4'b1001; // OUT B
  localparam OUT_IM   = 4'b1101; // OUT Im

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      register_A <= 4'b0;
      register_B <= 4'b0;
      pc <= 4'b0;
      register_OUT <= 4'b0;
      register_carry <= 1'b0;
    end
    else
    begin
      if (exec_mode)
      begin
        case (opcode)
          ADD_A:
            {register_carry, register_A} <= register_A + immediate;
          ADD_B:
            {register_carry, register_B} <= register_B + immediate;
          MOV_A_IM:
            register_A <= immediate;
          MOV_B_IM:
            register_B <= immediate;
          MOV_A_B:
            register_A <= register_B;
          MOV_B_A:
            register_B <= register_A;
          JMP:
            pc <= immediate;
          JNC:
            if (!register_carry)
            begin
              pc <= immediate;
            end
          IN_A:
            register_A <= io_input;
          IN_B:
            register_B <= io_input;
          OUT_B:
            register_OUT <= register_B;
          OUT_IM:
            register_OUT <= immediate;
          default:
            ;
        endcase

        // increment PC for non-jump/branch instructions
        if (opcode != JMP && opcode != JNC)
          pc <= pc + 1;

        // clear carry on non-add instructions
        if (opcode != ADD_A && opcode != ADD_B)
          register_carry <= 1'b0;

      end
    end
  end
endmodule
