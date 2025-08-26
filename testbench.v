`timescale 1ns / 1ps

// Testbench do processador RISC-V
// Vou testar se o caminho de dados esta funcionando
// Instrucoes que vou testar: lh, sh, sub, or, andi, srl, beq

module testbench();

    // Sinais que preciso para conectar com o processador
    reg clk;                    // Clock para fazer o processador funcionar
    reg reset;                  // Reset para comecar do zero
    wire [31:0] pc_saida;       // Contador de programa (onde estou no codigo)
    wire [31:0] instrucao_saida; // Instrucao que esta sendo executada
    wire [31:0] resultado_ula_saida; // Resultado da operacao
    wire [31:0] dados_memoria_saida; // Dados da memoria
    
    // Conecto o processador aqui
    caminho_dados_riscv caminho_dados(
        .clk(clk),                          // Clock
        .reset(reset),                      // Reset
        .pc_saida(pc_saida),                // PC
        .instrucao_saida(instrucao_saida),  // Instrucao
        .resultado_ula_saida(resultado_ula_saida), // Resultado ULA
        .dados_memoria_saida(dados_memoria_saida)  // Dados memoria
    );
    
    // Gero o clock automatico
    // Cada ciclo dura 10ns (5ns alto, 5ns baixo)
    initial begin
        clk = 0;                    // Comeco com clock baixo
        forever #5 clk = ~clk;      // Inverto o clock a cada 5ns
    end
    
    // Aqui e onde faco o teste principal
    initial begin
        // Primeiro faco reset para comecar limpo
        reset = 1;                  // Ativo o reset
        #20;                        // Espero um pouco
        reset = 0;                  // Desativo o reset
        
        // Deixo o processador executar por um tempo
        #100;                       // 100ns de execucao
        
        // Agora mostro os resultados
        $display("\n=== RESULTADOS FINAIS ===");
        $display("PC final: %h", pc_saida);           // Onde parei
        $display("Ultima instrucao: %h", instrucao_saida); // O que executei por ultimo
        
        // Mostro todos os registradores (requisito do trabalho)
        $display("\n=== ESTADO DOS REGISTRADORES ===");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("Register [%2d]: %d", i, caminho_dados.registradores.registradores[i]);
        end
        
        // Mostro a memoria (requisito do trabalho)
        $display("\n=== PRIMEIRAS 32 POSICOES DA MEMORIA ===");
        for (integer i = 0; i < 32; i = i + 1) begin
            // Junto 4 bytes para formar uma palavra
            $display("Mem[%d]: %h", i, {caminho_dados.memoria_dados.memoria[i*4+3], 
                                       caminho_dados.memoria_dados.memoria[i*4+2], 
                                       caminho_dados.memoria_dados.memoria[i*4+1], 
                                       caminho_dados.memoria_dados.memoria[i*4]});
        end
        
        $finish;                    // Termino a simulacao
    end
    
    // Sinais para monitorar o que esta acontecendo
    // Preciso disso para nao dar erro no $monitor
    wire [31:0] ciclo_atual;       // Qual ciclo estou
    wire [31:0] dados_registrador1_monitor; // Dados do registrador 1
    wire [31:0] dados_registrador2_monitor; // Dados do registrador 2
    wire [3:0] op_ula_monitor;     // Operacao da ULA
    wire [4:0] registrador_destino_monitor;         // Registrador destino
    wire [4:0] registrador_origem1_monitor;        // Registrador origem 1
    wire escrever_monitor;         // Se vai escrever no registrador
    
    // Conecto os sinais de monitoramento
    assign ciclo_atual = $time/10;  // Calculo o numero do ciclo
    assign dados_registrador1_monitor = caminho_dados.dados_registrador1;
    assign dados_registrador2_monitor = caminho_dados.dados_registrador2;
    assign op_ula_monitor = caminho_dados.operacao_ula;
    assign registrador_destino_monitor = caminho_dados.registrador_destino;
    assign registrador_origem1_monitor = caminho_dados.registrador_origem1;
    assign escrever_monitor = caminho_dados.escrever_registrador;
    
    // Monitoro cada ciclo para ver o que esta acontecendo
    // Isso vai me ajudar a debugar se der algum problema
    initial begin
        $monitor("Ciclo: %0d | PC: %h | Instrucao: %h | Resultado_ULA: %h | Escrever_Registrador: %b | Dados_Registrador1: %h | Dados_Registrador2: %h | Operacao: %b | Registrador_Destino: %d | Registrador_Origem1: %d | Escrever: %b", 
                 ciclo_atual, pc_saida, instrucao_saida, resultado_ula_saida, 
                 caminho_dados.escrever_registrador, 
                 dados_registrador1_monitor, 
                 dados_registrador2_monitor, 
                 op_ula_monitor,
                 registrador_destino_monitor,
                 registrador_origem1_monitor,
                 escrever_monitor);
    end
    
    // Mostro quando um registrador e escrito
    // So para ver se esta funcionando mesmo.
    always @(posedge clk) begin
        if (caminho_dados.escrever_registrador && caminho_dados.registrador_destino != 0) begin
            $display("ESCRITA_REGISTRADOR: x%d = %h", caminho_dados.registrador_destino, caminho_dados.dados_memoria_saida);
        end
    end

endmodule
