# Codigo de teste para o caminho de dados RISC-V
# Instrucoes permitidas: lh, sh, sub, or, andi, srl, beq
# Adaptado do exemplo do trabalho para usar apenas as instrucoes do grupo

# Inicializar registradores com valores de teste
andi x1, x0, 7       # x1 = x0 & 7 = 0 & 7 = 0
andi x2, x0, 3       # x2 = x0 & 3 = 0 & 3 = 0

# Operacoes aritmeticas e logicas
sub x3, x1, x2       # x3 = x1 - x2 = 0 - 0 = 0
or x4, x1, x2        # x4 = x1 | x2 = 0 | 0 = 0
srl x5, x1, 1        # x5 = x1 >> 1 = 0 >> 1 = 0

# Operacoes de memoria
sh x1, 4(x0)         # Salvar x1 (0) na memoria[4]
lh x6, 4(x0)         # Carregar da memoria[4] para x6

# Branch (desvio condicional)
beq x6, x1, SAIDA    # Se x6 == x1 (0 == 0), pular para SAIDA
andi x7, x0, 1       # Esta linha nao deve ser executada se o branch funcionar

SAIDA:
andi x8, x1, 15      # x8 = x1 & 15 = 0 & 15 = 0
or x9, x8, x2        # x9 = x8 | x2 = 0 | 0 = 0



//x0 sempre é zero
x1 e x2 ficam zero por causa do x0
x3, x4, x5 ficam zero por causa de x1 e x2
A memória fica zero por causa de x1
x6 fica zero por causa da memória
E assim por diante...//