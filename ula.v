module ula (
    input [2:0] opcode,
    input signed [15:0] valor1,
    input signed [15:0] valor2,
    output reg signed [15:0] resultado,
    output reg executou
);
    always @(*) begin
        executou = 0;
        case (opcode)
            3'b000: begin 
                resultado = valor2; 
                executou = 1; 
            end
            3'b001: begin 
                resultado = valor1 + valor2; 
                executou = 1; 
            end
            3'b010: begin 
                resultado = valor1 + valor2; 
                executou = 1; 
            end
            3'b011: begin 
                resultado = valor1 - valor2; 
                executou = 1; 
            end
            3'b100: begin
                resultado = valor1 - valor2; 
                executou = 1; 
            end
            3'b101: begin
                resultado = valor1 * valor2; 
                executou = 1; 
            end    
            default: begin
                resultado = 16'b0;
                executou = 0;
            end
        endcase
    end
endmodule
