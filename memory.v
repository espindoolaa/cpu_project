// virtual memory module 
module memory (
    input clk, 
    input we,
    input [2:0] opcode,
    input [3:0] addr1,
    input [3:0] addr2,
    input [15:0] data_in,
    output reg [15:0] data_out1,
    output reg [15:0] data_out2 
    );

    reg [15:0] memoria_registrada [15:0];
    
    // reading function
    function [15:0] ler_memoria(input [3:0] endereco);
        begin
            ler_memoria = memoria_registrada[endereco];
        end
    endfunction

    always @(posedge clk)begin // writing in the memory space  
        if (we) begin
            memoria_registrada[addr] <= data_in;
        end
        if (opcode == 3'b110) begin // clear mode activated 
            memoria_registrada[0] = 0;
            memoria_registrada[1] = 0;
            memoria_registrada[2] = 0;
            memoria_registrada[3] = 0;
            memoria_registrada[4] = 0;
            memoria_registrada[5] = 0;
            memoria_registrada[6] = 0;
            memoria_registrada[7] = 0;
            memoria_registrada[8] = 0;
            memoria_registrada[9] = 0;
            memoria_registrada[10] = 0;
            memoria_registrada[11] = 0;
            memoria_registrada[12] = 0;
            memoria_registrada[13] = 0;
            memoria_registrada[14] = 0;
            memoria_registrada[15] = 0;
        end
    end
    
    always @(posedge clk)begin
        data_out <= ler_memoria(addr);
    end
    
endmodule
