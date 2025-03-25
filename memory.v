module memory (
    input clk,
    input write_enable,
    input [3:0] addr_w, // Endereço de escrita
    input [3:0] addr_r1, // Endereço de leitura 1
    input [3:0] addr_r2, // Endereço de leitura 2
    input [15:0] data_in,
    output reg [15:0] data_out1,
    output reg [15:0] data_out2
);
    reg [15:0] registers [0:15]; // 16 registradores de 16 bits

    always @(posedge clk) begin
        if (write_enable)
            registers[addr_w] <= data_in; // Escreve no registrador de destino
    end

    always @(*) begin
        data_out1 = registers[addr_r1]; // Lê src1
        data_out2 = registers[addr_r2]; // Lê src2
    end
endmodule