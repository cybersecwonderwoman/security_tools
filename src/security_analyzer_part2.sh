# ========================================
# Security Analyzer Tool v3.0 - Parte 2
# Funções de análise e interface
# ========================================

# Função principal de análise de arquivo
analyze_file_interactive() {
    echo -e "${CYAN}📁 ANÁLISE AVANÇADA DE ARQUIVO${NC}"
    echo "================================"
    echo ""
    
    echo "Digite o caminho do arquivo para análise:"
    echo -n "➤ "
    read -r file_path
    
    # Sanitizar entrada
    file_path=$(sanitize_input "$file_path")
    
    if [[ -z "$file_path" ]]; then
        echo -e "${RED}❌ Caminho não fornecido${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}🔍 Iniciando análise...${NC}"
    echo ""
    
    # Executar análise
    local analysis_result
    if analysis_result=$(analyze_file "$file_path"); then
        echo "$analysis_result"
        
        # Oferecer geração de relatório
        echo ""
        echo -e "${CYAN}📄 Deseja gerar relatório HTML? (s/n)${NC}"
        read -r generate_report
        
        if [[ "$generate_report" =~ ^[Ss]$ ]]; then
            local risk_level=$(calculate_risk_level "$file_path")
            local report_file=$(generate_html_report "Arquivo" "$file_path" "$analysis_result" "$risk_level")
            
            if [[ -n "$report_file" ]]; then
                echo -e "${GREEN}✅ Relatório gerado: $(basename "$report_file")${NC}"
                
                echo -e "${CYAN}🌐 Deseja abrir no navegador? (s/n)${NC}"
                read -r open_browser
                
                if [[ "$open_browser" =~ ^[Ss]$ ]]; then
                    open_report_controlled "$report_file"
                fi
            fi
        fi
    else
        echo -e "${RED}❌ Erro na análise do arquivo${NC}"
        log_error "Falha na análise do arquivo: $file_path" "MAIN"
    fi
}

# Função principal de análise de URL
analyze_url_interactive() {
    echo -e "${CYAN}🌐 ANÁLISE AVANÇADA DE URL${NC}"
    echo "==========================="
    echo ""
    
    echo "Digite a URL para análise:"
    echo -n "➤ "
    read -r url
    
    # Sanitizar entrada
    url=$(sanitize_input "$url")
    
    if [[ -z "$url" ]]; then
        echo -e "${RED}❌ URL não fornecida${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}🔍 Iniciando análise...${NC}"
    echo ""
    
    # Executar análise
    local analysis_result
    if analysis_result=$(analyze_url "$url"); then
        echo "$analysis_result"
        
        # Oferecer geração de relatório
        echo ""
        echo -e "${CYAN}📄 Deseja gerar relatório HTML? (s/n)${NC}"
        read -r generate_report
        
        if [[ "$generate_report" =~ ^[Ss]$ ]]; then
            local risk_level=$(calculate_url_risk "$url")
            local report_file=$(generate_html_report "URL" "$url" "$analysis_result" "$risk_level")
            
            if [[ -n "$report_file" ]]; then
                echo -e "${GREEN}✅ Relatório gerado: $(basename "$report_file")${NC}"
                
                echo -e "${CYAN}🌐 Deseja abrir no navegador? (s/n)${NC}"
                read -r open_browser
                
                if [[ "$open_browser" =~ ^[Ss]$ ]]; then
                    open_report_controlled "$report_file"
                fi
            fi
        fi
    else
        echo -e "${RED}❌ Erro na análise da URL${NC}"
        log_error "Falha na análise da URL: $url" "MAIN"
    fi
}

# Análise de domínio
analyze_domain_interactive() {
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
    
    # Análise básica de domínio
    echo -e "${BLUE}[🔍 Resolução DNS]${NC}"
    if command -v dig &>/dev/null; then
        local ip_address=$(dig +short "$domain" 2>/dev/null | head -1)
        if [[ -n "$ip_address" ]]; then
            echo "IP: $ip_address"
            
            # Verificar geolocalização
            if command -v geoiplookup &>/dev/null; then
                local geo_info=$(geoiplookup "$ip_address" 2>/dev/null)
                [[ -n "$geo_info" ]] && echo "Localização: $geo_info"
            fi
        else
            echo -e "${RED}❌ Falha na resolução DNS${NC}"
        fi
    fi
    
    echo ""
    echo -e "${BLUE}[📋 Informações WHOIS]${NC}"
    if command -v whois &>/dev/null; then
        local whois_info=$(timeout 10 whois "$domain" 2>/dev/null | head -20)
        if [[ -n "$whois_info" ]]; then
            echo "$whois_info"
        else
            echo "Informações WHOIS não disponíveis"
        fi
    fi
    
    log_analysis "DOMAIN" "$domain" "BAIXO" "5"
}

# Análise de hash
analyze_hash_interactive() {
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
    if validate_input "$hash" "hash_md5"; then
        hash_type="MD5"
    elif validate_input "$hash" "hash_sha1"; then
        hash_type="SHA1"
    elif validate_input "$hash" "hash_sha256"; then
        hash_type="SHA256"
    else
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
    
    # Verificar em APIs se disponível
    if is_api_configured "virustotal"; then
        echo ""
        echo -e "${BLUE}[🌐 VirusTotal]${NC}"
        local vt_result=$(check_virustotal_file "$hash")
        echo "$vt_result"
    fi
    
    log_analysis "HASH" "$hash" "BAIXO" "3"
}

# Análise de email
analyze_email_interactive() {
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
    
    # Extrair domínio do email
    local domain=$(echo "$email" | cut -d'@' -f2)
    
    echo -e "${BLUE}[📧 Informações do Email]${NC}"
    echo "Email: $email"
    echo "Domínio: $domain"
    
    # Verificar domínio
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
    
    log_analysis "EMAIL" "$email" "BAIXO" "2"
}

# Análise de IP
analyze_ip_interactive() {
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
        
        # Geolocalização
        if command -v geoiplookup &>/dev/null; then
            local geo_info=$(geoiplookup "$ip_address" 2>/dev/null)
            [[ -n "$geo_info" ]] && echo "Localização: $geo_info"
        fi
    fi
    
    # Reverse DNS
    if command -v dig &>/dev/null; then
        local reverse_dns=$(dig +short -x "$ip_address" 2>/dev/null)
        [[ -n "$reverse_dns" ]] && echo "Reverse DNS: $reverse_dns"
    fi
    
    log_analysis "IP" "$ip_address" "BAIXO" "3"
}
