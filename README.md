# 🛡️ Security Analyzer Tool v3.0

<div align="center">

![Security Analyzer](https://img.shields.io/badge/Security-Analyzer-blue?style=for-the-badge&logo=shield)
![Version](https://img.shields.io/badge/Version-3.0.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20WSL-lightgrey?style=for-the-badge)

**Ferramenta Profissional de Análise de Segurança Cibernética**

*Transformando análises de segurança com inteligência artificial e múltiplas fontes de threat intelligence*

</div>

---

## 🚀 **NOVIDADES DA VERSÃO 3.0**

### ⭐ **Arquitetura Completamente Reestruturada**
- **Código modular** organizado em componentes especializados
- **81% redução** no código total (de 80k+ para 15k linhas)
- **Estrutura profissional** pronta para ambientes empresariais

### 🔒 **Segurança de Nível Empresarial**
- **Criptografia AES-256-CBC** para proteção de chaves de API
- **Validação robusta** contra injeções e ataques
- **Rate limiting inteligente** para proteção de APIs
- **Auditoria completa** com logs estruturados

### 🧠 **Análises Inteligentes e Profundas**
- **Avaliação de risco** baseada em múltiplos fatores
- **Detecção de padrões** suspeitos avançada
- **Recomendações específicas** por nível de ameaça
- **Análise comportamental** de URLs e arquivos

---

## ✨ **Funcionalidades Principais**

### 🔍 **Análises Avançadas**
- **📁 Análise de Arquivos**: Verificação profunda com múltiplos algoritmos de hash (MD5, SHA1, SHA256, SHA512), detecção de assinaturas de malware, análise de metadados e estrutura
- **🌐 Análise de URLs**: Verificação completa incluindo certificados SSL, cabeçalhos HTTP, análise de conteúdo, conectividade e verificação em blacklists
- **🏠 Análise de Domínios**: Investigação DNS, WHOIS, geolocalização, verificação em blacklists e análise de reputação
- **🔢 Análise de Hashes**: Identificação automática de tipo e consulta em múltiplas bases de dados de threat intelligence
- **🌐 Análise de IPs**: Verificação de geolocalização, reverse DNS, classificação de rede e detecção de ameaças
- **📧 Análise de Emails**: Validação de formato, verificação de domínio, registros MX e detecção de phishing

### 🌐 **Integração com APIs de Threat Intelligence**
- **VirusTotal**: Verificação de arquivos e URLs em 70+ engines antivírus
- **URLScan.io**: Análise comportamental de URLs em sandbox seguro
- **Shodan**: Intelligence sobre dispositivos e serviços expostos na internet
- **ThreatFox**: Base de dados de IOCs (Indicators of Compromise) atualizada
- **AlienVault OTX**: Open Threat Exchange para threat intelligence
- **Sistema extensível** para integração com novas APIs

### 📊 **Relatórios Profissionais**
- **Relatórios HTML**: Interface responsiva com design profissional e interativo
- **Servidor web integrado**: Visualização automática no navegador com porta configurável
- **Metadados completos**: Rastreabilidade, auditoria e informações forenses
- **Exportação avançada**: Suporte para impressão, PDF e compartilhamento
- **Dashboard interativo**: Estatísticas em tempo real e histórico de análises

### 🔒 **Segurança e Compliance**
- **Criptografia AES-256-CBC**: Proteção de chaves de API e dados sensíveis
- **Validação de entrada**: Sanitização automática contra injeções e ataques
- **Rate limiting**: Controle inteligente de requisições para APIs
- **Logs auditáveis**: Registro completo com timestamps e rastreabilidade
- **Verificação de privilégios**: Execução segura sem privilégios de root
- **Backup automático**: Proteção de configurações e dados importantes

## 🚀 Instalação Rápida

### Pré-requisitos
- Sistema Linux, macOS ou WSL
- Bash 4.0+
- Conexão com internet

### Instalação Automática
```bash
# Clone o repositório
git clone https://github.com/cybersecwonderwoman/security_tools.git
cd security_tools

# Execute o instalador inteligente
chmod +x scripts/install_dependencies.sh
./scripts/install_dependencies.sh

# Inicie a aplicação
chmod +x start.sh
./start.sh
```

### Execução Alternativa (Versão Simplificada)
```bash
# Para uma versão mais leve e funcional
chmod +x security_analyzer_v3_complete.sh
./security_analyzer_v3_complete.sh
```

### Instalação Manual de Dependências
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y curl jq dnsutils whois file openssl python3 git bc geoip-bin exiftool

# CentOS/RHEL/Fedora
sudo dnf install -y curl jq bind-utils whois file openssl python3 git bc GeoIP perl-Image-ExifTool

# macOS (requer Homebrew)
brew install curl jq bind whois file openssl python3 git geoip exiftool
```

## 📋 Guia de Uso

### Primeira Execução
1. Execute `./start.sh` para iniciar a aplicação
2. Configure suas chaves de API no menu "Configurar APIs"
3. Execute um teste com a opção "Executar Testes"

### Análise de Arquivo
```bash
# No menu principal, selecione opção 1
# Digite o caminho do arquivo
/caminho/para/arquivo.exe

# A ferramenta irá:
# - Calcular hashes (MD5, SHA1, SHA256, SHA512)
# - Analisar tipo e estrutura
# - Verificar assinaturas de malware
# - Consultar APIs externas
# - Gerar relatório HTML
```

### Análise de URL
```bash
# No menu principal, selecione opção 2
# Digite a URL completa
https://exemplo.com/pagina

# A ferramenta irá:
# - Verificar conectividade
# - Analisar certificado SSL
# - Examinar cabeçalhos HTTP
# - Verificar conteúdo
# - Consultar threat intelligence
```

### Configuração de APIs

#### VirusTotal
1. Acesse [VirusTotal](https://www.virustotal.com/)
2. Crie uma conta gratuita
3. Vá em "API Key" no seu perfil
4. Copie a chave de 64 caracteres
5. Configure na ferramenta (Menu → Configurar APIs → VirusTotal)

#### URLScan.io
1. Acesse [URLScan.io](https://urlscan.io/)
2. Registre-se gratuitamente
3. Vá em "Settings" → "API"
4. Gere uma nova chave de API
5. Configure na ferramenta

#### Shodan
1. Acesse [Shodan](https://www.shodan.io/)
2. Crie uma conta
3. Vá em "My Account"
4. Copie sua API Key
5. Configure na ferramenta

## 🏗️ Arquitetura

```
security_tools/
├── src/                          # Código fonte principal
│   ├── security_analyzer_complete.sh  # Script principal modular
│   ├── config.conf              # Configurações centralizadas
│   ├── modules/                 # Módulos funcionais
│   │   ├── api_manager.sh       # Gerenciamento de APIs
│   │   └── report_generator.sh  # Geração de relatórios
│   ├── analyzers/               # Engines de análise
│   │   ├── file_analyzer.sh     # Análise de arquivos
│   │   └── url_analyzer.sh      # Análise de URLs
│   └── utils/                   # Utilitários
│       ├── security.sh          # Funções de segurança
│       └── logger.sh            # Sistema de logging
├── scripts/                     # Scripts auxiliares
│   └── install_dependencies.sh  # Instalador inteligente
├── templates/                   # Templates HTML
│   └── html_templates/          # Templates de relatórios
├── docs/                        # Documentação
├── backup_old_version/          # Backup da versão anterior
├── security_analyzer_v3_complete.sh  # Versão funcional monolítica
└── start.sh                     # Launcher principal
```

### 🔧 **Componentes Principais**

#### **Script Principal Modular** (`src/security_analyzer_complete.sh`)
- Arquitetura modular com carregamento dinâmico
- Gerenciamento de dependências inteligente
- Sistema de inicialização robusto

#### **Versão Funcional** (`security_analyzer_v3_complete.sh`)
- Versão monolítica para uso direto
- Todas as funcionalidades em um único arquivo
- Ideal para ambientes com restrições

#### **Módulos Especializados**
- **API Manager**: Gerenciamento seguro de chaves e requisições
- **Report Generator**: Geração de relatórios HTML profissionais
- **File Analyzer**: Análise profunda de arquivos
- **URL Analyzer**: Verificação completa de URLs
- **Security Utils**: Funções de criptografia e validação
- **Logger**: Sistema de logging estruturado

## 🔧 Configuração Avançada

### Arquivo de Configuração
Localizado em `src/config.conf`:

```bash
# Configurações Gerais
APP_VERSION="3.0.0"
DEFAULT_TIMEOUT=30
MAX_FILE_SIZE=104857600  # 100MB

# Segurança
ENCRYPTION_ALGORITHM="aes-256-cbc"
HASH_ALGORITHM="sha256"
SECURE_DELETE=true

# Retenção de Dados
REPORTS_RETENTION_DAYS=30
LOG_RETENTION_DAYS=90
CACHE_RETENTION_HOURS=24

# Servidor Web para Relatórios
WEB_SERVER_PORT=8080
WEB_SERVER_HOST="127.0.0.1"
```

### Configuração do Usuário
Localizado em `~/.security_analyzer/user_config.conf`:

```bash
# Configurações de interface
ENABLE_COLORS=true
ENABLE_ANIMATIONS=true

# Configurações de rede
CONNECTION_TIMEOUT=10
API_RATE_LIMIT=4

# Configurações de relatórios
REPORTS_RETENTION_DAYS=30
LOG_RETENTION_DAYS=90
DEFAULT_REPORT_FORMAT=html
```

### Variáveis de Ambiente
```bash
export SECURITY_ANALYZER_CONFIG_DIR="$HOME/.security_analyzer"
export SECURITY_ANALYZER_LOG_LEVEL="INFO"
export SECURITY_ANALYZER_API_TIMEOUT="30"
```

## 📊 Exemplos de Uso

### Análise Automatizada via Script
```bash
#!/bin/bash
# Script de análise automatizada

SECURITY_TOOL="./security_analyzer_v3_complete.sh"

# Analisar múltiplos arquivos
for file in /suspicious_files/*; do
    echo "Analisando: $file"
    echo "1" | echo "$file" | $SECURITY_TOOL
done
```

### Integração com Pipeline CI/CD
```yaml
# .github/workflows/security-scan.yml
name: Security Scan
on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Security Analyzer
        run: |
          git clone https://github.com/cybersecwonderwoman/security_tools.git
          cd security_tools
          ./scripts/install_dependencies.sh
      - name: Scan Files
        run: |
          cd security_tools
          # Implementar lógica de scan automatizado
```

### Análise em Lote com Relatórios
```bash
#!/bin/bash
# Análise em lote com geração de relatórios

ANALYZER="./security_analyzer_v3_complete.sh"
REPORT_DIR="./batch_reports"

mkdir -p "$REPORT_DIR"

# Lista de URLs suspeitas
urls=(
    "https://suspicious-site1.com"
    "https://phishing-site2.net"
    "https://malware-host3.org"
)

for url in "${urls[@]}"; do
    echo "Analisando URL: $url"
    # Executar análise e salvar resultado
    echo "2" | echo "$url" | $ANALYZER > "$REPORT_DIR/$(echo $url | sed 's|https\?://||' | tr '/' '_').txt"
done
```

## 🛠️ Desenvolvimento

### Estrutura de Módulos
Cada módulo segue o padrão:
```bash
#!/bin/bash
# Cabeçalho com descrição
# Carregar dependências
# Definir funções
# Exportar funções públicas
```

### Adicionando Nova API
1. Edite `src/modules/api_manager.sh`
2. Adicione entrada em `SUPPORTED_APIS`
3. Implemente funções `test_*_api` e `check_*_*`
4. Atualize documentação

### Executando Testes
```bash
# Testes do sistema
./start.sh
# Menu → Executar Testes

# Testes manuais
cd src
bash -n security_analyzer_complete.sh  # Verificar sintaxe
```

### Criando Novos Analisadores
```bash
# Exemplo de novo analisador
# src/analyzers/new_analyzer.sh

#!/bin/bash
# Novo Analisador

analyze_new_type() {
    local input="$1"
    
    # Validar entrada
    if ! validate_input "$input" "new_type"; then
        return 1
    fi
    
    # Executar análise
    local result="Análise concluída"
    
    # Log da análise
    log_analysis "NEW_TYPE" "$input" "BAIXO" "5"
    
    echo "$result"
}
```

## 🔍 Solução de Problemas

### Problemas Comuns

#### Dependências Faltando
```bash
# Erro: comando não encontrado
./scripts/install_dependencies.sh
```

#### Problemas de Permissão
```bash
# Erro: permissão negada
chmod +x start.sh
chmod +x security_analyzer_v3_complete.sh
```

#### APIs Não Funcionando
1. Verifique conexão com internet
2. Confirme chaves de API no menu de configuração
3. Teste cada API individualmente
4. Verifique logs em `~/.security_analyzer/analysis.log`

#### Relatórios Não Abrindo
1. Verifique se Python3 está instalado
2. Confirme se porta 8080 está livre
3. Tente abrir arquivo HTML manualmente

### Logs e Debugging
```bash
# Ver logs em tempo real
tail -f ~/.security_analyzer/analysis.log

# Buscar erros específicos
grep ERROR ~/.security_analyzer/analysis.log

# Executar em modo debug
export SECURITY_ANALYZER_LOG_LEVEL="DEBUG"
./start.sh
```

## 📈 Roadmap

### v3.1 (Próxima Release)
- [ ] Análise de documentos PDF e Office
- [ ] Integração com MISP (Malware Information Sharing Platform)
- [ ] Análise de tráfego de rede (PCAP)
- [ ] Dashboard web permanente

### v3.2 (Futuro)
- [ ] Machine Learning para detecção de anomalias
- [ ] Análise de blockchain e criptomoedas
- [ ] Integração com SIEM (Splunk, ELK)
- [ ] API REST para integração externa

### v4.0 (Longo Prazo)
- [ ] Interface gráfica (GUI)
- [ ] Análise forense completa
- [ ] Suporte para Windows nativo
- [ ] Análise de malware em sandbox

## 🤝 Contribuição

### Como Contribuir
1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

### Diretrizes
- Siga o padrão de código existente
- Adicione testes para novas funcionalidades
- Atualize a documentação
- Use commits descritivos

### Reportar Bugs
Use o template de issue no GitHub incluindo:
- Versão do sistema operacional
- Versão da ferramenta
- Passos para reproduzir
- Logs relevantes

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## ⚠️ Disclaimer

Esta ferramenta é destinada apenas para fins educacionais e de segurança legítima. O uso inadequado é de responsabilidade do usuário. Sempre obtenha autorização adequada antes de analisar sistemas que não sejam seus.

## 👥 Créditos

- **Desenvolvido por**: @cybersecwonderwoman
- **Contribuidores**: Veja [CONTRIBUTORS.md](docs/CONTRIBUTORS.md)
- **Inspirado por**: Comunidade de segurança cibernética

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/cybersecwonderwoman/security_tools/issues)
- **Documentação**: [Wiki do Projeto](https://github.com/cybersecwonderwoman/security_tools/wiki)
- **Email**: security-tools@cybersecwonderwoman.com

---

<div align="center">

**🛡️ Security Analyzer Tool v3.0 - Protegendo o mundo digital, uma análise por vez 🛡️**

[![GitHub stars](https://img.shields.io/github/stars/cybersecwonderwoman/security_tools.svg?style=social&label=Star)](https://github.com/cybersecwonderwoman/security_tools)
[![GitHub forks](https://img.shields.io/github/forks/cybersecwonderwoman/security_tools.svg?style=social&label=Fork)](https://github.com/cybersecwonderwoman/security_tools/fork)

</div>
