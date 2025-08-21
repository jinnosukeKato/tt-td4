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
          4'b0000: // ADD A,Im
            {register_carry, register_A} <= register_A + immediate;
          4'b1010: // ADD B,Im
            {register_carry, register_B} <= register_B + immediate;
          4'b1100: // MOV A,Im
            register_A <= immediate;
          4'b1110: // MOV B, Im
            register_B <= immediate;
          4'b1000: // MOV A, B
            register_A <= register_B;
          4'b0010: // MOV B, A
            register_B <= register_A;
          4'b1111: // JMP Im
            pc <= immediate;
          4'b0111: // JNC Im
            if (!register_carry)
            begin
              pc <= immediate;
            end
          4'b0100: // IN A
            register_A <= io_input;
          4'b0110: // IN B
            register_B <= io_input;
          4'b1001: // OUT B
            register_OUT <= register_B;
          4'b1101: // OUT Im
            register_OUT <= immediate;
          default:
            ;
        endcase

        if (opcode[2:0] != 3'b111)
          pc <= pc + 1;

        if (opcode != 4'b0000 && opcode != 4'b1010)
          register_carry <= 1'b0;

      end
    end
  end
endmodule
