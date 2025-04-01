module ula (
    input [2:0] opcode,
    input [6:0] A,
    input [6:0] B,
    output reg [15:0] result
);
    always @(*) begin
        case (opcode)
            3'b001: result = A + B; // ADD
            3'b011: result = A - B; // SUB
            3'b010: result = A + B; // ADDI 
            3'b100: result = A - B; // SUBI
            3'b101: result = A * B; // MUL
            default: result = 16'd0; // caso base com o valor zerado; 
        endcase
    end
endmodule