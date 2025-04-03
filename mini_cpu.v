module mini_cpu (
    input clk,
    input reset,
    input botao_inicio,
    input botao_send,
    input [17:0] switches,
    output [7:0] lcd_data,
    output lcd_rs,
    output lcd_rw,
    output lcd_en
);

    // definição dos estados
    typedef enum logic [2:0] {
        IDLE    = 3'd0,  // sistema desligado ou reinicializado
        FETCH   = 3'd1,  // busca a instrução nos switches
        DECODE  = 3'd2,  // decodifica a instrução lida
        EXECUTE = 3'd3,  // executa a operação na ULA
        STORE   = 3'd4,  // armazena o resultado na memória (ou registrador)
        DISPLAY = 3'd5,  // aciona o LCD para mostrar os resultados
        WAIT    = 3'd6   // aguarda a propagação e o "release" do botão
    } state_t;

    state_t state, next_state;

    // Sinais internos
    reg [17:0] instrucao;
    reg [2:0] opcode;
    reg [3:0] reg_dest;
    reg [3:0] reg_src1;
    reg [3:0] reg_src2;
    reg [5:0] imediato;
    reg sinal_imediato;
    reg [15:0] resultado;

    // Sinais para comunicação com a ULA e memória
    wire signed [15:0] operando1;
    wire signed [15:0] operando2;
    wire signed [15:0] resultado_alu;
    reg write_enable;

    // Sinal de pronto do LCD
    wire lcd_ready;

    // Contador para gerar atraso no estado WAIT (aguarda tempo de propagação para estabilização no LCD)
    reg [15:0] wait_counter;
    parameter WAIT_TIME = 16'd50000; // considerando que o clock é de 50MHz, 1ms seria necessário 50.000 ciclos 
    
    // Sinais utilizados para transição de determinados estados 
    wire executou;
    
    // Instanciação da ULA
    ula alu (
        .opcode(opcode),
        .valor1(operando1),
        .valor2(operando2),
        .resultado(resultado_alu),
        .executou(executou)
    );

    // Instanciação da memória (registradores)
    memory memoria (
        .clk(clk),
        .we(write_enable),
        .opcode(opcode),
        .addr1(reg_dest),
        .addr2(reg_src1),
        .data_in(resultado),
        .data_out1(operando1),
        .data_out2(operando2)
    );

    // Instanciação do LCD
    lcd_controller lcd (
        .clk(clk),
        .reset(reset),
        .state(state), // repassa o estado atual, se necessário para o display
        .opcode(opcode),
        .reg_dest(reg_dest),
        .reg_src1(reg_src1),
        .reg_src2(reg_src2),
        .resultado(resultado),
        .lcd_data(lcd_data),
        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw),
        .lcd_en(lcd_en),
        .ready(lcd_ready)
    );

    // Máquina de estados: transição de estados
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            wait_counter <= 16'd0; 
            
        end else begin
            state <= next_state;

            if (state != WAIT) 
                wait_counter <= 16'd0;
        end
    end

    // Lógica de próximo estado
    always @(*) begin
        case (state)
            IDLE: begin
                // Aguarda o botão de início para ligar o sistema
                if (botao_inicio)
                    next_state = FETCH;
                else
                    next_state = IDLE;
            end

            FETCH: begin
                // Busca a instrução assim que o botão de envio for acionado
                if (botao_send)
                    next_state = DECODE;
                else
                    next_state = FETCH;
            end

            DECODE: begin
                // Após capturar a instrução, vai para execução
                next_state = EXECUTE;
            end

            EXECUTE: begin
                // Executa a operação via ULA (ou lógica interna)
                if (executou)
                    next_state = STORE;
                else
                    next_state = EXECUTE;
            end

            STORE: begin
                // Armazena o resultado na memória se necessário
                next_state = DISPLAY;
            end

            DISPLAY: begin
                // Envia os dados para o LCD e aguarda o LCD pronto
                if (lcd_ready)
                    next_state = WAIT;
                else
                    next_state = DISPLAY;
            end

            WAIT: begin
                // Aguarda o "release" do botão para permitir nova instrução
                if ((wait_counter >= WAIT_TIME) && (!botao_send))
                    next_state = FETCH;
                else
                    next_state = WAIT;
            end

            default: next_state = IDLE;
        endcase
    end

    // Lógica de saída e processamento
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                // Reseta os sinais e os registradores
                instrucao      <= 18'b0;
                opcode         <= 3'b0;
                reg_dest       <= 4'b0;
                reg_src1       <= 4'b0;
                reg_src2       <= 4'b0;
                imediato       <= 6'b0;
                sinal_imediato <= 1'b0;
                resultado      <= 16'b0;
                write_enable   <= 1'b0;
            end

            FETCH: begin
                // Captura a instrução dos switches
                instrucao <= switches;
            end

            DECODE: begin
                // Decodifica os campos da instrução
                opcode <= instrucao[17:15];
                case (instrucao[17:15])
                    3'b000: begin // LOAD
                        reg_dest       <= instrucao[14:11];
                        sinal_imediato <= instrucao[10];
                        imediato       <= instrucao[9:4];
                    end

                    3'b001, 3'b011: begin // ADD, SUB
                        reg_dest <= instrucao[14:11];
                        reg_src1 <= instrucao[10:7];
                        reg_src2 <= instrucao[6:3];
                    end

                    3'b010, 3'b100, 3'b101: begin // ADDI, SUBI, MUL
                        reg_dest       <= instrucao[14:11];
                        reg_src1       <= instrucao[10:7];
                        sinal_imediato <= instrucao[6];
                        imediato       <= instrucao[5:0];
                    end

                    3'b110: begin // CLEAR
                        // Operação especial de limpar os registradores, que ocorre na própria memória 
                    end

                    3'b111: begin // DISPLAY
                        reg_src1 <= instrucao[3:0];
                    end

                    default: ;
                endcase
            end

            EXECUTE: begin
                // Executa a operação usando a ULA 
                case (opcode)
                    3'b001: begin // ADD
                        resultado <= resultado_alu;
                        write_enable <= 1'b1;
                    end
                    3'b011: begin // SUB
                        resultado <= resultado_alu;
                        write_enable <= 1'b1;
                    end
                    3'b010, 3'b100: begin // ADDI, SUBI
                        resultado <= resultado_alu;
                        write_enable <= 1'b1;
                    end
                    3'b101: begin // MUL
                        resultado <= resultado_alu;
                        write_enable <= 1'b1;
                    end
                    3'b000: begin // LOAD
                        resultado <= imediato; // Carrega o valor imediato
                        write_enable <= 1'b1;
                    end
                    3'b110: begin // CLEAR
                        resultado <= 16'b0;
                        write_enable <= 1'b1;
                    end
                    3'b111: begin // DISPLAY
                        // Apenas leitura para exibição – não realiza escrita
                        write_enable <= 1'b0;
                    end
                    default: begin
                        resultado <= 16'b0;
                        write_enable <= 1'b0;
                    end
                endcase
            end

            STORE: begin
                // O sinal write_enable continua ativo durante o ciclo de armazenamento
            end

            DISPLAY: begin
                // Aciona o módulo LCD para atualizar a exibição
                write_enable <= 1'b0;
            end

            WAIT: begin
                // Aguarda a propagação do sinal do LCD e o "release" do botão de envio
            end

            default: ;
        endcase
    end

endmodule
