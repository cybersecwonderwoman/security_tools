# 📋 Changelog - Security Analyzer Tool

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [1.1.0] - 2025-07-22

### ✅ Adicionado
- **Nova funcionalidade de análise de IP** - Análise completa de endereços IP
  - Geolocalização precisa (país, região, cidade, organização)
  - Verificação em listas de bloqueio (RBLs)
  - Análise de portas abertas com scan básico
  - Verificação de reputação de IP
  - Geração de relatórios HTML interativos
  - Integração com ipinfo.io para dados geográficos
- **Opção 7 no menu interativo** - "🌐 Analisar IP"
- **Scripts especializados para análise de IP**:
  - `ip_analyzer_tool.sh` - Engine principal de análise
  - `run_ip_analysis.sh` - Script de execução e relatório
- **Geração de relatórios HTML** - Relatórios visuais para análise de IP
- **Suporte a netcat (nc)** - Para verificação de portas abertas

### 🔧 Corrigido
- **Menu interativo opção 7** - Corrigido problema que impedia funcionamento
- **Conflito de numeração** - Removida duplicação da opção 10 no menu
- **Case statement** - Corrigida estrutura do switch/case no menu
- **Função duplicada** - Removida duplicação da função `menu_analyze_ip`
- **Extração de pontuação de risco** - Corrigido comando `cut` no generate_report.sh
- **Comparações numéricas** - Adicionado tratamento de erro com `2>/dev/null`
- **Here-document** - Corrigido erro de sintaxe no generate_report.sh

### 🎨 Melhorado
- **Numeração do menu** - Reorganizada sequencialmente (1-13)
- **Categorização das opções** - Agrupadas por funcionalidade
- **Tratamento de erros** - Melhor handling de erros em scripts
- **Documentação** - README atualizado com nova funcionalidade
- **Estrutura de arquivos** - Documentação da nova estrutura

### 🔄 Alterado
- **Menu principal** - Reorganização das opções:
  - [1-7] Análises (incluindo nova análise de IP)
  - [8-11] Configurações e utilitários
  - [12-13] Informações e ajuda
- **Diretório de relatórios** - Agora suporta HTML além de JSON

---

## [1.0.0] - 2025-07-18

### ✅ Adicionado
- **Lançamento inicial** da Security Analyzer Tool
- **Menu interativo** com ASCII art "SECURITY TOOL"
- **Análise de arquivos** - Verificação de malware via múltiplas APIs
- **Análise de URLs** - Detecção de phishing e sites maliciosos
- **Análise de domínios** - DNS, WHOIS, blacklists
- **Análise de hashes** - Consulta em bases de dados de malware
- **Análise de emails** - Verificação de domínios e autenticação
- **Análise de cabeçalhos** - Headers de email e detecção de spoofing
- **Integração com APIs**:
  - VirusTotal
  - URLScan.io
  - Shodan
  - ThreatFox
  - AlienVault OTX
  - Hybrid Analysis
  - MalShare
  - Joe Sandbox
- **Sistema de configuração** - Gerenciamento de chaves de API
- **Sistema de logs** - Registro completo de análises
- **Relatórios JSON** - Saída estruturada de resultados
- **Scripts de instalação** - Instalador automático de dependências
- **Interface colorida** - Output visual com códigos de cores
- **Documentação completa**:
  - README.md
  - QUICK_START.md
  - MENU_GUIDE.md
  - TECHNICAL_DETAILS.md
  - EXECUTIVE_SUMMARY.md

### 🎯 Funcionalidades Principais
- **start.sh** - Script de inicialização com seleção de modo
- **menu.sh** - Menu interativo principal
- **security_analyzer.sh** - Engine de análise
- **threat_intel_apis.sh** - Módulo de APIs
- **email_analyzer.sh** - Analisador de emails
- **config.sh** - Configurações globais
- **install_dependencies.sh** - Instalador de dependências

---

## 📋 Tipos de Mudanças

- **✅ Adicionado** - Para novas funcionalidades
- **🔄 Alterado** - Para mudanças em funcionalidades existentes
- **🔧 Corrigido** - Para correções de bugs
- **🗑️ Removido** - Para funcionalidades removidas
- **🔒 Segurança** - Para correções de vulnerabilidades
- **🎨 Melhorado** - Para melhorias de interface/UX
- **📚 Documentação** - Para mudanças na documentação
- **⚡ Performance** - Para melhorias de performance

---

## 🔗 Links

- [Repositório](https://github.com/cybersecwonderwoman/security-analyzer-tool)
- [Issues](https://github.com/cybersecwonderwoman/security-analyzer-tool/issues)
- [Releases](https://github.com/cybersecwonderwoman/security-analyzer-tool/releases)

---

**Desenvolvido com ❤️ por @cybersecwonderwoman**
