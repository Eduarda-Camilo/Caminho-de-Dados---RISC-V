# TRABALHO PRÁTICO 02 - CAMINHO DE DADOS RISC-V

## Sobre o Projeto

Implementação de um caminho de dados RISC-V simplificado em Verilog.
Processador de ciclo único com instruções: lh, sh, sub, or, andi, srl, beq.

**Integrantes:** Eduarda Gomes e Lucas Afonso

## Como Executar

### Pré-requisitos
- Icarus Verilog (iverilog)
- Montador RISC-V (incluído no projeto)

### Passos para Execução

1. **Descompactar o montador:**
   ```bash
   # IMPORTANTE: Descompactar o arquivo montador-riscv-oac-main.zip
   # para que o TP02 funcione corretamente
   ```

2. **Gerar arquivo binário:**
   ```bash
   cd montador-riscv-oac-main
   .\montador.exe ..\teste.asm -o ..\teste_binario.txt
   ```

3. **Compilar o projeto:**
   ```bash
   iverilog -o sim testbench.v caminho_dados_riscv.v unidade_controle.v ula.v banco_registradores.v memoria_dados.v memoria_instrucoes.v extensor_imediato.v
   ```

4. **Executar simulação:**
   ```bash
   vvp sim
   ```

## Arquivos do Projeto

### Código Verilog
- `caminho_dados_riscv.v` - Módulo principal do processador
- `unidade_controle.v` - Unidade de controle
- `ula.v` - Unidade lógica e aritmética
- `banco_registradores.v` - Banco de registradores
- `memoria_dados.v` - Memória de dados
- `memoria_instrucoes.v` - Memória de instruções
- `extensor_imediato.v` - Extensor de imediato
- `testbench.v` - Testbench para simulação

### Arquivos de Entrada
- `teste.asm` - Código assembly de teste
- `teste_binario.txt` - Código binário gerado pelo montador
- `registradores_iniciais.txt` - Estado inicial dos registradores
- `memoria_inicial.txt` - Estado inicial da memória

### Montador (TP01)
- `montador-riscv-oac-main.zip` - **DESCOMPACTAR ANTES DE USAR**

## Instruções Implementadas

- `lh` (Load Halfword) - Carrega 16 bits da memória
- `sh` (Store Halfword) - Armazena 16 bits na memória
- `sub` (Subtract) - Subtração entre registradores
- `or` (OR) - Operação lógica OR
- `andi` (AND Immediate) - AND com valor imediato
- `srl` (Shift Right Logical) - Deslocamento lógico para direita
- `beq` (Branch if Equal) - Desvio condicional

## Resultados Esperados

A simulação deve mostrar:
- Estado final de todos os 32 registradores
- Primeiras 32 posições da memória
- Execução correta de todas as instruções
- Branch funcionando adequadamente
