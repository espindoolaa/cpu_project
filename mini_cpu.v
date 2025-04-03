module mini_cpu (
    input clk,
    input reset,
    input botao_inicio,
    input botao_send,
    input [17:0] switches,
    output [7:0] lcd_data,
	output reg [15:0] led_resultado,
	output reg [2:0] led_opcode,
    output lcd_rs,
    output lcd_rw,
    output lcd_en,
	output led_power, led_send, led_lcd
);

    // definição dos estados
    localparam FETCH = 3'd1,  
           DECODE = 3'd2,  
           EXECUTE = 3'd3,  
           STORE = 3'd4,  
           DISPLAY = 3'd5,  
           WAIT = 3'd6,
           APAGADO = 3'd7;

    reg [2:0] state;
    reg [2:0] next_state = APAGADO;
	reg enviou;

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

	 
	 assign led_power = botao_inicio;
	 assign led_send = botao_send;
	 always @(*) begin
	  led_resultado <= resultado;
	  led_opcode <=  instrucao[17:15];
	 end
    // Contador para gerar atraso no estado WAIT (aguarda tempo de propagação para estabilização no LCD)
    reg [15:0] wait_counter;
    parameter WAIT_TIME = 16'd50000; // considerando que o clock é de 50MHz, 1ms seria necessário 50.000 ciclos 
    
    // Sinais utilizados para transição de determinados estados 
    wire executou;

    parameter nada = 2'b00,
            apertou = 2'b01,
            soltou = 2'b10,
            espera = 2'b11;
    reg [1:0] botao_envia = nada;
    reg [1:0] botao_reset = nada;
    reg [1:0] botao_comeca = nada;
    
    // Instanciacão da ULA
    ula alu (
        .opcode(instrucao[17:15]),
        .valor1(operando1),
        .valor2(operando2),
        .resultado(resultado_alu),
        .executou(executou)
    );

    // Instanciacão da memória (registradores)
    memory memoria (
        .clk(clk),
        .we(write_enable),
        .opcode(instrucao[17:15]),
        .destino(reg_dest),
        .cpu_estado(state),
        .addr1(reg_src1),
        .addr2(reg_src2),
        .data_in(resultado),
        .data_out1(operando1),
        .data_out2(operando2)
    );

    // Instanciacão do LCD
    lcd lcd (
        .clk(clk),
        .estado(state), // repassa o estado atual, se necessário para o display
        .opcode(opcode),
        .valor(resultado),
        .data(lcd_data),
        .RS(lcd_rs),
        .RW(lcd_rw),
        .EN(lcd_en),
        .adress(reg_dest),
    );
    //maquina de estados para checar a descida dos botões
    always @(posedge clk) begin 
        case(botao_envia)  // inutil
            nada: begin if (!botao_send) botao_envia <= apertou; end 
            apertou: begin if (botao_send) botao_envia <= soltou; end
            soltou: begin botao_envia<=nada; end 
        endcase

        case(botao_reset)
            nada: begin if (!reset) botao_reset <= apertou; end 
            apertou: begin if (reset) botao_reset <= soltou; end
            soltou: begin ibotao_reset <= nada; end 
        endcase

        case(botao_comeca)
            nada: begin if (!botao_inicio) botao_comeca <= apertou; end 
            apertou: begin if (botao_inicio) botao_comeca <= soltou; end
            soltou: begin botao_comeca <= nada; end 
        endcase
    end

    // Máquina de estados: transicão de estados
    always @(posedge clk) begin
        if (botao_reset == soltou) begin   //retorna para o estado inicial (lcd com tracos e numeros zerados)
            state <= FETCH;
            wait_counter <= 16'd0; 
            end 
            else begin
                if (state != WAIT) 
                    wait_counter <= 16'd0;
                end
    end

    // Lógica de próximo estado
    always @(posedge clk) begin
        case (state)
            APAGADO:
                if (botao_comeca == soltou)  //LCD COMEcA VAZIO, APERTOU BOTAO DE INICIO ELE LIGA!!!!
                    next_state = FETCH;
                else next_state = APAGADO;


            FETCH: begin
                // Busca a instrucão assim que o botão de envio for acionado
                if (botao_comeca == soltou)  //SE APERTAR NOVAMENTE O BOTÃO DE COMEcO, APAGA TUDOOOOO DNV
                    next_state = APAGADO;
                else 
                if (botao_envia == soltou)  //apenas o botão de envio habilita as imformacões para o lcd
                    next_state = DECODE;

            end

            DECODE: begin
                // Após capturar a instrucão, vai para execucão
                if (botao_comeca == soltou)  //SE APERTAR NOVAMENTE O BOTÃO DE COMEcO, APAGA TUDOOOOO DNV
                    next_state = APAGADO;
                else next_state = EXECUTE;
            end

            EXECUTE: begin
                // Executa a operacão via ULA (ou lógica interna)
                if (botao_comeca == soltou)  //SE APERTAR NOVAMENTE O BOTÃO DE COMEcO, APAGA TUDOOOOO DNV
                    next_state = APAGADO;
                else begin 
                    if (executou)
                    next_state = STORE;
                    else
                    next_state = EXECUTE;
                end
            end

            STORE: begin
                // Armazena o resultado na memória se necessário
                if (botao_comeca == soltou)  //SE APERTAR NOVAMENTE O BOTÃO DE COMEcO, APAGA TUDOOOOO DNV
                    next_state = APAGADO;
                else next_state = DISPLAY;
            end

            DISPLAY: begin
                // Envia os dados para o LCD e aguarda o LCD pronto
                if (botao_comeca == soltou)  //SE APERTAR NOVAMENTE O BOTÃO DE COMEcO, APAGA TUDOOOOO DNV
                    next_state = APAGADO;
                else begin 
                    if (lcd_ready)
                    next_state = WAIT;
                    else
                    next_state = DISPLAY;
                end
            end

            WAIT: begin
                // Aguarda o "release" do botão para permitir nova instrucão
                if (botao_comeca == soltou)  //SE APERTAR NOVAMENTE O BOTÃO DE COMEcO, APAGA TUDOOOOO DNV
                    next_state = APAGADO;
                else begin 
                    if ((wait_counter >= WAIT_TIME) && (botao_envia == soltou))
                        next_state = FETCH;
                    else next_state = WAIT;
                end
            end

            default: next_state = FETCH;
        endcase
    end

    // Lógica de saída e processamento
    always @(*) begin
        case (state)

            FETCH: begin
                // Reseta os sinais e os registradores
                instrucao      <= 18'b0;
                //opcode         <= 3'b0;
                reg_dest       <= 4'b0;
                reg_src1       <= 4'b0;
                reg_src2       <= 4'b0;
                imediato       <= 6'b0;
                sinal_imediato <= 1'b0;
                resultado      <= 16'b0;
                write_enable   <= 1'b0;
                instrucao <= switches;
            end

            DECODE: begin
                // Decodifica os campos da instrução
                opcode <= instrucao[17:15];
                case (instrucao[17:15])
                    3'b000: begin // LOAD
                        reg_dest	   <= instrucao[14:11];
                        sinal_imediato <= instrucao[6];
                        imediato       <= instrucao[5:0];
                    end

                    3'b001: begin // ADD, SUB
                        reg_dest <= instrucao[14:11];
                        reg_src1 <= instrucao[10:7];
                        reg_src2 <= instrucao[6:3];
                    end

                    3'b011: begin // ADD, SUB
                        reg_dest <= instrucao[14:11];
                        reg_src1 <= instrucao[10:7];
                        reg_src2 <= instrucao[6:3];
                    end

                    3'b010: begin // ADDI, SUBI, MUL
                        reg_dest       <= instrucao[14:11];
                        reg_src1       <= instrucao[10:7];
                        sinal_imediato <= instrucao[6];
                        imediato       <= instrucao[5:0];
                    end

                    3'b100: begin // ADDI, SUBI, MUL
                        reg_dest       <= instrucao[14:11];
                        reg_src1       <= instrucao[10:7];
                        sinal_imediato <= instrucao[6];
                        imediato       <= instrucao[5:0];
                    end

                    3'b101: begin // ADDI, SUBI, MUL
                        reg_dest       <= instrucao[14:11];
                        reg_src1       <= instrucao[10:7];
                        sinal_imediato <= instrucao[6];
                        imediato       <= instrucao[5:0];
                    end

                    3'b110: begin // CLEAR
                        // Operação especial de limpar os registradores, que ocorre na própria memória 
                    end

                    3'b111: begin // DISPLAY
                        reg_src1 <= instrucao[14:11];
                    end

                    default: ;
                endcase
            end

            EXECUTE: begin
                // Executa a operação usando a ULA 
                case ( instrucao[17:15])
                    3'b001: begin // ADD
                        resultado <= resultado_alu;
                        write_enable <= 1'b1;
                    end
                    3'b011: begin // SUB
                        resultado <= resultado_alu;
                        write_enable <= 1'b1;
                    end
                    3'b010: begin // ADDI, SUBI
                        resultado <= resultado_alu;
                        write_enable <= 1'b1;
                    end
                    3'b100: begin // ADDI, SUBI
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
