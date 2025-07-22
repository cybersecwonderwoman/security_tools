# 🛡️ Security Analyzer Tool

**Ferramenta Avançada de Análise de Segurança da Informação**

Uma solução completa desenvolvida em Bash para análise profissional de ameaças cibernéticas, integrando múltiplas fontes de threat intelligence para detectar arquivos maliciosos, URLs perigosas, domínios suspeitos e atividades de phishing.

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Funcionalidades](#-funcionalidades)
- [Fontes de Threat Intelligence](#️-fontes-de-threat-intelligence-integradas)
- [Instalação](#-instalação)
- [Configuração](#-configuração)
- [Como Usar](#-como-usar)
- [Exemplos Práticos](#-exemplos-práticos)
- [Interpretação de Resultados](#-interpretação-de-resultados)
- [Estrutura de Arquivos](#-estrutura-de-arquivos)
- [Logs e Relatórios](#-logs-e-relatórios)
- [Solução de Problemas](#-solução-de-problemas)
- [Contribuição](#-contribuição)

---

## 🎯 Visão Geral

O **Security Analyzer Tool** é uma ferramenta de linha de comando que permite aos profissionais de segurança cibernética realizar análises abrangentes de potenciais ameaças. A ferramenta consulta automaticamente múltiplas bases de dados de threat intelligence e fornece relatórios detalhados sobre a segurança dos alvos analisados.

### ✨ Principais Características

- 🔍 **Análise Multifonte**: Integra 8+ fontes de threat intelligence
- 🎨 **Interface Colorida**: Output visual com códigos de cores para fácil interpretação
- 📊 **Relatórios Detalhados**: Geração automática de relatórios em JSON
- 📝 **Sistema de Logs**: Registro completo de todas as análises
- ⚡ **Performance Otimizada**: Cache inteligente e rate limiting
- 🔒 **Segurança**: Proteção de chaves de API e dados sensíveis

## 🔍 Funcionalidades

### 📁 Análise de Arquivos
- Cálculo automático de hashes (MD5, SHA1, SHA256)
- Verificação contra bases de malware conhecidas
- Detecção de tipo de arquivo e metadados
- Análise comportamental via Hybrid Analysis

### 🌐 Análise de URLs
- Verificação de reputação de URLs
- Análise de conteúdo via URLScan.io
- Detecção de phishing e malware
- Verificação de redirecionamentos suspeitos

### 🏠 Análise de Domínios
- Resolução DNS e verificação de registros
- Consulta WHOIS para informações de registro
- Verificação em blacklists conhecidas
- Análise de infraestrutura via Shodan

### 🔢 Análise de Hashes
- Suporte para MD5, SHA1, SHA256
- Consulta em múltiplas bases de malware
- Verificação de IOCs conhecidos
- Análise de família de malware

### 📧 Análise de Emails
- Verificação de domínios de email
- Análise completa de cabeçalhos
- Detecção de spoofing e phishing
- Verificação de autenticação (SPF, DKIM, DMARC)

### 📋 Análise de Cabeçalhos de Email
- Extração automática de IPs
- Verificação de blacklists de email
- Análise de caminho de entrega
- Detecção de indicadores de phishing

### 🌐 Análise de Endereços IP
- Geolocalização precisa de IPs
- Verificação em listas de bloqueio (RBLs)
- Análise de portas abertas
- Verificação de reputação
- Relatórios HTML interativos
- Integração com Shodan para análise de infraestrutura

## 🛠️ Fontes de Threat Intelligence Integradas

| Fonte | Tipo | Funcionalidade |
|-------|------|----------------|
| **VirusTotal** | Arquivos/URLs | Análise antivirus e detecção de malware |
| **URLScan.io** | URLs | Análise comportamental de websites |
| **Shodan** | Domínios/IPs | Informações de infraestrutura e serviços |
| **ThreatFox** | IOCs | Base de indicadores maliciosos |
| **AlienVault OTX** | Múltiplo | Threat intelligence colaborativa |
| **Hybrid Analysis** | Arquivos | Análise comportamental em sandbox |
| **MalShare** | Hashes | Base de amostras de malware |
| **Joe Sandbox** | Arquivos | Análise dinâmica avançada |

## 📦 Instalação

### 1. Instalar Dependências

```bash
# Executar o instalador automático
./install_dependencies.sh

# Ou instalar manualmente (Ubuntu/Debian)
sudo apt-get install curl jq dnsutils whois file coreutils openssl
```

### 2. Configurar Chaves de API (Opcional)

```bash
./security_analyzer.sh --config
```

Configure suas chaves de API para:
- VirusTotal
- Shodan
- URLScan.io
- Hybrid Analysis

## 🚀 Uso

### Sintaxe Básica

```bash
./security_analyzer.sh [OPÇÃO] [ALVO]
```

### Exemplos de Uso

#### Análise de Arquivo
```bash
./security_analyzer.sh -f /path/to/suspicious_file.exe
./security_analyzer.sh --file malware_sample.bin
```

#### Análise de URL
```bash
./security_analyzer.sh -u https://suspicious-site.com
./security_analyzer.sh --url http://malicious-domain.com/payload
```

#### Análise de Domínio
```bash
./security_analyzer.sh -d malicious-domain.com
./security_analyzer.sh --domain suspicious-site.org
```

#### Análise de Hash
```bash
./security_analyzer.sh -h 5d41402abc4b2a76b9719d911017c592
./security_analyzer.sh --hash e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

#### Análise de Email
```bash
./security_analyzer.sh -e suspicious@malicious-domain.com
./security_analyzer.sh --email phishing@fake-bank.com
```

#### Análise de Cabeçalho de Email
```bash
./security_analyzer.sh --header email_headers.txt
```

### Opções Disponíveis

| Opção | Descrição |
|-------|-----------|
| `-f, --file` | Analisar arquivo |
| `-u, --url` | Analisar URL |
| `-d, --domain` | Analisar domínio |
| `-h, --hash` | Analisar hash |
| `-e, --email` | Analisar email |
| `--header` | Analisar cabeçalho de email |
| `--config` | Configurar chaves de API |
| `--help` | Exibir ajuda |

## 📊 Saída da Análise

A ferramenta fornece informações detalhadas incluindo:

- **Status de Segurança**: Limpo, Suspeito ou Malicioso
- **Detecções**: Número de engines que detectaram ameaças
- **Metadados**: Informações técnicas sobre o alvo
- **Threat Intelligence**: Dados de múltiplas fontes
- **Recomendações**: Ações sugeridas baseadas nos resultados

### Exemplo de Saída

```
╔═══════════════════════════════════════════════════════════════╗
║                    SECURITY ANALYZER TOOL                    ║
║              Ferramenta Avançada de Análise de Segurança     ║
╚═══════════════════════════════════════════════════════════════╝

=== ANÁLISE DE ARQUIVO ===
Arquivo: suspicious_file.exe

[Informações Básicas]
suspicious_file.exe: PE32 executable (GUI) Intel 80386, for MS Windows

[Hashes]
MD5:    d41d8cd98f00b204e9800998ecf8427e
SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

[VirusTotal] AMEAÇA DETECTADA!
  Malicioso: 45 detecções
  Suspeito: 12 detecções

[ThreatFox] IOC MALICIOSO ENCONTRADO!
  Malware: Trojan.Generic | Confiança: 95% | Tags: exe, trojan

Análise concluída. Log salvo em: /home/user/.security_analyzer/analysis.log
```

## 📁 Estrutura de Arquivos

```
/home/anny-ribeiro/amazonQ/app/
├── security_analyzer.sh      # Script principal
├── threat_intel_apis.sh      # Módulo de APIs
├── config.sh                 # Configurações
├── install_dependencies.sh   # Instalador
├── README.md                 # Documentação
└── examples/                 # Exemplos de uso
```

## 🔧 Configuração Avançada

### Arquivo de Configuração

O arquivo `~/.security_analyzer/api_keys.conf` contém:

```bash
VIRUSTOTAL_API_KEY="sua_chave_aqui"
SHODAN_API_KEY="sua_chave_aqui"
URLSCAN_API_KEY="sua_chave_aqui"
HYBRID_ANALYSIS_API_KEY="sua_chave_aqui"
```

### Logs e Relatórios

- **Logs**: `~/.security_analyzer/analysis.log`
- **Relatórios**: `~/.security_analyzer/reports/`
- **Cache**: `~/.security_analyzer/cache/`

## 🔒 Considerações de Segurança

1. **Chaves de API**: Mantenha suas chaves seguras (arquivo com permissão 600)
2. **Arquivos Suspeitos**: Execute em ambiente isolado
3. **Logs**: Contêm informações sensíveis, proteja adequadamente
4. **Rate Limiting**: Respeite os limites das APIs

## 🐛 Solução de Problemas

### Dependências Faltando
```bash
# Verificar dependências
./security_analyzer.sh --help

# Reinstalar dependências
./install_dependencies.sh
```

### Problemas de API
```bash
# Reconfigurar chaves
./security_analyzer.sh --config

# Verificar logs
tail -f ~/.security_analyzer/analysis.log
```

### Permissões
```bash
# Corrigir permissões
chmod +x security_analyzer.sh
chmod 600 ~/.security_analyzer/api_keys.conf
```

## 📈 Roadmap

- [ ] Integração com mais fontes de threat intelligence
- [ ] Interface web opcional
- [ ] Análise de PDFs e documentos Office
- [ ] Integração com YARA rules
- [ ] Análise de tráfego de rede
- [ ] Relatórios em HTML/PDF
- [ ] Modo batch para múltiplos alvos

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para detalhes.

## ⚠️ Disclaimer

Esta ferramenta é destinada apenas para fins educacionais e de segurança legítima. O uso inadequado é de responsabilidade do usuário.

## 📞 Suporte

Para suporte e dúvidas:
- Abra uma issue no repositório
- Consulte os logs em `~/.security_analyzer/analysis.log`
- Verifique a documentação das APIs utilizadas

## 📦 Instalação

### Pré-requisitos

- Sistema Linux (Ubuntu, Debian, CentOS, Fedora, Arch)
- Acesso à internet para consultas de API
- Permissões de usuário para instalação de pacotes

### Instalação Automática

```bash
# 1. Navegar para o diretório da aplicação
cd /home/anny-ribeiro/amazonQ/app

# 2. Executar o instalador de dependências
./install_dependencies.sh

# 3. Verificar instalação
./security_analyzer.sh --help
```

### Instalação Manual

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install curl jq dnsutils whois file coreutils openssl ca-certificates

# CentOS/RHEL/Fedora
sudo dnf install curl jq bind-utils whois file coreutils openssl ca-certificates

# Arch Linux
sudo pacman -S curl jq bind-tools whois file coreutils openssl ca-certificates
```

## ⚙️ Configuração

### Configuração de Chaves de API

Para obter funcionalidade completa, configure suas chaves de API:

```bash
./security_analyzer.sh --config
```

### Obtenção de Chaves de API (Gratuitas)

1. **VirusTotal**: 
   - Acesse: https://www.virustotal.com/gui/join-us
   - Limite: 4 consultas/minuto

2. **URLScan.io**: 
   - Acesse: https://urlscan.io/user/signup
   - Limite: 100 consultas/dia

3. **Shodan**: 
   - Acesse: https://account.shodan.io/register
   - Limite: 100 consultas/mês

4. **Hybrid Analysis**: 
   - Acesse: https://www.hybrid-analysis.com/signup
   - Limite: 200 consultas/mês

### Arquivo de Configuração

As chaves são armazenadas em: `~/.security_analyzer/api_keys.conf`

```bash
VIRUSTOTAL_API_KEY="sua_chave_virustotal"
SHODAN_API_KEY="sua_chave_shodan"
URLSCAN_API_KEY="sua_chave_urlscan"
HYBRID_ANALYSIS_API_KEY="sua_chave_hybrid"
```

## 🚀 Como Usar

### Modos de Execução

#### 1. Menu Interativo com ASCII Art (Recomendado)
```bash
# Script de inicialização com seleção de modo
./start.sh

# Menu interativo direto com arte ASCII "SECURITY TOOL"
./menu.sh
```

**Características do Menu:**
- 🎨 Arte ASCII profissional "SECURITY TOOL"
- 🏷️ Logo @cybersecwonderwoman em destaque
- 🌈 Interface colorida com emojis
- 📋 12 opções organizadas por categoria
- 🔄 Navegação intuitiva com retorno automático

#### 2. Linha de Comando Direta
```bash
# Uso tradicional
./security_analyzer.sh [OPÇÃO] [ALVO]

# Através do inicializador (mantém compatibilidade)
./start.sh -f arquivo.exe
```

#### 3. Modo Híbrido
```bash
# Iniciar com seleção de modo
./start.sh
# Escolher entre: Menu Interativo | Linha de Comando | Ajuda | Testes
```

### Interface do Menu Principal

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

### Sintaxe da Linha de Comando

```bash
./security_analyzer.sh [OPÇÃO] [ALVO]
```

### Opções do Menu Interativo

| Categoria | Opção | Descrição | Funcionalidade |
|-----------|-------|-----------|----------------|
| **🔍 Análises** | [1] 📁 Analisar Arquivo | Verificar arquivos suspeitos | Análise completa de malware |
| | [2] 🌐 Analisar URL | Verificar links maliciosos | Detecção de phishing/malware |
| | [3] 🏠 Analisar Domínio | Investigar domínios suspeitos | DNS, WHOIS, blacklists |
| | [4] 🔢 Analisar Hash | Consultar hashes | Múltiplas bases de dados |
| | [5] 📧 Analisar Email | Verificar endereços | Validação de domínios |
| | [6] 📋 Analisar Cabeçalho | Headers de email | Detecção de spoofing |
| | [7] 🌐 Analisar IP | Verificar endereços IP | Geolocalização, RBLs, portas |
| **⚙️ Config** | [8] ⚙️ Configurar APIs | Chaves de acesso | Setup de integração |
| | [9] 📊 Ver Estatísticas | Relatórios de uso | Métricas de análise |
| | [10] 📝 Ver Logs | Logs de análise | Histórico detalhado |
| | [11] 🧪 Executar Testes | Testes funcionais | Validação do sistema |
| **📚 Info** | [12] 📚 Ajuda | Manual de uso | Documentação completa |
| | [13] ℹ️ Sobre | Informações | Versão e créditos |

### Opções da Linha de Comando

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-f, --file` | Analisar arquivo | `./security_analyzer.sh -f malware.exe` |
| `-u, --url` | Analisar URL | `./security_analyzer.sh -u https://site.com` |
| `-d, --domain` | Analisar domínio | `./security_analyzer.sh -d malicious.com` |
| `-h, --hash` | Analisar hash | `./security_analyzer.sh -h abc123...` |
| `-e, --email` | Analisar email | `./security_analyzer.sh -e user@domain.com` |
| `-i, --ip` | Analisar IP | `./security_analyzer.sh -i 192.168.1.1` |
| `--header` | Analisar cabeçalho | `./security_analyzer.sh --header headers.txt` |
| `--config` | Configurar APIs | `./security_analyzer.sh --config` |
| `--help` | Exibir ajuda | `./security_analyzer.sh --help` |

## 💡 Exemplos Práticos

### 🎯 Usando o Menu Interativo

#### Primeira Execução
```bash
# 1. Iniciar a ferramenta
./start.sh

# 2. Escolher [1] Menu Interativo
# 3. Configurar APIs: [7] ⚙️ Configurar APIs
# 4. Executar testes: [10] 🧪 Executar Testes
# 5. Começar análises
```

#### Fluxo de Análise via Menu
```bash
./menu.sh
# Escolher [1] 📁 Analisar Arquivo
# Digite: /downloads/suspicious_file.exe
# [Análise executada automaticamente]
# [Pressione ENTER para continuar]
# [Retorna ao menu principal]
```

### ⚡ Usando Linha de Comando

#### 1. Análise de Arquivo Suspeito

```bash
# Analisar um executável suspeito
./security_analyzer.sh -f /downloads/suspicious_file.exe

# Resultado esperado:
# ✓ Informações do arquivo (tipo, tamanho, permissões)
# ✓ Hashes MD5 e SHA256 calculados
# ✓ Verificação em múltiplas bases de malware
# ✓ Relatório de detecções
```

#### 2. Verificação de URL Suspeita

```bash
# Verificar uma URL recebida por email
./security_analyzer.sh -u https://suspicious-bank-login.com

# Resultado esperado:
# ✓ Análise de reputação da URL
# ✓ Screenshot e análise de conteúdo
# ✓ Verificação do domínio
# ✓ Detecção de phishing
```

#### 3. Investigação de Domínio

```bash
# Investigar um domínio suspeito
./security_analyzer.sh -d malicious-domain.com

# Resultado esperado:
# ✓ Resolução DNS e IPs associados
# ✓ Informações WHOIS
# ✓ Verificação em blacklists
# ✓ Análise de infraestrutura
```

#### 4. Verificação de Hash de Malware

```bash
# Verificar hash conhecido
./security_analyzer.sh -h 5d41402abc4b2a76b9719d911017c592

# Resultado esperado:
# ✓ Identificação do tipo de hash
# ✓ Consulta em bases de malware
# ✓ Informações sobre família de malware
# ✓ Indicadores de compromisso
```

#### 6. Análise de Endereço IP

```bash
# Analisar um endereço IP suspeito
./security_analyzer.sh -i 192.168.1.100

# Resultado esperado:
# ✓ Geolocalização do IP (país, região, cidade)
# ✓ Informações da organização/ISP
# ✓ Verificação em listas de bloqueio (RBLs)
# ✓ Análise de portas abertas
# ✓ Relatório HTML interativo
```

#### 6. Análise de Endereço IP

```bash
# Analisar um endereço IP suspeito
./security_analyzer.sh -i 192.168.1.100

# Resultado esperado:
# ✓ Geolocalização do IP (país, região, cidade)
# ✓ Informações da organização/ISP
# ✓ Verificação em listas de bloqueio (RBLs)
# ✓ Análise de portas abertas
# ✓ Relatório HTML interativo
```

### 🧪 Exemplos de Teste

#### Teste com Arquivo EICAR (Menu)
```bash
./menu.sh
# [10] 🧪 Executar Testes
# [Testes automatizados executados]
```

#### Teste Manual (Linha de Comando)
```bash
# Criar arquivo de teste EICAR (inofensivo)
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /tmp/eicar.txt

# Analisar arquivo de teste
./security_analyzer.sh -f /tmp/eicar.txt

# Limpar arquivo de teste
rm /tmp/eicar.txt
```

### 🔧 Configuração via Menu

#### Setup Inicial Completo
```bash
./start.sh
# [1] Menu Interativo
# [7] ⚙️ Configurar APIs
# Inserir chaves de API:
#   - VirusTotal: sua_chave_vt
#   - Shodan: sua_chave_shodan  
#   - URLScan.io: sua_chave_urlscan
#   - Hybrid Analysis: sua_chave_hybrid
# [Configuração salva automaticamente]
```

### 📊 Monitoramento via Menu

#### Visualizar Estatísticas
```bash
./menu.sh
# [8] 📊 Ver Estatísticas
# === Resumo de Análises ===
# Total: 25 análises
# Arquivos: 10 | URLs: 8 | Domínios: 5 | Hashes: 2
```

#### Verificar Logs
```bash
./menu.sh  
# [9] 📝 Ver Logs
# === Últimas 20 entradas ===
# [2025-07-18 16:00:00] Arquivo analisado: malware.exe
# [2025-07-18 16:01:00] URL analisada: https://malicious.com
```

## 📊 Interpretação de Resultados

### Códigos de Cores

- 🟢 **Verde**: Limpo/Seguro - Nenhuma ameaça detectada
- 🟡 **Amarelo**: Suspeito/Atenção - Requer investigação adicional
- 🔴 **Vermelho**: Malicioso/Perigoso - Ameaça confirmada

### Exemplo de Saída Completa

```
╔═══════════════════════════════════════════════════════════════╗
║                    SECURITY ANALYZER TOOL                    ║
║              Ferramenta Avançada de Análise de Segurança     ║
╚═══════════════════════════════════════════════════════════════╝

=== ANÁLISE DE ARQUIVO ===
Arquivo: suspicious_malware.exe

[Informações Básicas]
suspicious_malware.exe: PE32 executable (GUI) Intel 80386, for MS Windows
-rw-r--r-- 1 user user 1.2M Jul 18 16:00 suspicious_malware.exe

[Hashes]
MD5:    d41d8cd98f00b204e9800998ecf8427e
SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

[VirusTotal] AMEAÇA DETECTADA!
  Malicioso: 45 detecções
  Suspeito: 12 detecções
  Família: Trojan.Generic.KD.12345

[ThreatFox] IOC MALICIOSO ENCONTRADO!
  Malware: Trojan.Banker | Confiança: 95% | Tags: banking, trojan, stealer

[Hybrid Analysis] ARQUIVO MALICIOSO!
  Threat Score: 85/100 | Ambiente: Windows 10 64-bit

[AlienVault OTX] INDICADOR MALICIOSO! (3 pulses)
  Pulse: Banking Trojan Campaign 2025 | Criado: 2025-07-15T10:30:00Z

RECOMENDAÇÃO: ⚠️  ARQUIVO ALTAMENTE PERIGOSO - NÃO EXECUTE!
```

## 📁 Estrutura de Arquivos

```
/home/anny-ribeiro/amazonQ/app/
├── start.sh                      # 🚀 Script de inicialização principal
├── menu.sh                       # 🎯 Menu interativo com ASCII art
├── security_analyzer.sh          # 🛡️ Script principal de análise
├── threat_intel_apis.sh          # 🔗 Módulo de APIs de threat intelligence
├── email_analyzer.sh             # 📧 Analisador especializado de emails
├── ip_analyzer_tool.sh           # 🌐 Analisador especializado de IPs
├── run_ip_analysis.sh            # 🔍 Script de execução de análise de IP
├── generate_report.sh            # 📊 Gerador de relatórios HTML
├── config.sh                     # ⚙️ Configurações e variáveis globais
├── install_dependencies.sh       # 📦 Instalador automático de dependências
├── README.md                     # 📚 Documentação completa (este arquivo)
├── QUICK_START.md                # ⚡ Guia de início rápido
├── MENU_GUIDE.md                 # 🎯 Guia do menu interativo
├── TECHNICAL_DETAILS.md          # 🔧 Detalhes técnicos da implementação
├── EXECUTIVE_SUMMARY.md          # 📊 Resumo executivo para gestores
├── LICENSE                       # 📄 Licença GNU GPL v3
└── examples/                     # 📁 Exemplos e testes
    ├── test_samples.sh           # 🧪 Script de testes automatizados
    └── sample_email_header.txt   # 📋 Exemplo de cabeçalho de email

# Diretórios criados automaticamente:
~/.security_analyzer/
├── analysis.log                  # 📝 Log principal de análises
├── api_keys.conf                 # 🔐 Chaves de API (protegido)
├── cache/                        # 💾 Cache de consultas
└── reports/                      # 📊 Relatórios em JSON e HTML
```

### 🎯 Arquivos Principais

| Arquivo | Função | Uso |
|---------|--------|-----|
| **start.sh** | Inicializador principal | `./start.sh` |
| **menu.sh** | Menu interativo | `./menu.sh` |
| **security_analyzer.sh** | Engine principal | `./security_analyzer.sh [opções]` |

### 📚 Documentação

| Arquivo | Conteúdo | Público-Alvo |
|---------|----------|--------------|
| **README.md** | Documentação completa | Todos os usuários |
| **QUICK_START.md** | Guia rápido | Usuários iniciantes |
| **MENU_GUIDE.md** | Guia do menu | Usuários do menu |
| **TECHNICAL_DETAILS.md** | Detalhes técnicos | Desenvolvedores |
| **EXECUTIVE_SUMMARY.md** | Resumo executivo | Gestores |

## 📝 Logs e Relatórios

### Sistema de Logs

Todas as análises são registradas em: `~/.security_analyzer/analysis.log`

```bash
# Visualizar logs em tempo real
tail -f ~/.security_analyzer/analysis.log

# Buscar análises específicas
grep "malware.exe" ~/.security_analyzer/analysis.log

# Ver últimas 50 linhas
tail -50 ~/.security_analyzer/analysis.log
```

### Relatórios JSON

Relatórios detalhados são salvos em: `~/.security_analyzer/reports/`

```json
{
  "target": "suspicious_file.exe",
  "type": "file",
  "timestamp": "2025-07-18T16:00:00Z",
  "results": [
    {
      "source": "VirusTotal",
      "result": "malicious",
      "status": "45 detections"
    },
    {
      "source": "ThreatFox",
      "result": "malicious",
      "status": "IOC found - Trojan.Banker"
    }
  ]
}
```

### Comandos Úteis para Logs

```bash
# Limpar logs antigos (mais de 30 dias)
find ~/.security_analyzer/ -name "*.log" -mtime +30 -delete

# Estatísticas de análises
grep -c "analisado" ~/.security_analyzer/analysis.log

# Buscar ameaças detectadas
grep -i "malicioso\|ameaça\|detectada" ~/.security_analyzer/analysis.log
```

## 🔧 Solução de Problemas

### Problemas Comuns

#### 1. Dependências Faltando

**Erro**: `command not found: jq`

**Solução**:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# CentOS/Fedora
sudo dnf install jq

# Ou executar o instalador
./install_dependencies.sh
```

#### 2. Problemas de Permissão

**Erro**: `Permission denied`

**Solução**:
```bash
# Tornar scripts executáveis
chmod +x security_analyzer.sh
chmod +x install_dependencies.sh

# Corrigir permissões do arquivo de configuração
chmod 600 ~/.security_analyzer/api_keys.conf
```

#### 3. APIs Não Funcionando

**Erro**: `API Key não configurada`

**Solução**:
```bash
# Reconfigurar chaves de API
./security_analyzer.sh --config

# Verificar arquivo de configuração
cat ~/.security_analyzer/api_keys.conf

# Testar conectividade
curl -s "https://www.virustotal.com/api/v3/files/limits" \
  -H "x-apikey: SUA_CHAVE_AQUI"
```

#### 4. Problemas de Conectividade

**Erro**: `curl: (6) Could not resolve host`

**Solução**:
```bash
# Verificar conectividade
ping google.com

# Verificar DNS
nslookup virustotal.com

# Verificar proxy/firewall
curl -I https://www.virustotal.com
```

#### 5. Rate Limiting

**Erro**: `HTTP 429 Too Many Requests`

**Solução**:
- Aguardar alguns minutos antes de nova consulta
- Verificar limites da API gratuita
- Considerar upgrade para API premium

### Comandos de Diagnóstico

```bash
# Verificar todas as dependências
./security_analyzer.sh --help

# Testar conectividade com APIs
curl -s https://www.virustotal.com/api/v3/files/limits

# Verificar logs de erro
grep -i error ~/.security_analyzer/analysis.log

# Limpar cache em caso de problemas
rm -rf ~/.security_analyzer/cache/*

# Verificar espaço em disco
df -h ~/.security_analyzer/
```

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

### Como Contribuir

1. **Fork** o repositório
2. **Clone** sua fork localmente
3. **Crie** uma branch para sua feature: `git checkout -b minha-feature`
4. **Faça** suas modificações
5. **Teste** suas mudanças
6. **Commit** suas alterações: `git commit -m "Adiciona nova feature"`
7. **Push** para sua branch: `git push origin minha-feature`
8. **Abra** um Pull Request

### Diretrizes de Contribuição

- Mantenha o código limpo e bem documentado
- Adicione testes para novas funcionalidades
- Siga as convenções de nomenclatura existentes
- Atualize a documentação quando necessário

### Ideias para Contribuição

- 🔍 Integração com novas fontes de threat intelligence
- 🎨 Melhorias na interface de usuário
- 📊 Novos formatos de relatório (HTML, PDF)
- 🔧 Otimizações de performance
- 🌐 Suporte para mais tipos de análise
- 📱 Interface web opcional

## 📄 Licença

Este projeto está licenciado sob a **GNU General Public License v3.0 (GPL-3.0)**. 

### 📋 Resumo da Licença GPL-3.0

- ✅ **Uso comercial** permitido
- ✅ **Modificação** permitida  
- ✅ **Distribuição** permitida
- ✅ **Uso privado** permitido
- ✅ **Uso de patentes** permitido
- ⚠️ **Copyleft** - Modificações devem usar a mesma licença
- ⚠️ **Divulgação do código fonte** obrigatória
- ⚠️ **Aviso de licença e copyright** deve ser mantido
- ❌ **Sem garantia** ou responsabilidade

### 🔗 Licença Completa

Veja o arquivo [LICENSE](LICENSE) para o texto completo da licença GNU GPL v3.0.

### 🤝 Contribuições

Ao contribuir para este projeto, você concorda que suas contribuições serão licenciadas sob a mesma licença GPL-3.0.

### 📝 Aviso de Copyright

```
Security Analyzer Tool - Advanced Cybersecurity Analysis Tool
Copyright (C) 2025 @cybersecwonderwoman

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
```

## ⚠️ Disclaimer e Considerações Legais

### Uso Responsável

Esta ferramenta foi desenvolvida exclusivamente para:
- **Análise de segurança legítima**
- **Pesquisa em cibersegurança**
- **Fins educacionais**
- **Resposta a incidentes**

### Responsabilidades do Usuário

- ✅ Use apenas em sistemas próprios ou com autorização
- ✅ Respeite os termos de uso das APIs
- ✅ Mantenha as chaves de API seguras
- ❌ Não use para atividades maliciosas
- ❌ Não viole leis locais ou internacionais

### Limitações

- A ferramenta depende de serviços externos
- Resultados podem ter falsos positivos/negativos
- APIs gratuitas têm limitações de uso
- Nem todas as ameaças podem ser detectadas

## 📞 Suporte e Contato

### Obtendo Ajuda

1. **Documentação**: Consulte este README e o QUICK_START.md
2. **Logs**: Verifique `~/.security_analyzer/analysis.log`
3. **Issues**: Abra uma issue no repositório
4. **Testes**: Execute `./examples/test_samples.sh`

### Informações de Versão

- **Versão**: 1.1.0
- **Data de Lançamento**: Julho 2025
- **Última Atualização**: Julho 2025
- **Compatibilidade**: Linux (Ubuntu, Debian, CentOS, Fedora, Arch)
- **Dependências**: Bash 4.0+, curl, jq, dig, whois, nc (netcat)

### Changelog v1.1.0

#### ✅ Novas Funcionalidades
- 🌐 **Análise de IP**: Nova funcionalidade completa de análise de endereços IP
- 📊 **Relatórios HTML**: Geração automática de relatórios HTML interativos
- 🔍 **Verificação de Portas**: Análise de portas abertas em IPs
- 🌍 **Geolocalização**: Informações detalhadas de localização geográfica

#### 🔧 Correções Implementadas
- ✅ Corrigido conflito no menu interativo (opção 7 agora funciona)
- ✅ Reorganizada numeração das opções do menu (1-13)
- ✅ Removidas funções duplicadas no código
- ✅ Corrigido erro de extração de pontuação de risco
- ✅ Melhorado tratamento de erros em comparações numéricas

#### 🎨 Melhorias na Interface
- ✅ Menu reorganizado com categorias claras
- ✅ Numeração sequencial corrigida
- ✅ Melhor feedback visual para o usuário

### Roadmap Futuro

- [ ] Interface web opcional
- [ ] Análise de documentos Office/PDF
- [ ] Integração com YARA rules
- [ ] Análise de tráfego de rede
- [ ] Relatórios em HTML/PDF
- [ ] Modo batch para múltiplos alvos
- [ ] API REST própria
- [ ] Dashboard de monitoramento

---

**Desenvolvido com ❤️ para a comunidade de cibersegurança**

*Última atualização: Julho 2025*
# security_tools
