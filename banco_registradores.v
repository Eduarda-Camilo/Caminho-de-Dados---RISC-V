// Banco de registradores do processador RISC-V
// Aqui e onde guardo os 32 registradores (x0 a x31)
// O x0 sempre retorna zero, mesmo se eu tentar escrever nele

module banco_registradores(
    input wire clk,                    // Clock do sistema
    input wire reset,                  // Reset (zera tudo)
    input wire escrever_registrador,   // Se vai escrever no registrador
    input wire [4:0] registrador_leitura1, // Qual registrador ler primeiro
    input wire [4:0] registrador_leitura2, // Qual registrador ler segundo
    input wire [4:0] registrador_escrita,  // Qual registrador escrever
    input wire [31:0] dados_escrita,   // O que escrever no registrador
    output wire [31:0] dados_leitura1, // O que li do primeiro registrador
    output wire [31:0] dados_leitura2  // O que li do segundo registrador
);

    // Aqui e onde guardo os registradores
    // Cada um tem 32 bits
    reg [31:0] registradores [0:31];
    integer i;  // Para fazer loops
    
    // Leitura dos registradores
    // Sempre posso ler, nao depende de clock
    // Se tentar ler x0, sempre retorna zero
    assign dados_leitura1 = (registrador_leitura1 == 5'b0) ? 32'h0 : registradores[registrador_leitura1];
    assign dados_leitura2 = (registrador_leitura2 == 5'b0) ? 32'h0 : registradores[registrador_leitura2];
    
    // Escrita nos registradores
    // So escreve na borda de subida do clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset - zera todos os registradores
            for (i = 0; i < 32; i = i + 1) begin
                registradores[i] <= 32'h0;  // Registrador i = 0
            end
        end
        else if (escrever_registrador && registrador_escrita != 5'b0) begin
            // Escrita - so escreve se:
            // 1. O sinal de escrita estiver ativo
            // 2. Nao for o registrador x0 (x0 nunca e escrito)
            registradores[registrador_escrita] <= dados_escrita;
        end
    end

endmodule
