# 🔧 Solução de Problemas - Análise de Cabeçalhos de Email

## 🚨 Problemas Comuns e Soluções

### 1. "Arquivo não encontrado"

#### Problema:
```
Erro: Arquivo não encontrado: /caminho/para/arquivo.txt
```

#### Soluções:
```bash
# Verificar se o arquivo existe
ls -la /caminho/para/arquivo.txt

# Verificar o diretório atual
pwd

# Usar caminho absoluto
./security_analyzer.sh --header /home/usuario/email_headers.txt

# Ou caminho relativo
./security_analyzer.sh --header ./meu_arquivo.txt
```

### 2. "Sem permissão para ler o arquivo"

#### Problema:
```
Erro: Sem permissão para ler o arquivo: arquivo.txt
```

#### Solução:
```bash
# Dar permissão de leitura
chmod +r arquivo.txt

# Ou permissões completas
chmod 644 arquivo.txt

# Verificar permissões
ls -la arquivo.txt
```

### 3. "Arquivo está vazio"

#### Problema:
```
Erro: Arquivo está vazio: arquivo.txt
```

#### Soluções:
```bash
# Verificar tamanho do arquivo
wc -c arquivo.txt

# Ver conteúdo do arquivo
cat arquivo.txt

# Verificar se há conteúdo oculto
hexdump -C arquivo.txt | head
```

### 4. Script não consegue ler o arquivo

#### Diagnóstico Completo:
```bash
# Usar o script de diagnóstico
./debug_header.sh /caminho/para/arquivo.txt

# Ou verificar manualmente:
file /caminho/para/arquivo.txt
head -5 /caminho/para/arquivo.txt
```

## 📋 Como Preparar Cabeçalhos de Email

### 1. Extrair de Clientes de Email

#### Gmail (Web):
1. Abrir o email
2. Clicar nos 3 pontos (⋮)
3. Selecionar "Mostrar original"
4. Copiar todo o conteúdo
5. Salvar em arquivo .txt

#### Outlook (Desktop):
1. Abrir o email
2. Arquivo → Propriedades
3. Copiar "Cabeçalhos da Internet"
4. Salvar em arquivo .txt

#### Thunderbird:
1. Abrir o email
2. Ver → Cabeçalhos → Todos
3. Copiar cabeçalhos visíveis
4. Salvar em arquivo .txt

### 2. Formato Correto do Arquivo

#### Exemplo de cabeçalho válido:
```
Return-Path: <sender@example.com>
Delivered-To: recipient@domain.com
Received: from mail.example.com (mail.example.com [1.2.3.4])
    by mx.domain.com (Postfix) with ESMTP id ABC123
    for <recipient@domain.com>; Mon, 18 Jul 2025 16:00:00 +0000
From: "Sender Name" <sender@example.com>
To: recipient@domain.com
Subject: Email Subject Here
Date: Mon, 18 Jul 2025 16:00:00 +0000
Message-ID: <unique-id@example.com>
```

#### ❌ Formato incorreto:
- Apenas o corpo do email
- Cabeçalhos incompletos
- Arquivo binário (.eml sem conversão)

## 🧪 Testes e Validação

### 1. Testar com Arquivo de Exemplo
```bash
# Usar o arquivo de exemplo incluído
./security_analyzer.sh --header examples/sample_email_header.txt

# Via menu interativo
./menu.sh
# [6] 📋 Analisar Cabeçalho
# Digite: examples/sample_email_header.txt
```

### 2. Criar Arquivo de Teste
```bash
# Criar arquivo de teste simples
cat > test_header.txt << 'EOF'
Return-Path: <test@example.com>
From: "Test Sender" <test@example.com>
To: recipient@domain.com
Subject: Test Email
Date: Mon, 18 Jul 2025 16:00:00 +0000
Message-ID: <test123@example.com>
Received: from mail.example.com (mail.example.com [1.2.3.4])
    by mx.domain.com (Postfix) with ESMTP id TEST123
EOF

# Testar
./security_analyzer.sh --header test_header.txt
```

### 3. Script de Diagnóstico
```bash
# Usar o script de diagnóstico completo
./debug_header.sh /caminho/para/arquivo.txt
```

## 🔍 O que a Análise Detecta

### ✅ Informações Extraídas:
- **Remetente e destinatário**
- **Assunto e data**
- **Caminho do email** (servidores Received)
- **Autenticação** (SPF, DKIM, DMARC)
- **IPs públicos** dos servidores
- **Indicadores de phishing/spam**

### 🚨 Indicadores de Suspeita:
- **SPF/DMARC falhou**
- **Spoofing de marca conhecida**
- **Emails em massa**
- **Muitos hops** (>8 servidores)
- **IPs em blacklists**

## 📁 Formatos de Arquivo Suportados

### ✅ Suportados:
- **Arquivo .txt** com cabeçalhos
- **Arquivo .log** com cabeçalhos
- **Qualquer arquivo texto** com cabeçalhos válidos

### ❌ Não Suportados Diretamente:
- **Arquivos .eml** (precisam ser convertidos)
- **Arquivos .msg** (Outlook, precisam ser convertidos)
- **Arquivos binários**

### Conversão de .eml para .txt:
```bash
# Extrair cabeçalhos de arquivo .eml
head -50 arquivo.eml > cabecalhos.txt

# Ou usar ferramenta específica
strings arquivo.eml | head -50 > cabecalhos.txt
```

## 🛠️ Comandos Úteis para Diagnóstico

### Verificar Arquivo:
```bash
# Informações do arquivo
file arquivo.txt
stat arquivo.txt

# Primeiras linhas
head -10 arquivo.txt

# Buscar cabeçalhos específicos
grep -i "^From:\|^To:\|^Subject:" arquivo.txt
```

### Verificar Codificação:
```bash
# Detectar codificação
file -i arquivo.txt

# Converter se necessário (de Windows para Linux)
dos2unix arquivo.txt
```

### Verificar Conteúdo Oculto:
```bash
# Ver caracteres especiais
cat -A arquivo.txt | head -5

# Ver em hexadecimal
hexdump -C arquivo.txt | head -5
```

## 📞 Suporte Adicional

### Se o problema persistir:

1. **Execute o diagnóstico completo**:
   ```bash
   ./debug_header.sh seu_arquivo.txt
   ```

2. **Verifique os logs**:
   ```bash
   tail -20 ~/.security_analyzer/analysis.log
   ```

3. **Teste com arquivo de exemplo**:
   ```bash
   ./security_analyzer.sh --header examples/sample_email_header.txt
   ```

4. **Verifique dependências**:
   ```bash
   ./security_analyzer.sh --help
   ```

## ✅ Exemplo de Uso Bem-Sucedido

```bash
# 1. Navegar para o diretório
cd /home/anny-ribeiro/amazonQ/app

# 2. Verificar se o arquivo existe e é legível
ls -la meu_cabecalho.txt

# 3. Executar análise
./security_analyzer.sh --header meu_cabecalho.txt

# 4. Ou usar menu interativo
./menu.sh
# [6] 📋 Analisar Cabeçalho
# Digite o caminho completo do arquivo
```

**Resultado esperado**: Análise completa com informações de autenticação, IPs, e indicadores de suspeita.

---

**💡 Dica**: Use sempre caminhos absolutos ou relativos corretos, e certifique-se de que o arquivo contém cabeçalhos de email válidos!
