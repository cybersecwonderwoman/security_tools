# 🚀 Quick Start - Security Analyzer Tool

## Instalação Rápida

```bash
# 1. Navegar para o diretório
cd /home/anny-ribeiro/amazonQ/app

# 2. Instalar dependências
./install_dependencies.sh

# 3. Configurar APIs (opcional mas recomendado)
./security_analyzer.sh --config
```

## 🎯 Modos de Uso

### 1. Menu Interativo com ASCII Art (Recomendado)
```bash
# Inicializador com seleção de modo
./start.sh

# Menu direto com arte "SECURITY TOOL"
./menu.sh
```

**Características:**
- 🎨 Arte ASCII profissional
- 🏷️ Logo @cybersecwonderwoman
- 📋 12 opções organizadas
- 🌈 Interface colorida

### 2. Linha de Comando Tradicional
```bash
# Uso direto
./security_analyzer.sh [opções]

# Através do inicializador
./start.sh -f arquivo.exe
```

## 📋 Opções do Menu

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

## Uso Básico

### Analisar um arquivo suspeito
```bash
./security_analyzer.sh -f /path/to/suspicious_file.exe
```

### Analisar uma URL
```bash
./security_analyzer.sh -u https://suspicious-site.com
```

### Analisar um domínio
```bash
./security_analyzer.sh -d malicious-domain.com
```

### Analisar um hash
```bash
./security_analyzer.sh -h 5d41402abc4b2a76b9719d911017c592
```

### Analisar cabeçalho de email
```bash
./security_analyzer.sh --header examples/sample_email_header.txt
```

## Testes Rápidos

### Via Menu Interativo
```bash
./menu.sh
# Escolher [10] 🧪 Executar Testes
```

### Via Linha de Comando
```bash
# Executar exemplos de teste
./examples/test_samples.sh

# Testar com arquivo de exemplo
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /tmp/eicar.txt
./security_analyzer.sh -f /tmp/eicar.txt
rm /tmp/eicar.txt
```

## APIs Recomendadas (Gratuitas)

1. **VirusTotal**: https://www.virustotal.com/gui/join-us
2. **URLScan.io**: https://urlscan.io/user/signup
3. **Shodan**: https://account.shodan.io/register
4. **Hybrid Analysis**: https://www.hybrid-analysis.com/signup

## Estrutura de Logs

- **Logs principais**: `~/.security_analyzer/analysis.log`
- **Relatórios**: `~/.security_analyzer/reports/`
- **Configurações**: `~/.security_analyzer/api_keys.conf`

## Comandos Úteis

```bash
# Ver logs em tempo real
tail -f ~/.security_analyzer/analysis.log

# Limpar cache
rm -rf ~/.security_analyzer/cache/*

# Reconfigurar APIs
./security_analyzer.sh --config

# Verificar dependências
./security_analyzer.sh --help
```

## Interpretação de Resultados

- 🟢 **Verde**: Limpo/Seguro
- 🟡 **Amarelo**: Suspeito/Atenção
- 🔴 **Vermelho**: Malicioso/Perigoso

## Troubleshooting Rápido

### Erro de dependências
```bash
sudo apt-get install curl jq dnsutils whois file
```

### Erro de permissão
```bash
chmod +x security_analyzer.sh start.sh menu.sh
```

### APIs não funcionando
```bash
# Verificar configuração
cat ~/.security_analyzer/api_keys.conf

# Reconfigurar
./security_analyzer.sh --config
```

## 🎨 Interface do Menu

```
╔══════════════════════════════════════════════════════════════════════════════╗
║   ███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗            ║
║   ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝            ║
║   ███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝             ║
║   ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝              ║
║   ███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║               ║
║   ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝               ║
║                                                                              ║
║                    🛡️  FERRAMENTA AVANÇADA DE SEGURANÇA  🛡️                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

                           @cybersecwonderwoman
```

---

**⚠️ Importante**: Use apenas para fins legítimos de segurança!

**Desenvolvido por @cybersecwonderwoman**
