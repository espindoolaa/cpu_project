// LCD
module lcd (
    input clk,
    output reg EN, RW, RS,
    input [15:0] valor,
    input [2:0] opcode,
    input [2:0] estado,
    output reg [7:0] data
);

parameter MS = 5000;
parameter WRITE = 0;
parameter WAIT = 1;
reg [20:0] counter = 0;

reg [20:0] instructions = 0;
reg [3:0] U, D, C, M, DM;
reg [7:0] dezmilhar;
reg [7:0] milhar;
reg [7:0] centenas;
reg [7:0] dezenas;
reg [7:0] unidades;

initial begin
    EN = 0;
    RS = 0;
    RW = 0;
instructions = 0;
end

reg [2:0] status = WRITE;

always @(posedge clk) begin
    case(status)
        WRITE: begin
            if (counter == MS - 1) begin
                counter <= 0;
                status <= WAIT;
            end
            else
                counter <= counter + 1;
        end
        WAIT: begin
            if (counter == MS - 1) begin
                counter <= 0;
                status <= WRITE;
                if(instructions < 40) instructions <= instructions +1;
            end
            else counter <= counter + 1;
        end
        default: begin end
    endcase
end

always @(*) begin
    U = valor % 10;
    D = (valor % 100) / 10;
    C = (valor % 1000) / 100;
    M = (valor % 10000) / 1000;
    DM = valor / 10000;

    unidades = 8'h30 + U;
    dezenas = 8'h30 + D;
    centenas = 8'h30 + C;
    milhar = 8'h30 + M;
    dezmilhar = 8'h30 + DM;
end

always @(posedge clk) begin
    case (status)
        WRITE: EN <= 1;
        WAIT: EN <= 0;
        default: EN <= EN;
    endcase

    case(instructions)
        1: begin data <= 8'h38; RS <= 0; end    
        2: begin data <= 8'h0E; RS <= 0; end
        3: begin data <= 8'h01; RS <= 0; end
        4: begin data <= 8'h02; RS <= 0; end
        5: begin data <= 8'h06; RS <= 0; end

        6: begin //LETRA 1
            //if (opcode == 3'b000) //LOAD
                data <= 8'h4C; //L
            /*if (opcode == 3'b001 || opcode == 3'b010) //ADD or ADDI
                data <= 8'h41; //A
            if (opcode == 3'b011 || opcode == 3'b100) //SUB or SUBI
                data <= 8'h53; //S
            if (opcode == 3'b101) //MUL
                data <= 8'h4D; //M
            if (opcode == 3'b111) //DPL
                data <= 8'h44;   //D
            if (opcode == 3'b110) //CLEAR
                data <= 8'h43; //C
            if (estado == 3'b000)  //inicio do LCD
                data <= 8'h2D; //-*/
            RS <= 1; end  

        7: begin //LETRA 2
            //if (opcode == 3'b000) //LOAD
                data <= 8'h4F; //O
            /*if (opcode == 3'b001 || opcode == 3'b010) //ADD or ADDI
                data <= 8'h44; //D
            if (opcode == 3'b011 || opcode == 3'b100 || opcode == 3'b101) //SUB or SUBI or MUL
                data <= 8'h55; //U
            if (opcode == 3'b110) // CLEAR
                data <= 8'h4C; //L
            if (opcode == 3'b111) //DPL
                data <= 8'h50;   //P
            if (estado == 3'b000)  //inicio do LCD
                data <= 8'h2D; //-*/
            RS <= 1; end

        8: begin  //LETRA 3
            //if (opcode == 3'b000) //LOAD
                data <= 8'h41; //A
            /*if (opcode == 3'b001 || opcode == 3'b010) //ADD or ADDI
                data <= 8'h44; //D
            if (opcode == 3'b011 || opcode == 3'b100) //SUB or SUBI
                data <= 8'h42; //B
            if (opcode == 3'b101 || opcode == 3'b111) //MUL or DPL
                data <= 8'h4C; //L
            if (opcode == 3'b110) //CLEAR
                data <= 8'h45; //E
            if (estado == 3'b000)  //inicio do LCD
                data <= 8'h2D; //-*/
            RS <= 1; end  

        9: begin //LETRA 4
            //if (opcode == 3'b000) //LOAD
                data <= 8'h44; //D
            /*if (opcode == 3'b001 || opcode == 3'b011 || opcode == 3'b101 || opcode == 3'b111) // ADD  or SUB or MUL or DPL(espaço)
                data <= 8'h20; //espaço
            if (opcode == 3'b010 || opcode == 3'b100) //ADDI or SUBI
                data <= 8'h49; //I
            if (opcode == 3'b110) //CLEAR
                data <= 8'h41; //A
            if (estado == 3'b000)  //inicio do LCD
                data <= 8'h2D; //-*/
            RS <= 1;
        end

        10: begin
            //if (opcode == 3'b110) //CLEAR
                //data <= 8'h52; //R
            //else
                data <= 8'h20;
            RS <= 1;
        end  //ESPAÇO
        11: begin data <= 8'h20; RS <= 1; end
        12: begin data <= 8'h20; RS <= 1; end
        13: begin data <= 8'h20; RS <= 1; end
        14: begin data <= 8'h20; RS <= 1; end
        15: begin data <= 8'h20; RS <= 1; end
        16: begin data <= 8'h5B; RS <= 1; end    // opcode [

        17: begin
            if (estado == 3'b000)  //inicio do LCD
                data <= 8'h2D; //-
            else
                data <= 8'h30; RS <= 1; end // 0

        18: begin
            if (estado == 3'b000)  //inicio do LCD
                data <= 8'h2D; //-
            else begin
                if (opcode[2] == 0) begin
                    data <= 8'h30; RS <= 1; // 0
                end else begin
                    data <= 8'h31; RS <= 1; // 1
                end
            end
        end

        19: begin  
            if (estado == 3'b000)  //inicio do LCD
            data <= 8'h2D; //-
            else begin
                if (opcode[2] == 0) begin
                    data <= 8'h30; RS <= 1; // 0
                end else begin
                    data <= 8'h31; RS <= 1; // 1
                end
            end
        end

        20: begin
            if (estado == 3'b000)  //inicio do LCD
            data <= 8'h2D; //-
            else begin
                if (opcode[2] == 0) begin
                    data <= 8'h30; RS <= 1; // 0
                end else begin
                    data <= 8'h31; RS <= 1; // 1
                end
            end
        end

        21: begin data <= 8'h5D; RS <= 1; end    //]

        22: begin data <= 8'hC0; RS <= 0; end    //QUEBRA DE LINHA

        23: begin data <= 8'h20; RS <= 1; end  //ESPAÇO
        24: begin data <= 8'h20; RS <= 1; end
        25: begin data <= 8'h20; RS <= 1; end
        26: begin data <= 8'h20; RS <= 1; end
        27: begin data <= 8'h20; RS <= 1; end
        28: begin data <= 8'h20; RS <= 1; end
        29: begin data <= 8'h20; RS <= 1; end  
        30: begin data <= 8'h20; RS <= 1; end
        31: begin data <= 8'h20; RS <= 1; end
        32: begin data <= 8'h20; RS <= 1; end
       
        33: begin  
            if(valor[15] == 0 || estado == 3'b000)
                data <= 8'h2B;  //+
            else
                data <= 8'h2D; //-
            RS <= 1;
            end
       
        34: begin data <= dezmilhar; RS <= 1; end
        35: begin data <= milhar; RS <= 1; end
        36: begin data <= centenas; RS <= 1; end
        37: begin data <= dezenas; RS <= 1; end
        38: begin data <= unidades; RS <= 1; end

        default: begin data <= 8'h02; RS <= 0; end
           
    endcase
end

endmodule
