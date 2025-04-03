module ula ( // recieve the values and executes
    input [2:0] opcode,
    input signed [15:0] valor1,
    input signed [15:0] valor2,
    output reg signed [15:0] resultado
    );

    always @(*) begin 
        case(opcode)
            3'b000: resultado = valor2; //caso em que ela só recebe
            3'b001: resultado = valor1 + valor2; //soma
            3'b010: resultado = valor1 + valor2; //soma com immediatos
            3'b011: resultado = valor1 - valor2; //subtração
            3'b100: resultado = valor1 - valor2; //subtração com immediatos
            3'b101: resultado = valor1 * valor2; //multiplicação;
        endcase
    end
    
endmodule
