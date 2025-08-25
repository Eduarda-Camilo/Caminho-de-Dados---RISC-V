// Unidade de controle do processador RISC-V
// Aqui e onde decodifico as instrucoes e ativo os sinais certos
// Instrucoes que reconheco: lh, sh, sub, or, andi, srl, beq

module unidade_controle(
    input wire [6:0] codigo_operacao,    // Opcode da instrucao
    input wire [2:0] funcao3,           // Campo funct3
    input wire [6:0] funcao7,           // Campo funct7
    output reg escrever_registrador,    // Se vai escrever no registrador
    output reg ler_memoria,             // Se vai ler da memoria
    output reg escrever_memoria,        // Se vai escrever na memoria
    output reg fonte_ula,               // Se ULA usa registrador ou imediato
    output reg [3:0] operacao_ula,      // Qual operacao a ULA vai fazer
    output reg branch,                  // Se e uma instrucao de desvio
    output reg [1:0] memoria_para_registrador, // De onde vem os dados
    output reg [1:0] fonte_imediato     // Como estender o imediato
);

    // Opcodes das instrucoes RISC-V
    // Cada um identifica um tipo de instrucao
    localparam CARREGAR = 7'b0000011;      // Load (lh) carrega dados da memoria
    localparam ARMAZENAR = 7'b0100011;     // Store (sh) armazena dados na memoria
    localparam DESVIO = 7'b1100011;        // Branch (beq) desvio condicional
    localparam OP_IMEDIATO = 7'b0010011;   // Operacoes com imediato (andi, srl)
    localparam OP_REGISTRADOR = 7'b0110011; // Operacoes entre registradores (sub, or)
    
    // Campos funct3 para identificar a instrucao exata
    localparam LH = 3'b001;    // Load halfword
    localparam SH = 3'b001;    // Store halfword
    localparam BEQ = 3'b000;   // Branch if equal
    localparam SUB = 3'b000;   // Subtract
    localparam OR = 3'b110;    // OR
    localparam ANDI = 3'b111;  // AND immediate
    localparam SRL = 3'b101;   // Shift right logical
    
    // Aqui e onde decodifico a instrucao
    always @(*) begin
        // Comeco com todos os sinais desligados
        // So ativo os que preciso para cada instrucao
        escrever_registrador = 1'b0;        // Nao escreve no registrador
        ler_memoria = 1'b0;                 // Nao le da memoria
        escrever_memoria = 1'b0;            // Nao escreve na memoria
        fonte_ula = 1'b0;                   // ULA usa registrador
        operacao_ula = 4'b0000;             // Operacao padrao (soma)
        branch = 1'b0;                      // Nao e desvio
        memoria_para_registrador = 2'b00;   // Dados vem da ULA
        fonte_imediato = 2'b00;             // Formato padrao
        
        // Vejo qual e o opcode e ativo os sinais certos
        case (codigo_operacao)
            // Instrucoes de carregamento (lh)
            CARREGAR: begin
                if (funcao3 == LH) begin
                    escrever_registrador = 1'b1;    // Vai escrever no registrador
                    ler_memoria = 1'b1;             // Vai ler da memoria
                    fonte_ula = 1'b1;               // ULA usa imediato (offset)
                    operacao_ula = 4'b0000;         // Soma para calcular endereco
                    memoria_para_registrador = 2'b01; // Dados vem da memoria
                    fonte_imediato = 2'b00;         // Formato tipo I
                end
            end
            
            // Instrucoes de armazenamento (sh)
            ARMAZENAR: begin
                if (funcao3 == SH) begin
                    escrever_memoria = 1'b1;        // Vai escrever na memoria
                    fonte_ula = 1'b1;               // ULA usa imediato (offset)
                    operacao_ula = 4'b0000;         // Soma para calcular endereco
                    fonte_imediato = 2'b01;         // Formato tipo S
                end
            end
            
            // Instrucoes de desvio (beq)
            DESVIO: begin
                if (funcao3 == BEQ) begin
                    branch = 1'b1;                  // E um desvio
                    operacao_ula = 4'b0001;         // Subtracao para comparar
                    fonte_imediato = 2'b10;         // Formato tipo SB
                end
            end
            
            // Operacoes com imediato (andi, srl)
            OP_IMEDIATO: begin
                case (funcao3)
                    // ANDI - AND com imediato
                    ANDI: begin
                        escrever_registrador = 1'b1;    // Vai escrever no registrador
                        fonte_ula = 1'b1;               // ULA usa imediato
                        operacao_ula = 4'b0010;         // Operacao AND
                        fonte_imediato = 2'b00;         // Formato tipo I
                    end
                    // SRL - Shift right logical
                    SRL: begin
                        escrever_registrador = 1'b1;    // Vai escrever no registrador
                        fonte_ula = 1'b1;               // ULA usa imediato
                        operacao_ula = 4'b0100;         // Operacao SRL
                        fonte_imediato = 2'b00;         // Formato tipo I
                    end
                endcase
            end
            
            // Operacoes entre registradores (sub, or)
            OP_REGISTRADOR: begin
                case (funcao3)
                    // SUB - Subtracao
                    SUB: begin
                        if (funcao7 == 7'b0100000) begin
                            escrever_registrador = 1'b1;    // Vai escrever no registrador
                            operacao_ula = 4'b0001;         // Operacao subtracao
                        end
                    end
                    // OR - OR logico
                    OR: begin
                        escrever_registrador = 1'b1;        // Vai escrever no registrador
                        operacao_ula = 4'b0011;             // Operacao OR
                    end
                endcase
            end
        endcase
    end

endmodule
