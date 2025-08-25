// ULA do processador RISC-V
// Aqui e onde faco todas as operacoes matematicas e logicas
// Instrucoes que uso: lh, sh, sub, or, andi, srl, beq

module ula(
    input wire [31:0] operando_a,    // Primeiro numero
    input wire [31:0] operando_b,    // Segundo numero
    input wire [3:0] operacao_ula,   // Qual operacao fazer
    input wire [2:0] funcao3,        // Campo funct3 (nao uso aqui)
    input wire [6:0] funcao7,        // Campo funct7 (nao uso aqui)
    output reg [31:0] resultado      // Resultado da operacao
);

    // Codigos das operacoes que posso fazer gerados pela ula
    localparam SOMA = 4'b0000;       // Soma: a + b
    localparam SUBTRACAO = 4'b0001;  // Subtracao: a - b
    localparam AND = 4'b0010;        // AND: a & b
    localparam OR = 4'b0011;         // OR: a | b
    localparam SRL = 4'b0100;        // Shift right: a >> b
    
    // Aqui e onde faco a operacao
    always @(*) begin
        case (operacao_ula)
            // Soma - uso para calcular enderecos
            // Exemplo: lh x6, 4(x0) -> endereco = x0 + 4
            SOMA: begin
                resultado = operando_a + operando_b;
            end
            
            // Subtracao - uso para operacoes e comparacoes
            // Exemplo: sub x3, x1, x2 -> x3 = x1 - x2
            // Exemplo: beq x6, x1, SAIDA -> compara se x6 == x1
            SUBTRACAO: begin
                resultado = operando_a - operando_b;
            end
            
            // AND logico - uso para andi
            // Exemplo: andi x1, x0, 7 -> x1 = x0 & 7
            AND: begin
                resultado = operando_a & operando_b;
            end
            
            // OR logico - uso para or
            // Exemplo: or x4, x1, x2 -> x4 = x1 | x2
            OR: begin
                resultado = operando_a | operando_b;
            end
            
            // Shift right - uso para srl
            // Exemplo: srl x5, x1, 1 -> x5 = x1 >> 1
            // Pego so os 5 bits menos significativos do operando_b
            SRL: begin
                resultado = operando_a >> operando_b[4:0];
            end
            
            // Se receber uma operacao que nao conheco, retorno zero
            default: begin
                resultado = 32'h0;
            end
        endcase
    end

endmodule
