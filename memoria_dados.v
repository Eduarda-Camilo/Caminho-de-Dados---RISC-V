// Memoria de dados do processador RISC-V
// Aqui e onde guardo os dados que posso ler e escrever
// Uso para as instrucoes lh e sh

module memoria_dados(
    input wire clk,                    // Clock
    input wire reset,                  // Reset (zera tudo)
    input wire [31:0] endereco,        // Qual endereco acessar
    input wire [31:0] dados_escrita,   // O que escrever na memoria
    input wire ler_memoria,            // Se vai ler da memoria
    input wire escrever_memoria,       // Se vai escrever na memoria
    output reg [31:0] dados_leitura    // O que li da memoria
);

    // Aqui e onde guardo os dados
    // Memoria organizada em bytes (8 bits cada)
    // Tenho 1024 bytes = 1KB
    reg [7:0] memoria [0:1023];
    integer i;  // Para fazer loops
    
    // Calculo o endereco de byte
    // Pego so os 10 bits menos significativos do endereco
    wire [9:0] endereco_byte = endereco[9:0];
    
    // Escrita na memoria
    // So escreve na borda de subida do clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset - zera toda a memoria
            for (i = 0; i < 1024; i = i + 1) begin
                memoria[i] <= 8'h0;  // Byte i = 0
            end
        end
        else if (escrever_memoria) begin
            // Escrita - guardo halfword (16 bits)
            // Instrucao: sh (Store Halfword)
            // Little-endian: byte menos significativo primeiro
            memoria[endereco_byte] <= dados_escrita[7:0];      // Byte menos significativo
            memoria[endereco_byte + 1] <= dados_escrita[15:8]; // Byte mais significativo
        end
    end
    
    // Leitura da memoria
    // Sempre posso ler, nao depende de clock
    always @(*) begin
        if (ler_memoria) begin
            // Leitura - leio halfword (16 bits)
            // Instrucao: lh (Load Halfword)
            // Estendo para 32 bits com extensao de sinal
            dados_leitura = {{16{memoria[endereco_byte + 1][7]}}, memoria[endereco_byte + 1], memoria[endereco_byte]};
        end
        else begin
            // Se nao estou lendo, retorno zero
            dados_leitura = 32'h0;
        end
    end

endmodule
