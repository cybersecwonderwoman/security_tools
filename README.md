# 🛡️ Security Analyzer Tool

**Ferramenta Avançada de Análise de Segurança da Informação**

Uma solução completa desenvolvida em Bash para análise profissional de ameaças cibernéticas, integrando múltiplas fontes de threat intelligence para detectar arquivos maliciosos, URLs perigosas, domínios suspeitos e atividades de phishing.

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Funcionalidades](#-funcionalidades)
- [Fontes de Threat Intelligence](#️-fontes-de-threat-intelligence-integradas)
- [Instalação](#-instalação)
- [Como Usar](#-como-usar)
- [Exemplos Práticos](#-exemplos-práticos)
- [Interpretação de Resultados](#-interpretação-de-resultados)
- [Logs e Relatórios](#-logs-e-relatórios)
- [Solução de Problemas](#-solução-de-problemas)
- [Contribuição](#-contribuição)

---

## 🎯 Visão Geral

O **Security Analyzer Tool** é uma ferramenta interativa que permite aos profissionais de segurança cibernética realizar análises abrangentes de potenciais ameaças. A ferramenta consulta automaticamente múltiplas bases de dados de threat intelligence e fornece relatórios detalhados sobre a segurança dos alvos analisados.

### ✨ Principais Características

- 🔍 **Análise Multifonte**: Integra 8+ fontes de threat intelligence
- 🎨 **Interface Colorida**: Output visual com códigos de cores para fácil interpretação
- 📊 **Relatórios Detalhados**: Geração automática de relatórios
- 📝 **Sistema de Logs**: Registro completo de todas as análises
- 📚 **Documentação Interativa**: Acesso à documentação via navegador
- 🔒 **Segurança**: Proteção de chaves de API e dados sensíveis

## 🔍 Funcionalidades

### 📁 Análise de Arquivos
- Cálculo automático de hashes (MD5, SHA1, SHA256)
- Verificação contra bases de malware conhecidas
- Detecção de tipo de arquivo e metadados

### 🌐 Análise de URLs
- Verificação de reputação de URLs
- Análise de conteúdo via URLScan.io
- Detecção de phishing e malware

### 🏠 Análise de Domínios
- Resolução DNS e verificação de registros
- Consulta WHOIS para informações de registro
- Verificação em blacklists conhecidas

### 🔢 Análise de Hashes
- Suporte para MD5, SHA1, SHA256
- Consulta em múltiplas bases de malware
- Verificação de IOCs conhecidos

### 📧 Análise de Emails
- Verificação de domínios de email
- Análise de autenticação (SPF, DKIM, DMARC)
- Detecção de spoofing e phishing

### 📋 Análise de Cabeçalhos de Email
- Extração automática de IPs
- Verificação de blacklists de email
- Análise de caminho de entrega

### 🌐 Análise de Endereços IP
- Geolocalização precisa de IPs
- Verificação em listas de bloqueio (RBLs)
- Análise de portas abertas
- Verificação de reputação

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

### 1. Clonar o repositório

```bash
git clone https://github.com/seu-usuario/security_tools.git
cd security_tools
```

### 2. Instalar Dependências

```bash
# Executar o instalador automático
./install_dependencies.sh
```

### 3. Configurar Chaves de API (Opcional)

Execute a ferramenta e selecione a opção 8 (Configurar APIs) para configurar suas chaves de API para:
- VirusTotal
- Shodan
- URLScan.io
- Hybrid Analysis

## 🚀 Como Usar

### Iniciar a ferramenta

```bash
./start.sh
```

Ou diretamente:

```bash
./security_tool.sh
```

### Menu Interativo

O menu interativo oferece as seguintes opções:

1. **📁 Analisar Arquivo** - Verificar arquivos suspeitos
2. **🌐 Analisar URL** - Verificar links maliciosos
3. **🏠 Analisar Domínio** - Investigar domínios suspeitos
4. **🔢 Analisar Hash** - Consultar hashes em bases de dados
5. **📧 Analisar Email** - Verificar endereços de email
6. **📋 Analisar Cabeçalho** - Analisar headers de email
7. **🌐 Analisar IP** - Verificar endereços IP suspeitos
8. **⚙️ Configurar APIs** - Configurar chaves de acesso
9. **📊 Ver Estatísticas** - Relatórios de uso
10. **📝 Ver Logs** - Visualizar logs de análise
11. **🧪 Executar Testes** - Testar funcionalidades
12. **📚 Ajuda** - Manual de uso (via navegador)
13. **ℹ️ Sobre** - Informações da ferramenta

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
/security_tools/
├── security_tool.sh      # Script principal
├── install_dependencies.sh   # Instalador
├── start.sh              # Script de inicialização
├── README.md             # Documentação
└── docs/                 # Documentação adicional
```

## 🔧 Configuração Avançada

### 🔑 Configuração de APIs

O submenu de configuração de APIs permite:

1. **Visualizar Status**: Verificar quais APIs estão configuradas
2. **Configurar Individualmente**: Selecionar e configurar cada API separadamente
3. **Verificar Segurança**: Garantir que as chaves estão armazenadas com permissões seguras

Para acessar, selecione a opção 8 (⚙️ Configurar APIs) no menu principal.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         CONFIGURAÇÃO DE APIs                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

  [1] 🔑 VirusTotal API          - ✅ Configurada
  [2] 🔑 Shodan API              - ❌ Não configurada
  [3] 🔑 URLScan.io API          - ✅ Configurada
  [4] 🔑 Hybrid Analysis API      - ❌ Não configurada

  [5] 🔄 Verificar Status         - Verificar todas as chaves
  [6] 🔒 Permissões               - Verificar permissões do arquivo

  [0] 🔙 Voltar                   - Retornar ao menu principal
```

### Logs e Relatórios

- **Logs**: `~/.security_analyzer/analysis.log`
- **Cache**: `~/.security_analyzer/cache/`
- **Documentação**: `~/.security_analyzer/docs/`

## 🔒 Considerações de Segurança

1. **Chaves de API**: Mantenha suas chaves seguras (arquivo com permissão 600)
2. **Arquivos Suspeitos**: Execute em ambiente isolado
3. **Logs**: Contêm informações sensíveis, proteja adequadamente
4. **Rate Limiting**: Respeite os limites das APIs

## 🐛 Solução de Problemas

### Dependências Faltando
```bash
# Reinstalar dependências
./install_dependencies.sh
```

### Problemas de API
```bash
# Reconfigurar chaves
# Use a opção 8 no menu principal
```

### Permissões
```bash
# Corrigir permissões
chmod +x security_tool.sh
chmod +x install_dependencies.sh
chmod +x start.sh
chmod 600 ~/.security_analyzer/api_keys.conf
```

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
- Verifique a documentação via opção 12 do menu principal

---

**Desenvolvido com ❤️ para a comunidade de cibersegurança**

*@cybersecwonderwoman*
