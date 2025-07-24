#!/bin/bash

# Script para testar a funcionalidade de listagem de relatórios

# Importar funções necessárias
source "$(dirname "$(readlink -f "$0")")/html_report.sh"
source "$(dirname "$(readlink -f "$0")")/report_integration.sh"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🧪 TESTE DA FUNCIONALIDADE DE LISTAGEM DE RELATÓRIOS${NC}"
echo

# Verificar se existem relatórios
reports_dir="$HOME/.security_analyzer/reports"
if [[ ! -d "$reports_dir" ]]; then
    mkdir -p "$reports_dir"
fi

report_count=$(find "$reports_dir" -name "*.html" -type f 2>/dev/null | wc -l)

if [[ $report_count -eq 0 ]]; then
    echo -e "${YELLOW}📄 Nenhum relatório encontrado. Gerando alguns relatórios de exemplo...${NC}"
    echo
    
    # Gerar alguns relatórios de exemplo
    echo "Gerando relatório de arquivo..."
    file_output="📁 ANÁLISE DE ARQUIVO

[Informações Básicas]
Nome: malware.exe
Tipo: PE32 executable

[Hashes]
MD5: d41d8cd98f00b204e9800998ecf8427e
SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

[VirusTotal] AMEAÇA DETECTADA!
Malicioso: 45 detecções"
    
    generate_html_report "Arquivo" "malware.exe" "$file_output" >/dev/null
    
    echo "Gerando relatório de URL..."
    url_output="🌐 ANÁLISE DE URL

[Informações Básicas]
URL: https://safe-example.com
Domínio: safe-example.com

[URLScan.io] URL SEGURA
Reputação: Boa
Pontuação: 95/100"
    
    generate_html_report "URL" "https://safe-example.com" "$url_output" >/dev/null
    
    echo "Gerando relatório de domínio..."
    domain_output="🏠 ANÁLISE DE DOMÍNIO

[Informações Básicas]
Domínio: suspicious-site.com

[Registros DNS]
A: 192.168.1.100

[Reputação] DOMÍNIO SUSPEITO
Blacklists: 3/25
Pontuação de Risco: 75/100"
    
    generate_html_report "Domínio" "suspicious-site.com" "$domain_output" >/dev/null
    
    echo -e "${GREEN}✅ Relatórios de exemplo gerados!${NC}"
    echo
fi

# Testar a função de listagem
echo -e "${BLUE}📋 Testando a função list_reports...${NC}"
echo

# Chamar a função de listagem
list_reports

echo
echo -e "${GREEN}✅ Teste concluído!${NC}"
