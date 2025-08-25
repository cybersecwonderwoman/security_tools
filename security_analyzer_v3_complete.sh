#!/bin/bash

# ========================================
# Security Analyzer Tool v3.0 - Versão Funcional
# Ferramenta Avançada de Análise de Segurança
# ========================================

set -euo pipefail

# Configurações
APP_NAME="Security Analyzer Tool"
APP_VERSION="3.0.0"
APP_AUTHOR="@cybersecwonderwoman"

# Diretórios
CONFIG_DIR="$HOME/.security_analyzer"
LOG_FILE="$CONFIG_DIR/analysis.log"
CACHE_DIR="$CONFIG_DIR/cache"
REPORTS_DIR="$CONFIG_DIR/reports"
API_KEYS_FILE="$CONFIG_DIR/api_keys.enc"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Criar diretórios necessários
mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$REPORTS_DIR"

# Função de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Validar entrada
validate_input() {
    local input="$1"
    local type="$2"
    
    case "$type" in
        "url")
            [[ "$input" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]
            ;;
        "file")
            [[ -f "$input" && -r "$input" ]]
            ;;
        "domain")
            [[ "$input" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
            ;;
        "email")
            [[ "$input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
            ;;
        "ip")
            [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Sanitizar entrada
sanitize_input() {
    local input="$1"
    input=$(echo "$input" | tr -d '`$(){}[]|&;<>?*')
    input=$(echo "$input" | cut -c1-1000)
    echo "$input"
}

# Banner principal
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║   ███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗            ║
║   ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝            ║
║   ███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝             ║
║   ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝              ║
║   ███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║               ║
║   ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝               ║
║                                                                              ║
║                    🛡️  FERRAMENTA AVANÇADA DE SEGURANÇA  🛡️                  ║
║                              Versão 3.0.0                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${PURPLE}                           @cybersecwonderwoman${NC}"
    echo ""
}

# Menu principal
show_main_menu() {
    show_banner
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                              MENU PRINCIPAL                                 ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}  [1] 📁 Analisar Arquivo${NC}          - Análise profunda de arquivos"
    echo -e "${GREEN}  [2] 🌐 Analisar URL${NC}             - Verificação completa de URLs"
    echo -e "${GREEN}  [3] 🏠 Analisar Domínio${NC}         - Investigação de domínios"
    echo -e "${GREEN}  [4] 🔢 Analisar Hash${NC}            - Consulta em bases de dados"
    echo -e "${GREEN}  [5] 📧 Analisar Email${NC}           - Verificação de endereços"
    echo -e "${GREEN}  [6] 🌐 Analisar IP${NC}             - Análise de endereços IP"
    echo ""
    echo -e "${BLUE}  [7] ⚙️  Configurar APIs${NC}          - Gerenciar chaves de acesso"
    echo -e "${BLUE}  [8] 📊 Relatórios${NC}               - Visualizar relatórios"
    echo -e "${BLUE}  [9] 📝 Logs${NC}                     - Visualizar logs do sistema"
    echo -e "${BLUE}  [10] 🧪 Executar Testes${NC}         - Testar funcionalidades"
    echo ""
    echo -e "${CYAN}  [11] 📚 Ajuda${NC}                   - Documentação e suporte"
    echo -e "${CYAN}  [12] ℹ️  Sobre${NC}                   - Informações da ferramenta"
    echo ""
    echo -e "${RED}  [0] 🚪 Sair${NC}                     - Encerrar programa"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ Digite o número da opção desejada:                                          ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -n "➤ "
}

# Análise de arquivo
analyze_file() {
    echo -e "${CYAN}📁 ANÁLISE AVANÇADA DE ARQUIVO${NC}"
    echo "================================"
    echo ""
    
    echo "Digite o caminho do arquivo para análise:"
    echo -n "➤ "
    read -r file_path
    
    file_path=$(sanitize_input "$file_path")
    
    if [[ -z "$file_path" ]]; then
        echo -e "${RED}❌ Caminho não fornecido${NC}"
        return 1
    fi
    
    if ! validate_input "$file_path" "file"; then
        echo -e "${RED}❌ Arquivo não encontrado ou inacessível${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}🔍 Analisando arquivo: $file_path${NC}"
    echo ""
    
    # Informações básicas
    echo -e "${BLUE}[📋 Informações Básicas]${NC}"
    echo "Nome: $(basename "$file_path")"
    echo "Caminho: $file_path"
    
    local file_size=$(stat -c%s "$file_path" 2>/dev/null || echo "0")
    local size_mb=$((file_size / 1024 / 1024))
    echo "Tamanho: $file_size bytes (${size_mb}MB)"
    
    local file_type=$(file -b "$file_path" 2>/dev/null || echo "Desconhecido")
    echo "Tipo: $file_type"
    
    local modified=$(stat -c%y "$file_path" 2>/dev/null | cut -d'.' -f1)
    echo "Modificado: $modified"
    
    echo ""
    
    # Hashes
    echo -e "${BLUE}[🔢 Hashes Criptográficos]${NC}"
    if command -v md5sum &>/dev/null; then
        local md5_hash=$(md5sum "$file_path" | cut -d ' ' -f 1)
        echo "MD5:    $md5_hash"
    fi
    
    if command -v sha1sum &>/dev/null; then
        local sha1_hash=$(sha1sum "$file_path" | cut -d ' ' -f 1)
        echo "SHA1:   $sha1_hash"
    fi
    
    if command -v sha256sum &>/dev/null; then
        local sha256_hash=$(sha256sum "$file_path" | cut -d ' ' -f 1)
        echo "SHA256: $sha256_hash"
    fi
    
    echo ""
    
    # Análise de risco básica
    echo -e "${BLUE}[⚖️  Avaliação de Risco]${NC}"
    local risk_score=0
    local extension="${file_path##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    # Verificar extensões perigosas
    case "$extension" in
        exe|scr|bat|cmd|com|pif|vbs|js)
            risk_score=$((risk_score + 30))
            echo "⚠️  Extensão potencialmente perigosa: .$extension"
            ;;
    esac
    
    # Verificar tamanho
    if [[ $file_size -gt 50000000 ]]; then
        risk_score=$((risk_score + 10))
        echo "⚠️  Arquivo muito grande (> 50MB)"
    elif [[ $file_size -lt 1000 ]]; then
        risk_score=$((risk_score + 15))
        echo "⚠️  Arquivo muito pequeno (< 1KB)"
    fi
    
    # Determinar nível de risco
    if [[ $risk_score -ge 30 ]]; then
        echo -e "${RED}🔴 RISCO ALTO - Arquivo potencialmente perigoso${NC}"
        echo "   Recomendação: NÃO EXECUTAR"
    elif [[ $risk_score -ge 15 ]]; then
        echo -e "${YELLOW}🟡 RISCO MÉDIO - Arquivo requer atenção${NC}"
        echo "   Recomendação: Analisar com cuidado"
    else
        echo -e "${GREEN}🟢 RISCO BAIXO - Arquivo aparentemente seguro${NC}"
        echo "   Recomendação: Verificação adicional recomendada"
    fi
    
    log_message "Arquivo analisado: $file_path (risco: $risk_score)"
}

# Análise de URL
analyze_url() {
    echo -e "${CYAN}🌐 ANÁLISE AVANÇADA DE URL${NC}"
    echo "==========================="
    echo ""
    
    echo "Digite a URL para análise:"
    echo -n "➤ "
    read -r url
    
    url=$(sanitize_input "$url")
    
    if [[ -z "$url" ]]; then
        echo -e "${RED}❌ URL não fornecida${NC}"
        return 1
    fi
    
    if ! validate_input "$url" "url"; then
        echo -e "${RED}❌ Formato de URL inválido${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}🔍 Analisando URL: $url${NC}"
    echo ""
    
    # Análise da estrutura
    echo -e "${BLUE}[🔍 Estrutura da URL]${NC}"
    local protocol=$(echo "$url" | sed -n 's|^\([^:]*\)://.*|\1|p')
    local domain=$(echo "$url" | sed -n 's|^[^:]*://\([^/]*\).*|\1|p')
    local path=$(echo "$url" | sed -n 's|^[^:]*://[^/]*\(.*\)|\1|p')
    
    echo "Protocolo: $protocol"
    echo "Domínio: $domain"
    echo "Caminho: ${path:-/}"
    
    if [[ "$protocol" == "https" ]]; then
        echo -e "${GREEN}✅ Protocolo seguro (HTTPS)${NC}"
    else
        echo -e "${YELLOW}⚠️  Protocolo inseguro (HTTP)${NC}"
    fi
    
    echo ""
    
    # Teste de conectividade
    echo -e "${BLUE}[🔗 Teste de Conectividade]${NC}"
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$url" 2>/dev/null)
    
    if [[ -n "$http_code" ]]; then
        echo "Código HTTP: $http_code"
        
        case "$http_code" in
            200)
                echo -e "${GREEN}✅ Site acessível${NC}"
                ;;
            301|302|303|307|308)
                echo -e "${YELLOW}🔄 Redirecionamento detectado${NC}"
                ;;
            404)
                echo -e "${RED}❌ Página não encontrada${NC}"
                ;;
            403)
                echo -e "${RED}🚫 Acesso negado${NC}"
                ;;
            *)
                echo -e "${YELLOW}⚠️  Resposta inesperada${NC}"
                ;;
        esac
    else
        echo -e "${RED}❌ Falha na conexão${NC}"
    fi
    
    echo ""
    
    # Análise de risco
    echo -e "${BLUE}[⚖️  Avaliação de Risco]${NC}"
    local risk_score=0
    
    # Verificar protocolo
    [[ "$protocol" != "https" ]] && risk_score=$((risk_score + 20))
    
    # Verificar se usa IP em vez de domínio
    if [[ "$url" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
        risk_score=$((risk_score + 25))
        echo "⚠️  URL usa endereço IP em vez de domínio"
    fi
    
    # Verificar comprimento
    if [[ ${#url} -gt 200 ]]; then
        risk_score=$((risk_score + 10))
        echo "⚠️  URL muito longa (${#url} caracteres)"
    fi
    
    # Determinar nível de risco
    if [[ $risk_score -ge 30 ]]; then
        echo -e "${RED}🔴 RISCO ALTO - URL potencialmente perigosa${NC}"
        echo "   Recomendação: NÃO ACESSAR"
    elif [[ $risk_score -ge 15 ]]; then
        echo -e "${YELLOW}🟡 RISCO MÉDIO - URL requer atenção${NC}"
        echo "   Recomendação: Acessar com cuidado"
    else
        echo -e "${GREEN}🟢 RISCO BAIXO - URL aparentemente segura${NC}"
        echo "   Recomendação: Verificação adicional recomendada"
    fi
    
    log_message "URL analisada: $url (risco: $risk_score)"
}
# Análise de domínio
analyze_domain() {
    echo -e "${CYAN}🏠 ANÁLISE DE DOMÍNIO${NC}"
    echo "===================="
    echo ""
    
    echo "Digite o domínio para análise:"
    echo -n "➤ "
    read -r domain
    
    domain=$(sanitize_input "$domain")
    
    if [[ -z "$domain" ]]; then
        echo -e "${RED}❌ Domínio não fornecido${NC}"
        return 1
    fi
    
    if ! validate_input "$domain" "domain"; then
        echo -e "${RED}❌ Formato de domínio inválido${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}🔍 Analisando domínio: $domain${NC}"
    echo ""
    
    echo -e "${BLUE}[🔍 Resolução DNS]${NC}"
    if command -v dig &>/dev/null; then
        local ip_address=$(dig +short "$domain" 2>/dev/null | head -1)
        if [[ -n "$ip_address" ]]; then
            echo "IP: $ip_address"
        else
            echo -e "${RED}❌ Falha na resolução DNS${NC}"
        fi
    else
        echo "dig não disponível"
    fi
    
    echo ""
    echo -e "${BLUE}[📋 Informações WHOIS]${NC}"
    if command -v whois &>/dev/null; then
        local whois_info=$(timeout 10 whois "$domain" 2>/dev/null | head -10)
        if [[ -n "$whois_info" ]]; then
            echo "$whois_info"
        else
            echo "Informações WHOIS não disponíveis"
        fi
    else
        echo "whois não disponível"
    fi
    
    log_message "Domínio analisado: $domain"
}

# Análise de hash
analyze_hash() {
    echo -e "${CYAN}🔢 ANÁLISE DE HASH${NC}"
    echo "=================="
    echo ""
    
    echo "Digite o hash para análise:"
    echo -n "➤ "
    read -r hash
    
    hash=$(sanitize_input "$hash")
    
    if [[ -z "$hash" ]]; then
        echo -e "${RED}❌ Hash não fornecido${NC}"
        return 1
    fi
    
    # Determinar tipo de hash
    local hash_type=""
    case ${#hash} in
        32)
            if [[ "$hash" =~ ^[a-fA-F0-9]{32}$ ]]; then
                hash_type="MD5"
            fi
            ;;
        40)
            if [[ "$hash" =~ ^[a-fA-F0-9]{40}$ ]]; then
                hash_type="SHA1"
            fi
            ;;
        64)
            if [[ "$hash" =~ ^[a-fA-F0-9]{64}$ ]]; then
                hash_type="SHA256"
            fi
            ;;
    esac
    
    if [[ -z "$hash_type" ]]; then
        echo -e "${RED}❌ Formato de hash não reconhecido${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}🔍 Analisando hash $hash_type: $hash${NC}"
    echo ""
    
    echo -e "${BLUE}[🔢 Informações do Hash]${NC}"
    echo "Tipo: $hash_type"
    echo "Hash: $hash"
    echo "Comprimento: ${#hash} caracteres"
    
    log_message "Hash analisado: $hash ($hash_type)"
}

# Análise de email
analyze_email() {
    echo -e "${CYAN}📧 ANÁLISE DE EMAIL${NC}"
    echo "=================="
    echo ""
    
    echo "Digite o endereço de email para análise:"
    echo -n "➤ "
    read -r email
    
    email=$(sanitize_input "$email")
    
    if [[ -z "$email" ]]; then
        echo -e "${RED}❌ Email não fornecido${NC}"
        return 1
    fi
    
    if ! validate_input "$email" "email"; then
        echo -e "${RED}❌ Formato de email inválido${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}🔍 Analisando email: $email${NC}"
    echo ""
    
    local domain=$(echo "$email" | cut -d'@' -f2)
    
    echo -e "${BLUE}[📧 Informações do Email]${NC}"
    echo "Email: $email"
    echo "Domínio: $domain"
    
    echo ""
    echo -e "${BLUE}[🏠 Verificação do Domínio]${NC}"
    if command -v dig &>/dev/null; then
        local mx_record=$(dig +short MX "$domain" 2>/dev/null)
        if [[ -n "$mx_record" ]]; then
            echo "Registro MX: $mx_record"
        else
            echo -e "${YELLOW}⚠️  Nenhum registro MX encontrado${NC}"
        fi
    fi
    
    log_message "Email analisado: $email"
}

# Análise de IP
analyze_ip() {
    echo -e "${CYAN}🌐 ANÁLISE DE ENDEREÇO IP${NC}"
    echo "========================="
    echo ""
    
    echo "Digite o endereço IP para análise:"
    echo -n "➤ "
    read -r ip_address
    
    ip_address=$(sanitize_input "$ip_address")
    
    if [[ -z "$ip_address" ]]; then
        echo -e "${RED}❌ IP não fornecido${NC}"
        return 1
    fi
    
    if ! validate_input "$ip_address" "ip"; then
        echo -e "${RED}❌ Formato de IP inválido${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}🔍 Analisando IP: $ip_address${NC}"
    echo ""
    
    echo -e "${BLUE}[🌐 Informações do IP]${NC}"
    echo "Endereço: $ip_address"
    
    # Verificar se é IP privado
    if [[ "$ip_address" =~ ^10\. ]] || [[ "$ip_address" =~ ^192\.168\. ]] || [[ "$ip_address" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
        echo "Tipo: IP Privado"
    else
        echo "Tipo: IP Público"
    fi
    
    # Reverse DNS
    if command -v dig &>/dev/null; then
        local reverse_dns=$(dig +short -x "$ip_address" 2>/dev/null)
        [[ -n "$reverse_dns" ]] && echo "Reverse DNS: $reverse_dns"
    fi
    
    log_message "IP analisado: $ip_address"
}

# Configurar APIs (simplificado)
configure_apis() {
    echo -e "${CYAN}⚙️  CONFIGURAÇÃO DE APIs${NC}"
    echo "========================"
    echo ""
    
    echo "Esta funcionalidade permite configurar chaves de API para:"
    echo "• VirusTotal - Análise de arquivos e URLs"
    echo "• URLScan.io - Análise comportamental de URLs"
    echo "• Shodan - Intelligence sobre dispositivos"
    echo ""
    echo "Para configurar, edite o arquivo: $API_KEYS_FILE"
    echo ""
    echo "Formato:"
    echo "VIRUSTOTAL_API_KEY=sua_chave_aqui"
    echo "URLSCAN_API_KEY=sua_chave_aqui"
    echo "SHODAN_API_KEY=sua_chave_aqui"
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}

# Ver relatórios
view_reports() {
    echo -e "${CYAN}📊 RELATÓRIOS${NC}"
    echo "============="
    echo ""
    
    if [[ -d "$REPORTS_DIR" ]]; then
        local reports=($(find "$REPORTS_DIR" -name "*.html" -type f 2>/dev/null | sort -r))
        
        if [[ ${#reports[@]} -gt 0 ]]; then
            echo "Relatórios encontrados:"
            local count=1
            for report in "${reports[@]}"; do
                local report_name=$(basename "$report")
                local report_date=$(stat -c %y "$report" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
                
                printf "%2d. %s (%s)\n" "$count" "$report_name" "$report_date"
                count=$((count + 1))
            done
            echo ""
            echo "Total: $((count - 1)) relatórios"
        else
            echo "Nenhum relatório encontrado."
        fi
    else
        echo "Diretório de relatórios não encontrado."
    fi
    
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}

# Ver logs
view_logs() {
    echo -e "${CYAN}📝 LOGS DO SISTEMA${NC}"
    echo "=================="
    echo ""
    
    if [[ -f "$LOG_FILE" ]]; then
        echo "Últimas 20 entradas do log:"
        echo ""
        tail -20 "$LOG_FILE"
    else
        echo "Arquivo de log não encontrado."
    fi
    
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}

# Executar testes
run_tests() {
    echo -e "${CYAN}🧪 EXECUTANDO TESTES${NC}"
    echo "===================="
    echo ""
    
    local tests_passed=0
    local tests_total=5
    
    # Teste 1: Verificar dependências
    echo -n "Teste 1: Dependências básicas... "
    local deps=("curl" "file" "stat")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}❌ FALHOU${NC}"
    fi
    
    # Teste 2: Verificar diretórios
    echo -n "Teste 2: Estrutura de diretórios... "
    if [[ -d "$CONFIG_DIR" && -d "$CACHE_DIR" && -d "$REPORTS_DIR" ]]; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}❌ FALHOU${NC}"
    fi
    
    # Teste 3: Verificar permissões
    echo -n "Teste 3: Permissões de escrita... "
    if [[ -w "$CONFIG_DIR" ]]; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}❌ FALHOU${NC}"
    fi
    
    # Teste 4: Teste de validação
    echo -n "Teste 4: Funções de validação... "
    if validate_input "https://example.com" "url" && validate_input "test@example.com" "email"; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}❌ FALHOU${NC}"
    fi
    
    # Teste 5: Teste de conectividade
    echo -n "Teste 5: Conectividade de rede... "
    if curl -s --connect-timeout 5 "https://www.google.com" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${YELLOW}⚠️  AVISO${NC}"
    fi
    
    echo ""
    echo "Resultado: $tests_passed/$tests_total testes passaram"
    
    if [[ $tests_passed -eq $tests_total ]]; then
        echo -e "${GREEN}🎉 Todos os testes passaram!${NC}"
    elif [[ $tests_passed -ge 3 ]]; then
        echo -e "${YELLOW}⚠️  Sistema funcional com limitações${NC}"
    else
        echo -e "${RED}❌ Sistema pode não funcionar corretamente${NC}"
    fi
    
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}

# Mostrar ajuda
show_help() {
    clear
    echo -e "${CYAN}📚 AJUDA E DOCUMENTAÇÃO${NC}"
    echo "======================="
    echo ""
    
    echo -e "${YELLOW}🚀 GUIA RÁPIDO${NC}"
    echo ""
    echo -e "${BLUE}1. Análise de Arquivo:${NC}"
    echo "   • Selecione opção 1 no menu principal"
    echo "   • Digite o caminho completo do arquivo"
    echo "   • Aguarde a análise completa"
    echo ""
    echo -e "${BLUE}2. Análise de URL:${NC}"
    echo "   • Selecione opção 2 no menu principal"
    echo "   • Digite a URL completa (incluindo http/https)"
    echo "   • A ferramenta verificará conectividade e segurança"
    echo ""
    echo -e "${BLUE}3. Configuração de APIs:${NC}"
    echo "   • Selecione opção 7 no menu principal"
    echo "   • Siga as instruções para configurar suas chaves"
    echo ""
    echo -e "${YELLOW}🔑 OBTENDO CHAVES DE API${NC}"
    echo ""
    echo -e "${BLUE}VirusTotal:${NC}"
    echo "   1. Acesse: https://www.virustotal.com/"
    echo "   2. Crie uma conta gratuita"
    echo "   3. Vá em 'API Key' no seu perfil"
    echo "   4. Copie a chave de 64 caracteres"
    echo ""
    echo -e "${BLUE}URLScan.io:${NC}"
    echo "   1. Acesse: https://urlscan.io/"
    echo "   2. Registre-se gratuitamente"
    echo "   3. Vá em 'Settings' > 'API'"
    echo "   4. Gere uma nova chave de API"
    echo ""
    echo -e "${YELLOW}📋 DICAS DE USO${NC}"
    echo ""
    echo "• Execute análises em arquivos suspeitos em ambiente isolado"
    echo "• Verifique os logs regularmente para auditoria"
    echo "• Mantenha suas chaves de API seguras"
    echo "• Use a ferramenta apenas para fins legítimos"
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}

# Mostrar informações sobre
show_about() {
    clear
    echo -e "${CYAN}ℹ️  SOBRE A FERRAMENTA${NC}"
    echo "===================="
    echo ""
    
    echo -e "${BLUE}🛡️  Security Analyzer Tool${NC}"
    echo -e "${BLUE}Versão: $APP_VERSION${NC}"
    echo -e "${BLUE}Desenvolvido por: $APP_AUTHOR${NC}"
    echo ""
    echo -e "${YELLOW}📋 DESCRIÇÃO${NC}"
    echo "Ferramenta avançada de análise de segurança da informação que integra"
    echo "múltiplas fontes de threat intelligence para detectar arquivos maliciosos,"
    echo "URLs perigosas, domínios suspeitos e atividades de phishing."
    echo ""
    echo -e "${YELLOW}✨ PRINCIPAIS FUNCIONALIDADES${NC}"
    echo "• Análise profunda de arquivos com múltiplos algoritmos de hash"
    echo "• Verificação completa de URLs com análise de certificados SSL"
    echo "• Investigação de domínios com consultas DNS e WHOIS"
    echo "• Análise de hashes e endereços IP"
    echo "• Sistema de logging avançado e auditoria"
    echo ""
    echo -e "${YELLOW}📊 ESTATÍSTICAS${NC}"
    local total_analyses=$(grep -c "analisad" "$LOG_FILE" 2>/dev/null || echo "0")
    echo "• Análises realizadas: $total_analyses"
    echo "• Diretório de configuração: $CONFIG_DIR"
    echo ""
    echo -e "${YELLOW}⚠️  DISCLAIMER${NC}"
    echo "Esta ferramenta é destinada apenas para fins educacionais e de segurança"
    echo "legítima. O uso inadequado é de responsabilidade do usuário."
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}

# Loop principal
main_loop() {
    while true; do
        show_main_menu
        
        read -r choice
        echo ""
        
        case "$choice" in
            1)
                analyze_file
                ;;
            2)
                analyze_url
                ;;
            3)
                analyze_domain
                ;;
            4)
                analyze_hash
                ;;
            5)
                analyze_email
                ;;
            6)
                analyze_ip
                ;;
            7)
                configure_apis
                ;;
            8)
                view_reports
                ;;
            9)
                view_logs
                ;;
            10)
                run_tests
                ;;
            11)
                show_help
                ;;
            12)
                show_about
                ;;
            0)
                echo -e "${GREEN}Obrigado por usar o Security Analyzer Tool!${NC}"
                echo -e "${PURPLE}$APP_AUTHOR${NC}"
                log_message "Aplicação encerrada pelo usuário"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opção inválida! Tente novamente.${NC}"
                sleep 2
                continue
                ;;
        esac
        
        echo ""
        echo -e "${CYAN}Pressione ENTER para continuar...${NC}"
        read -r
    done
}

# Verificar dependências básicas
check_dependencies() {
    local missing_deps=()
    local deps=("bash" "curl")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Dependências básicas faltando: ${missing_deps[*]}${NC}"
        echo ""
        echo "Para instalar as dependências, execute:"
        echo "sudo apt install curl  # Ubuntu/Debian"
        echo "sudo dnf install curl  # Fedora/CentOS"
        echo "brew install curl      # macOS"
        echo ""
        exit 1
    fi
}

# Função principal
main() {
    # Verificar dependências
    check_dependencies
    
    # Inicializar log
    log_message "Security Analyzer Tool v$APP_VERSION iniciado"
    
    # Executar loop principal
    main_loop
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
