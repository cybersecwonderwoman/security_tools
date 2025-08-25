# 🎯 Guia do Menu Interativo - Security Analyzer Tool

## Visão Geral

O Security Analyzer Tool agora possui um **menu interativo** com arte ASCII personalizada e o logo **@cybersecwonderwoman**, proporcionando uma experiência de usuário mais amigável e profissional.

## 🚀 Como Iniciar

### Opção 1: Script de Inicialização (Recomendado)
```bash
cd /home/anny-ribeiro/amazonQ/app
./start.sh
```

### Opção 2: Menu Direto
```bash
cd /home/anny-ribeiro/amazonQ/app
./menu.sh
```

### Opção 3: Linha de Comando Tradicional
```bash
cd /home/anny-ribeiro/amazonQ/app
./security_analyzer.sh [opções]
```

## 🎨 Interface do Menu

### Banner Principal
```
╔══════════════════════════════════════════════════════════════════════════════╗
║   ███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗            ║
║   ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝            ║
║   ███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝             ║
║   ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝              ║
║   ███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║               ║
║   ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝               ║
║                                                                              ║
║   ████████╗ ██████╗  ██████╗ ██╗                                            ║
║   ╚══██╔══╝██╔═══██╗██╔═══██╗██║                                            ║
║      ██║   ██║   ██║██║   ██║██║                                            ║
║      ██║   ██║   ██║██║   ██║██║                                            ║
║      ██║   ╚██████╔╝╚██████╔╝███████╗                                       ║
║      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝                                       ║
║                                                                              ║
║                    🛡️  FERRAMENTA AVANÇADA DE SEGURANÇA  🛡️                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

                           @cybersecwonderwoman
```

## 📋 Opções do Menu Principal

### 🔍 Análises de Segurança
- **[1] 📁 Analisar Arquivo** - Verificar arquivos suspeitos
- **[2] 🌐 Analisar URL** - Verificar links maliciosos  
- **[3] 🏠 Analisar Domínio** - Investigar domínios suspeitos
- **[4] 🔢 Analisar Hash** - Consultar hashes em bases de dados
- **[5] 📧 Analisar Email** - Verificar endereços de email
- **[6] 📋 Analisar Cabeçalho** - Analisar headers de email

### ⚙️ Configuração e Monitoramento
- **[7] ⚙️ Configurar APIs** - Configurar chaves de acesso
- **[8] 📊 Ver Estatísticas** - Relatórios de uso
- **[9] 📝 Ver Logs** - Visualizar logs de análise
- **[10] 🧪 Executar Testes** - Testar funcionalidades

### 📚 Informações e Ajuda
- **[11] 📚 Ajuda** - Manual de uso
- **[12] ℹ️ Sobre** - Informações da ferramenta

### 🚪 Saída
- **[0] 🚪 Sair** - Encerrar programa

## 🎯 Fluxo de Uso

### 1. Primeira Execução
```bash
./start.sh
# Escolher opção [1] Menu Interativo
# Configurar APIs com opção [7]
# Executar testes com opção [10]
```

### 2. Análise Rápida
```bash
./start.sh
# Escolher opção [1] Menu Interativo
# Selecionar tipo de análise desejada
# Inserir alvo (arquivo, URL, domínio, etc.)
# Aguardar resultados
```

### 3. Monitoramento
```bash
./menu.sh
# Opção [8] para ver estatísticas
# Opção [9] para ver logs
```

## 🎨 Características Visuais

### Sistema de Cores
- 🔵 **Azul**: Informações e títulos
- 🟢 **Verde**: Opções de análise e sucesso
- 🟡 **Amarelo**: Avisos e destaques
- 🔴 **Vermelho**: Erros e saída
- 🟣 **Roxo**: Logo @cybersecwonderwoman
- 🔷 **Ciano**: Banner principal

### Elementos Visuais
- ✅ Bordas decorativas com caracteres Unicode
- ✅ Emojis para identificação rápida das opções
- ✅ Prompt personalizado com seta (➤)
- ✅ Limpeza automática da tela
- ✅ Formatação consistente

## 🔧 Funcionalidades Avançadas

### Menu de Seleção de Modo
O script `start.sh` oferece:
- **Menu Interativo**: Interface amigável
- **Linha de Comando**: Modo tradicional
- **Ajuda**: Documentação rápida
- **Testes**: Verificação de funcionalidades

### Validação de Entrada
- ✅ Verificação de arquivos existentes
- ✅ Validação de URLs
- ✅ Sanitização de entrada
- ✅ Tratamento de erros

### Navegação Intuitiva
- ✅ Retorno automático ao menu principal
- ✅ Confirmação antes de sair
- ✅ Mensagens de status claras
- ✅ Pausa para leitura de resultados

## 📱 Exemplos de Uso

### Análise de Arquivo Suspeito
```
[Menu] → [1] Analisar Arquivo
Digite o caminho: /downloads/suspicious.exe
[Análise executada]
[Pressione ENTER para continuar]
[Retorna ao menu]
```

### Configuração de APIs
```
[Menu] → [7] Configurar APIs
VirusTotal API Key: [inserir chave]
Shodan API Key: [inserir chave]
[Configuração salva]
[Retorna ao menu]
```

### Visualização de Estatísticas
```
[Menu] → [8] Ver Estatísticas
=== Resumo de Análises ===
Total: 25 análises
Arquivos: 10
URLs: 8
Domínios: 5
Hashes: 2
```

## 🚀 Vantagens do Menu Interativo

### Para Usuários Iniciantes
- ✅ Interface intuitiva
- ✅ Não precisa memorizar comandos
- ✅ Validação automática de entrada
- ✅ Mensagens de ajuda contextuais

### Para Usuários Avançados
- ✅ Acesso rápido a todas as funcionalidades
- ✅ Visualização de estatísticas
- ✅ Monitoramento de logs
- ✅ Execução de testes automatizados

### Para Administradores
- ✅ Configuração centralizada
- ✅ Monitoramento de uso
- ✅ Interface profissional
- ✅ Branding personalizado

## 🔄 Integração com Linha de Comando

O menu não substitui a funcionalidade de linha de comando:

```bash
# Uso direto (sem menu)
./security_analyzer.sh -f arquivo.exe

# Uso através do inicializador
./start.sh -f arquivo.exe

# Menu interativo
./start.sh
```

## 🎓 Dicas de Uso

### Primeira Vez
1. Execute `./start.sh`
2. Escolha opção [4] para executar testes
3. Configure APIs com opção [7]
4. Teste uma análise simples

### Uso Diário
1. Execute `./menu.sh` diretamente
2. Use as opções 1-6 para análises
3. Monitore com opções 8-9
4. Configure conforme necessário

### Automação
- Use linha de comando para scripts
- Use menu para análises manuais
- Combine ambos conforme necessário

## 🏆 Conclusão

O menu interativo do Security Analyzer Tool oferece:

- **Experiência Profissional**: Interface polida com branding
- **Facilidade de Uso**: Navegação intuitiva
- **Funcionalidade Completa**: Acesso a todas as features
- **Flexibilidade**: Coexiste com linha de comando

O logo **@cybersecwonderwoman** está presente em todas as telas, garantindo identificação e branding consistente da ferramenta.

---

**Desenvolvido com ❤️ por @cybersecwonderwoman**
