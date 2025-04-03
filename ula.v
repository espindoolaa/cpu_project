module ula (
    input [2:0] opcode,
    input signed [15:0] valor1,
    input signed [15:0] valor2,
    output reg signed [15:0] resultado,
    output reg executou
);
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100, 
              MUL = 3'b101;
        
    always @(*) begin
        executou = 0;
        case (opcode)
            LOAD: begin 
                resultado = valor2; 
                executou = 1; 
            end

            ADD: begin 
                resultado = valor1 + valor2; 
                executou = 1; 
            end

            ADDI: begin 
                resultado = valor1 + valor2; 
                executou = 1; 
            end

            SUB: begin 
                resultado = valor1 - valor2; 
                executou = 1; 
            end
            
            SUBI: begin
                resultado = valor1 - valor2; 
                executou = 1; 
            end

            MUL: begin
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

// A ULA aparentemente está OK. 
