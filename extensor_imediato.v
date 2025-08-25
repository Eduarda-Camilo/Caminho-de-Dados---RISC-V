// Extensor de imediato do processador RISC-V
// Aqui e onde converto imediatos pequenos para 32 bits
// Cada tipo de instrucao tem o imediato em posicoes diferentes

module extensor_imediato(
    input wire [31:0] instrucao,       // A instrucao completa
    input wire [1:0] fonte_imediato,   // Qual formato usar
    output reg [31:0] imediato_estendido // O imediato convertido para 32 bits
);

    // Campos de imediato das instrucoes
    // Cada formato tem o imediato em posicoes diferentes
    
    // Formato tipo I - imediato de 12 bits
    // Usado por: lh, andi, srl
    // Posicao: bits 31-20 da instrucao
    wire [11:0] imediato12 = instrucao[31:20];
    
    // Formato tipo S - instrucoes de armazenamento
    // Usado por: sh
    // Posicao: bits 31-25 e 11-7 da instrucao (fragmentado)
    wire [11:0] imediato12_armazenamento = {instrucao[31:25], instrucao[11:7]};
    
    // Formato tipo SB - instrucoes de desvio
    // Usado por: beq
    // Posicao: bits 31, 7, 30-25, 11-8 da instrucao (muito fragmentado)
    // O bit menos significativo e sempre 0 (enderecos alinhados)
    wire [12:0] imediato13_desvio = {instrucao[31], instrucao[7], instrucao[30:25], instrucao[11:8], 1'b0};
    
    // Aqui e onde faco a extensao
    always @(*) begin
        case (fonte_imediato)
            // Formato tipo I - extensao de sinal de 12 bits
            // Instrucoes: lh, andi, srl
            // Exemplo: andi x1, x0, 7 -> imediato = 7
            2'b00: begin
                // Extensao de sinal
                // Repito o bit mais significativo (bit 11) 20 vezes
                imediato_estendido = {{20{imediato12[11]}}, imediato12};
            end
            
            // Formato tipo S - extensao de sinal de 12 bits
            // Instrucoes: sh
            // Exemplo: sh x1, 4(x0) -> imediato = 4
            2'b01: begin
                // Extensao de sinal
                // Repito o bit mais significativo (bit 11) 20 vezes
                imediato_estendido = {{20{imediato12_armazenamento[11]}}, imediato12_armazenamento};
            end
            
            // Formato tipo SB - extensao de sinal de 13 bits
            // Instrucoes: beq
            // Exemplo: beq x6, x1, SAIDA -> imediato = offset do desvio
            2'b10: begin
                // Extensao de sinal
                // Repito o bit mais significativo (bit 12) 19 vezes
                imediato_estendido = {{19{imediato13_desvio[12]}}, imediato13_desvio};
            end
            
            // Se receber um formato que nao conheco, retorno zero
            default: begin
                imediato_estendido = 32'h0;
            end
        endcase
    end

endmodule
