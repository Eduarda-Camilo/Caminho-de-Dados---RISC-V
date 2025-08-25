// Memoria de instrucoes do processador RISC-V
// Aqui e onde guardo o programa que vai ser executado
// Cada posicao tem uma instrucao de 32 bits

module memoria_instrucoes(
    input wire [31:0] endereco,        // Qual instrucao pegar
    output reg [31:0] instrucao        // A instrucao que peguei
);

    // Aqui e onde guardo as instrucoes
    // Memoria organizada em palavras de 32 bits
    // Tenho 256 instrucoes = 1KB
    reg [31:0] memoria [0:255];
    integer i;  // Para fazer loops
    
    // Inicializacao da memoria
    // Carrego o programa quando a simulacao comeca
    initial begin
        // Primeiro zero tudo
        for (i = 0; i < 256; i = i + 1) begin
            memoria[i] <= 32'h0;  // Instrucao i = nop
        end
        
        // Agora carrego o programa
        // Cada linha e uma instrucao do teste.asm
        // Os valores foram gerados pelo montador do TP01
        
        memoria[0] <= 32'b00000000011111111111000010010011;  // andi x1, x0, 7
        memoria[1] <= 32'b00000000001111111111000100010011;  // andi x2, x0, 3
        memoria[2] <= 32'b01000000001011111000000110110011;  // sub x3, x1, x2
        memoria[3] <= 32'b00000000001011111110001000110011;  // or x4, x1, x2
        memoria[4] <= 32'b00000001111111111101001010110011;  // srl x5, x1, 1
        memoria[5] <= 32'b00000000000100000001001000100011;  // sh x1, 4(x0)
        memoria[6] <= 32'b00000000010000000001001100000011;  // lh x6, 4(x0)
        memoria[7] <= 32'b00000001111100110000000001100011;  // beq x6, x1, SAIDA
        memoria[8] <= 32'b00000000000111111111001110010011;  // andi x7, x0, 1
        memoria[9] <= 32'b00000000111111111111010000010011;  // andi x8, x1, 15
        memoria[10] <= 32'b00000000001011111110010010110011; // or x9, x8, x2
        memoria[11] <= 32'h00000000;                        // nop (fim do programa)
    end
    
    // Leitura da instrucao
    // Sempre posso ler, nao depende de clock
    always @(*) begin
        // Calculo qual instrucao pegar
        // Divido o endereco por 4 porque cada instrucao ocupa 4 bytes
        // endereco[9:2] faz isso automaticamente
        instrucao = memoria[endereco[9:2]];
    end

endmodule
