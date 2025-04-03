// virtual memory module 
module memory(
    input clk, 
    input we,
    input [2:0] opcode,
	input [3:0] destino,
    input [3:0] addr1,
    input [3:0] addr2,
    input [15:0] data_in,
    output reg [15:0] data_out1,
    output reg [15:0] data_out2 
);

    reg [15:0] memoria_registrada [15:0];
    
    // Escrita na memória
    always @(posedge clk) begin
        if (we) begin
            memoria_registrada[destino] <= data_in;
        end
        if (opcode == 3'b110) begin
            memoria_registrada[0]  <= 16'b0;
            memoria_registrada[1]  <= 16'b0;
            memoria_registrada[2]  <= 16'b0;
            memoria_registrada[3]  <= 16'b0;
            memoria_registrada[4]  <= 16'b0;
            memoria_registrada[5]  <= 16'b0;
            memoria_registrada[6]  <= 16'b0;
            memoria_registrada[7]  <= 16'b0;
            memoria_registrada[8]  <= 16'b0;
            memoria_registrada[9]  <= 16'b0;
            memoria_registrada[10] <= 16'b0;
            memoria_registrada[11] <= 16'b0;
            memoria_registrada[12] <= 16'b0;
            memoria_registrada[13] <= 16'b0;
            memoria_registrada[14] <= 16'b0;
            memoria_registrada[15] <= 16'b0;
        end
    end

    // Leitura da memória
    always @(posedge clk) begin
        data_out1 <= memoria_registrada[addr1];
        data_out2 <= memoria_registrada[addr2];
    end
    
endmodule
