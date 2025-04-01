module mini_cpu (
    input clk,
    input reset,
    input send_instr,
    input [17:0] instr,
    output reg [15:0] lcd_data
);
    reg [2:0] opcode;
    reg [3:0] dest, src1, src2;
    reg [5:0] imm;
    reg [15:0] A, B, result;
    wire [15:0] data_out1, data_out2;
    reg write_enable;

    parameter LOAD = 3'b000,
                

    // instancia memória e ULA
    memory mem (
        .clk(clk),
        .write_enable(write_enable),
        .addr_w(dest),
        .addr_r1(src1),
        .addr_r2(src2),
        .data_in(result),
        .data_out1(data_out1),
        .data_out2(data_out2)
    );

    alu my_alu (
        .opcode(opcode),
        .A(A),
        .B(B),
        .result(result)
    );

    // Finite state machine 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_enable <= 0;
        end else if (send_instr) begin
            opcode = instr[17:15];
            dest = instr[14:11];

            case (opcode)
                3'b000: begin  // LOAD imediato
                    A = {{10{instr[6]}}, instr[5:0]};  // Extensão de sinal
                    write_enable = 1;
                    result = A;
                end
                3'b001, 3'b011: begin  // ADD / SUB (Reg x Reg)
                    src1 = instr[10:7];
                    src2 = instr[6:3];
                    A = data_out1;
                    B = data_out2;
                    write_enable = 1;
                end
                3'b010, 3'b100, 3'b101: begin  // ADDI, SUBI, MUL (Reg x Imediato)
                    src1 = instr[10:7];
                    imm = instr[5:0];
                    A = data_out1;
                    B = {{10{instr[6]}}, imm}; // Extensão de sinal
                    write_enable = 1;
                end
                3'b110: begin  // CLEAR
                    integer i;
                    for (i = 0; i < 16; i = i + 1)
                        mem.registers[i] <= 16'b0;
                    write_enable = 0;
                end
                3'b111: begin  // DISPLAY
                    lcd_data = data_out1;
                    write_enable = 0;
                end
            endcase
        end
    end
endmodule
