#!/bin/bash

# Script para testar as melhorias na formatação dos relatórios HTML

# Importar funções do script de relatórios HTML
source "$(dirname "$(readlink -f "$0")")/html_report.sh"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}Testando melhorias na formatação dos relatórios HTML...${NC}"
echo

# Gerar um relatório de teste para cada tipo de análise
echo -e "${BLUE}Gerando relatório de teste para análise de arquivo...${NC}"
output=$(demo_file_analysis 2>/dev/null || cat <<EOF
📁 ANÁLISE DE ARQUIVO

[Informações Básicas]
Nome: example.exe
Tipo: PE32 executable (GUI) Intel 80386, for MS Windows
Tamanho: 2.4 MB (2,457,600 bytes)
Data de Modificação: 2025-07-20 15:32:45

[Hashes]
MD5:    d41d8cd98f00b204e9800998ecf8427e
SHA1:   da39a3ee5e6b4b0d3255bfef95601890afd80709
SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

[VirusTotal] AMEAÇA DETECTADA!
  Malicioso: 45 detecções
  Suspeito: 12 detecções
  Família: Trojan.Generic

[ThreatFox] IOC MALICIOSO ENCONTRADO!
  Malware: Trojan.Generic
  Confiança: 95%
  Tags: exe, trojan, backdoor
  Primeira Detecção: 2025-06-15

[Metadados]
  Compilado em: 2025-06-10 03:45:22
  Versão: 1.2.3
  Empresa: Unknown
  Descrição: Windows System File

Análise concluída.
EOF
)

file_report=$(generate_html_report "Arquivo" "example.exe" "$output")
echo "Relatório gerado: $file_report"

# Gerar relatório para análise de URL
echo -e "${BLUE}Gerando relatório de teste para análise de URL...${NC}"
output=$(demo_url_analysis 2>/dev/null || cat <<EOF
🌐 ANÁLISE DE URL

[Informações Básicas]
URL: https://example.com/download.php?id=1234
Domínio: example.com
Caminho: /download.php
Parâmetros: id=1234

[URLScan.io] URL SEGURA
  Reputação: Boa
  Última verificação: 2025-07-22
  Pontuação de Segurança: 95/100

[Análise de Conteúdo]
  Tipo de conteúdo: text/html
  Servidor: Apache/2.4.41
  Redirecionamentos: 0
  Cookies: 3
  Scripts externos: 2

[Cabeçalhos HTTP]
  Content-Type: text/html; charset=UTF-8
  Server: Apache/2.4.41 (Ubuntu)
  X-Frame-Options: SAMEORIGIN
  Content-Security-Policy: default-src 'self'

Análise concluída.
EOF
)

url_report=$(generate_html_report "URL" "https://example.com/download.php?id=1234" "$output")
echo "Relatório gerado: $url_report"

# Gerar relatório para análise de domínio
echo -e "${BLUE}Gerando relatório de teste para análise de domínio...${NC}"
output=$(demo_domain_analysis 2>/dev/null || cat <<EOF
🏠 ANÁLISE DE DOMÍNIO

[Informações Básicas]
Domínio: malicious-example.com
Status: Ativo
Criado em: 2025-01-15

[Registros DNS]
A: 192.168.1.1
MX: mail.malicious-example.com (Prioridade: 10)
NS: ns1.malicious-example.com, ns2.malicious-example.com
TXT: v=spf1 include:_spf.malicious-example.com ~all
DMARC: v=DMARC1; p=reject; rua=mailto:dmarc@malicious-example.com

[WHOIS] Informações de Registro
  Registrado em: 2025-01-15
  Expira em: 2026-01-15
  Registrador: Example Registrar, Inc.
  Nome do Registrante: REDACTED FOR PRIVACY
  Email do Registrante: REDACTED FOR PRIVACY

[Shodan] SERVIÇOS SUSPEITOS DETECTADOS
  Portas abertas: 21, 22, 80, 443, 8080
  Vulnerabilidades: CVE-2023-1234, CVE-2024-5678
  Serviços: FTP, SSH, HTTP, HTTPS, Proxy
  Sistema Operacional: Ubuntu 22.04 LTS

[Reputação] DOMÍNIO SUSPEITO
  Blacklists: 2/25
  Pontuação de Risco: 65/100
  Categorias: Suspeito, Recém-registrado

Análise concluída.
EOF
)

domain_report=$(generate_html_report "Domínio" "malicious-example.com" "$output")
echo "Relatório gerado: $domain_report"

# Iniciar o servidor web
echo
echo -e "${BLUE}Iniciando servidor web para visualizar os relatórios...${NC}"
start_report_server

# Perguntar qual relatório abrir
echo
echo -e "${CYAN}Qual relatório você deseja visualizar?${NC}"
echo "1. Análise de Arquivo"
echo "2. Análise de URL"
echo "3. Análise de Domínio"
echo "4. Todos (em abas separadas)"
echo "0. Nenhum (sair)"
echo
echo -n "Escolha uma opção: "
read -r option

case "$option" in
    1)
        open_report "$file_report"
        ;;
    2)
        open_report "$url_report"
        ;;
    3)
        open_report "$domain_report"
        ;;
    4)
        open_report "$file_report"
        sleep 1
        open_report "$url_report"
        sleep 1
        open_report "$domain_report"
        ;;
    *)
        echo "Saindo..."
        ;;
esac

echo
echo -e "${CYAN}Pressione Enter para encerrar o servidor web e sair...${NC}"
read

# Parar o servidor web
stop_report_server
