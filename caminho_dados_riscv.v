module caminho_dados_riscv(
    input wire clk,
    input wire reset,
    output wire [31:0] pc_saida,
    output wire [31:0] instrucao_saida,
    output wire [31:0] resultado_ula_saida,
    output wire [31:0] dados_memoria_saida
);

    // Sinais internos

    reg [31:0] contador_programa;
    wire [31:0] proximo_contador_programa;
    wire [31:0] instrucao;
    wire [31:0] dados_registrador1, dados_registrador2;
    wire [31:0] resultado_ula;
    wire [31:0] dados_memoria;
    wire [31:0] imediato_estendido;
    wire [31:0] destino_branch;
    
    // Sinais de controle

    wire escrever_registrador;
    wire ler_memoria;
    wire escrever_memoria;
    wire fonte_ula;
    wire [3:0] operacao_ula;
    wire branch;
    wire [1:0] memoria_para_registrador;
    wire [1:0] fonte_imediato;
    
    // Decodificação da instrução - extraindo os campos da instrução de 32 bits
    // Cada campo tem uma posição específica na instrução conforme especificação RISC-V
    // IMPORTANTE: RISC-V usa little-endian, então os bits estão na ordem correta

    wire [6:0] codigo_operacao = instrucao[6:0];        // Opcode: define o tipo da instrução
    wire [2:0] funcao3 = instrucao[14:12];             // Funct3: especifica a operação específica
    wire [6:0] funcao7 = instrucao[31:25];             // Funct7: usado para algumas operações
    wire [4:0] registrador_origem1 = instrucao[19:15]; // rs1: primeiro registrador fonte
    wire [4:0] registrador_origem2 = instrucao[24:20]; // rs2: segundo registrador fonte
    wire [4:0] registrador_destino = instrucao[11:7];  // rd: registrador destino
    wire [11:0] imediato12 = instrucao[31:20];         // Imediato para instruções tipo I
    wire [11:0] imediato12_armazenamento = {instrucao[31:25], instrucao[11:7]}; // Imediato para store
    wire [12:0] imediato13_desvio = {instrucao[31], instrucao[7], instrucao[30:25], instrucao[11:8], 1'b0}; // Imediato para branch
    
    // Registrador Contador de Programa (PC) - controla qual instrução executar
    // Incrementa a cada ciclo de clock, exceto quando há um desvio (branch)

    always @(posedge clk or posedge reset) begin
        if (reset)
            contador_programa <= 32'h0;  // Reset: volta para o início do programa
        else
            contador_programa <= proximo_contador_programa;  // Próxima instrução
    end
    
    // Lógica do próximo PC - decide se vai para próxima instrução ou desvia
    // Se branch=1 E resultado_ula==0 (comparação verdadeira), então desvia

    assign proximo_contador_programa = (branch && (resultado_ula == 0)) ? destino_branch : (contador_programa + 4);
    assign destino_branch = contador_programa + (imediato13_desvio << 1);  // Calcula endereço do desvio
    
    // Memória de Instruções - armazena o programa a ser executado
    // Lê a instrução no endereço apontado pelo PC

    memoria_instrucoes memoria_instrucoes(
        .endereco(contador_programa),
        .instrucao(instrucao)
    );
    
    // Unidade de Controle - gera os sinais de controle baseado na instrução
    // Decodifica o opcode e funct3/funct7 para ativar os sinais corretos

    unidade_controle controle(
        .codigo_operacao(codigo_operacao),
        .funcao3(funcao3),
        .funcao7(funcao7),
        .escrever_registrador(escrever_registrador),    // Ativa escrita no banco de registradores
        .ler_memoria(ler_memoria),                      // Ativa leitura da memória de dados
        .escrever_memoria(escrever_memoria),            // Ativa escrita na memória de dados
        .fonte_ula(fonte_ula),                          // Escolhe entre registrador ou imediato
        .operacao_ula(operacao_ula),                    // Define qual operação a ULA fará
        .branch(branch),                                // Indica se é uma instrução de desvio
        .memoria_para_registrador(memoria_para_registrador), // Escolhe fonte dos dados para registrador
        .fonte_imediato(fonte_imediato)                 // Define qual formato de imediato usar
    );
    
    // Extensão de Imediato - converte imediato de 12 bits para 32 bits
    // Diferentes instruções usam diferentes formatos de imediato (I, S, SB)
    extensor_imediato extensor_imediato(
        .instrucao(instrucao),
        .fonte_imediato(fonte_imediato),
        .imediato_estendido(imediato_estendido)
    );
    
    // Banco de Registradores - 32 registradores de 32 bits cada
    // Permite leitura de 2 registradores e escrita em 1 por ciclo
    banco_registradores registradores(
        .clk(clk),
        .reset(reset),
        .escrever_registrador(escrever_registrador),     // Sinal de controle para escrita
        .registrador_leitura1(registrador_origem1),      // Endereço do primeiro registrador a ler
        .registrador_leitura2(registrador_origem2),      // Endereço do segundo registrador a ler
        .registrador_escrita(registrador_destino),       // Endereço do registrador a escrever
        .dados_escrita(dados_memoria_saida),             // Dados que serão escritos no registrador
        .dados_leitura1(dados_registrador1),             // Dados lidos do primeiro registrador
        .dados_leitura2(dados_registrador2)              // Dados lidos do segundo registrador
    );
    
    // ULA (Unidade Lógica e Aritmética) - executa as operações matemáticas e lógicas
    // fonte_ula decide se o segundo operando vem de um registrador ou do imediato
    ula unidade_logica_aritmetica(
        .operando_a(dados_registrador1),                 // Primeiro operando (sempre do registrador)
        .operando_b(fonte_ula ? imediato_estendido : dados_registrador2), // Segundo operando (registrador ou imediato)
        .operacao_ula(operacao_ula),                     // Define qual operação executar (soma, sub, and, or, srl)
        .funcao3(funcao3),                               // Usado para algumas operações específicas
        .funcao7(funcao7),                               // Usado para algumas operações específicas
        .resultado(resultado_ula)                        // Resultado da operação
    );
    
    // Memória de Dados - armazena os dados do programa
    // Para load/store: resultado_ula é usado como endereço da memória

    memoria_dados memoria_dados(
        .clk(clk),
        .reset(reset),
        .endereco(resultado_ula),                        // Endereço calculado pela ULA
        .dados_escrita(dados_registrador2),              // Dados a serem escritos na memória (store)
        .ler_memoria(ler_memoria),                       // Sinal de controle para leitura
        .escrever_memoria(escrever_memoria),             // Sinal de controle para escrita
        .dados_leitura(dados_memoria)                    // Dados lidos da memória (load)
    );
    
    // Multiplexador Memória-para-Registrador - escolhe qual dado escrever no registrador
    // 00: resultado da ULA (instruções aritméticas/lógicas)
    // 01: dados da memória (instruções load)
    // 10: PC+4 (para instruções de jal, não implementadas aqui)

    assign dados_memoria_saida = (memoria_para_registrador == 2'b00) ? resultado_ula :
                                (memoria_para_registrador == 2'b01) ? dados_memoria :
                                (memoria_para_registrador == 2'b10) ? contador_programa + 4 : 32'h0;
    
    // Saídas do módulo - para monitoramento e debug
    
    assign pc_saida = contador_programa;                 // Valor atual do PC
    assign instrucao_saida = instrucao;                  // Instrução sendo executada
    assign resultado_ula_saida = resultado_ula;          // Resultado da ULA

endmodule
