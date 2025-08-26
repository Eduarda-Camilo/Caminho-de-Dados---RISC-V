# Trabalho Prático 02 - Caminho de Dados RISC-V

## 📋 Descrição
Implementação de um caminho de dados simplificado do processador RISC-V em Verilog, suportando as instruções: `lh`, `sh`, `sub`, `or`, `andi`, `srl`, `beq`.

## 👥 Integrantes
- **Eduarda Gomes**
- **Lucas Afonso**

## 🏗️ Estrutura do Projeto

### Arquivos Principais (Verilog)
- `caminho_dados_riscv.v` - Módulo principal do processador
- `unidade_controle.v` - Unidade de controle
- `ula.v` - Unidade lógica e aritmética
- `banco_registradores.v` - Banco de registradores
- `memoria_dados.v` - Memória de dados
- `memoria_instrucoes.v` - Memória de instruções
- `extensor_imediato.v` - Extensor de imediato
- `testbench.v` - Testbench para simulação

### Arquivos de Teste
- `teste.asm` - Código assembly de teste
- `teste_binario.txt` - Código binário gerado pelo montador
- `registradores_iniciais.txt` - Estado inicial dos registradores
- `memoria_inicial.txt` - Estado inicial da memória

### Montador (TP01)
- `montador-riscv-oac-main/` - Pasta contendo o montador do TP01

## 🚀 Como Executar

### 1. Gerar arquivo binário
```bash
cd montador-riscv-oac-main
.\montador.exe ..\teste.asm -o ..\teste_binario.txt
```

### 2. Compilar projeto
```bash
iverilog -o sim testbench.v caminho_dados_riscv.v unidade_controle.v ula.v banco_registradores.v memoria_dados.v memoria_instrucoes.v extensor_imediato.v
```

### 3. Executar simulação
```bash
vvp sim
```

## 📊 Resultados Esperados
A simulação deve mostrar:
- Execução de todas as instruções implementadas
- Estado final dos 32 registradores
- Estado das primeiras 32 posições da memória
- Monitoramento detalhado de cada ciclo de execução

## 🔧 Requisitos
- Icarus Verilog (iverilog)
- Montador do TP01 (incluído na pasta montador-riscv-oac-main)

## 📝 Observações
- O projeto implementa apenas as instruções especificadas no trabalho
- Integração completa com o montador do TP01
- Testbench com saída detalhada para verificação do funcionamento
