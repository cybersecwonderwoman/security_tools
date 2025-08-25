#!/bin/bash

# Script de demonstração para testar a geração de relatórios HTML

# Importar funções do script de relatórios HTML
source "$(dirname "$(readlink -f "$0")")/html_report.sh"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para simular análise de arquivo
demo_file_analysis() {
    echo -e "${CYAN}📁 ANÁLISE DE ARQUIVO${NC}"
    echo ""
    
    echo -e "${BLUE}[Informações Básicas]${NC}"
    echo "Nome: example.exe"
    echo "Tipo: PE32 executable (GUI) Intel 80386, for MS Windows"
    echo "Tamanho: 2.4 MB (2,457,600 bytes)"
    echo "Data de Modificação: 2025-07-20 15:32:45"
    echo ""
    
    echo -e "${BLUE}[Hashes]${NC}"
    echo "MD5:    d41d8cd98f00b204e9800998ecf8427e"
    echo "SHA1:   da39a3ee5e6b4b0d3255bfef95601890afd80709"
    echo "SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    echo ""
    
    echo -e "${RED}[VirusTotal] AMEAÇA DETECTADA!${NC}"
    echo "  Malicioso: 45 detecções"
    echo "  Suspeito: 12 detecções"
    echo "  Família: Trojan.Generic"
    echo ""
    
    echo -e "${RED}[ThreatFox] IOC MALICIOSO ENCONTRADO!${NC}"
    echo "  Malware: Trojan.Generic"
    echo "  Confiança: 95%"
    echo "  Tags: exe, trojan, backdoor"
    echo "  Primeira Detecção: 2025-06-15"
    echo ""
    
    echo -e "${BLUE}[Metadados]${NC}"
    echo "  Compilado em: 2025-06-10 03:45:22"
    echo "  Versão: 1.2.3"
    echo "  Empresa: Unknown"
    echo "  Descrição: Windows System File"
    echo ""
    
    echo "Análise concluída."
}

# Função para simular análise de URL
demo_url_analysis() {
    echo -e "${CYAN}🌐 ANÁLISE DE URL${NC}"
    echo ""
    
    echo -e "${BLUE}[Informações Básicas]${NC}"
    echo "URL: https://example.com/download.php?id=1234"
    echo "Domínio: example.com"
    echo "Caminho: /download.php"
    echo "Parâmetros: id=1234"
    echo ""
    
    echo -e "${GREEN}[URLScan.io] URL SEGURA${NC}"
    echo "  Reputação: Boa"
    echo "  Última verificação: 2025-07-22"
    echo "  Pontuação de Segurança: 95/100"
    echo ""
    
    echo -e "${BLUE}[Análise de Conteúdo]${NC}"
    echo "  Tipo de conteúdo: text/html"
    echo "  Servidor: Apache/2.4.41"
    echo "  Redirecionamentos: 0"
    echo "  Cookies: 3"
    echo "  Scripts externos: 2"
    echo ""
    
    echo -e "${BLUE}[Cabeçalhos HTTP]${NC}"
    echo "  Content-Type: text/html; charset=UTF-8"
    echo "  Server: Apache/2.4.41 (Ubuntu)"
    echo "  X-Frame-Options: SAMEORIGIN"
    echo "  Content-Security-Policy: default-src 'self'"
    echo ""
    
    echo "Análise concluída."
}

# Função para simular análise de domínio
demo_domain_analysis() {
    echo -e "${CYAN}🏠 ANÁLISE DE DOMÍNIO${NC}"
    echo ""
    
    echo -e "${BLUE}[Informações Básicas]${NC}"
    echo "Domínio: malicious-example.com"
    echo "Status: Ativo"
    echo "Criado em: 2025-01-15"
    echo ""
    
    echo -e "${BLUE}[Registros DNS]${NC}"
    echo "A: 192.168.1.1"
    echo "MX: mail.malicious-example.com (Prioridade: 10)"
    echo "NS: ns1.malicious-example.com, ns2.malicious-example.com"
    echo "TXT: v=spf1 include:_spf.malicious-example.com ~all"
    echo "DMARC: v=DMARC1; p=reject; rua=mailto:dmarc@malicious-example.com"
    echo ""
    
    echo -e "${YELLOW}[WHOIS] Informações de Registro${NC}"
    echo "  Registrado em: 2025-01-15"
    echo "  Expira em: 2026-01-15"
    echo "  Registrador: Example Registrar, Inc."
    echo "  Nome do Registrante: REDACTED FOR PRIVACY"
    echo "  Email do Registrante: REDACTED FOR PRIVACY"
    echo ""
    
    echo -e "${RED}[Shodan] SERVIÇOS SUSPEITOS DETECTADOS${NC}"
    echo "  Portas abertas: 21, 22, 80, 443, 8080"
    echo "  Vulnerabilidades: CVE-2023-1234, CVE-2024-5678"
    echo "  Serviços: FTP, SSH, HTTP, HTTPS, Proxy"
    echo "  Sistema Operacional: Ubuntu 22.04 LTS"
    echo ""
    
    echo -e "${YELLOW}[Reputação] DOMÍNIO SUSPEITO${NC}"
    echo "  Blacklists: 2/25"
    echo "  Pontuação de Risco: 65/100"
    echo "  Categorias: Suspeito, Recém-registrado"
    echo ""
    
    echo "Análise concluída."
}

# Menu de demonstração
show_demo_menu() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DEMONSTRAÇÃO DE RELATÓRIOS HTML                          ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo "  [1] 📁 Demo Análise de Arquivo"
    echo "  [2] 🌐 Demo Análise de URL"
    echo "  [3] 🏠 Demo Análise de Domínio"
    echo "  [4] 📊 Gerenciar Relatórios"
    echo
    echo "  [0] 🚪 Sair"
    echo
    echo -n "Escolha uma opção: "
    read -r option
    
    case "$option" in
        1)
            # Capturar a saída da análise e gerar relatório
            output=$(demo_file_analysis)
            echo "$output"
            report_file=$(generate_html_report "Arquivo" "example.exe" "$output")
            
            echo
            echo -e "${CYAN}Relatório HTML gerado: $report_file${NC}"
            echo -n "Deseja abrir o relatório no navegador? (s/n): "
            read -r open_browser
            
            if [[ "$open_browser" == "s" || "$open_browser" == "S" ]]; then
                open_report "$report_file"
            fi
            ;;
        2)
            # Capturar a saída da análise e gerar relatório
            output=$(demo_url_analysis)
            echo "$output"
            report_file=$(generate_html_report "URL" "https://example.com/download.php?id=1234" "$output")
            
            echo
            echo -e "${CYAN}Relatório HTML gerado: $report_file${NC}"
            echo -n "Deseja abrir o relatório no navegador? (s/n): "
            read -r open_browser
            
            if [[ "$open_browser" == "s" || "$open_browser" == "S" ]]; then
                open_report "$report_file"
            fi
            ;;
        3)
            # Capturar a saída da análise e gerar relatório
            output=$(demo_domain_analysis)
            echo "$output"
            report_file=$(generate_html_report "Domínio" "malicious-example.com" "$output")
            
            echo
            echo -e "${CYAN}Relatório HTML gerado: $report_file${NC}"
            echo -n "Deseja abrir o relatório no navegador? (s/n): "
            read -r open_browser
            
            if [[ "$open_browser" == "s" || "$open_browser" == "S" ]]; then
                open_report "$report_file"
            fi
            ;;
        4)
            # Listar relatórios
            list_reports
            ;;
        0)
            # Parar o servidor se estiver rodando
            stop_report_server
            exit 0
            ;;
        *)
            echo "Opção inválida."
            ;;
    esac
    
    echo
    echo -n "Pressione Enter para continuar..."
    read
    show_demo_menu
}

# Criar diretório para relatórios se não existir
mkdir -p "$HOME/.security_analyzer/reports"

# Iniciar o menu de demonstração
show_demo_menu
