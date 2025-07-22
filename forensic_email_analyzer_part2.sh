#!/bin/bash

# ========================================
# Forensic Email Analyzer Part 2 - Análise de Caminho e Conteúdo
# ========================================

source "$(dirname "$0")/config.sh" 2>/dev/null || true

# Função para análise de caminho e origem
path_origin_analysis() {
    local header_file="$1"
    
    echo -e "${BLUE}4. ANÁLISE DE CAMINHO E ORIGEM${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Análise dos cabeçalhos Received
    echo -e "${YELLOW}📍 Caminho do Email (Received Headers):${NC}"
    local received_count
    received_count=$(grep -c "^Received:" "$header_file")
    
    echo "   Total de hops: $received_count"
    
    if [[ $received_count -gt 10 ]]; then
        echo -e "   ${RED}⚠ SUSPEITO: Muitos hops ($received_count) - possível bounce/relay${NC}"
    elif [[ $received_count -lt 2 ]]; then
        echo -e "   ${YELLOW}⚠ INCOMUM: Poucos hops ($received_count) - possível envio direto${NC}"
    else
        echo -e "   ${GREEN}✓ Normal: Número adequado de hops${NC}"
    fi
    echo ""
    
    # Analisar cada hop em detalhes
    echo -e "${YELLOW}🔍 Análise Detalhada dos Hops:${NC}"
    local hop_num=1
    
    grep "^Received:" "$header_file" | while read -r received_line; do
        echo "   [$hop_num] $(echo "$received_line" | cut -c1-80)..."
        
        # Extrair IP do hop
        local hop_ip
        hop_ip=$(echo "$received_line" | grep -oE '\[([0-9]{1,3}\.){3}[0-9]{1,3}\]' | tr -d '[]' | head -1)
        
        if [[ -n "$hop_ip" ]]; then
            echo "       IP: $hop_ip"
            
            # Verificar se é IP privado
            if [[ "$hop_ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
                echo -e "       ${YELLOW}⚠ IP privado/interno${NC}"
            else
                echo -e "       ${GREEN}✓ IP público${NC}"
                
                # Verificar reputação do IP se disponível
                if [[ -f "$(dirname "$0")/ip_reputation_checker.sh" ]]; then
                    source "$(dirname "$0")/ip_reputation_checker.sh"
                    if declare -f check_ip_reputation > /dev/null 2>&1; then
                        echo "       Verificando reputação..."
                        if ! check_ip_reputation "$hop_ip" > /dev/null 2>&1; then
                            echo -e "       ${RED}⚠ IP MALICIOSO DETECTADO!${NC}"
                        else
                            echo -e "       ${GREEN}✓ IP com boa reputação${NC}"
                        fi
                    fi
                fi
            fi
        fi
        
        ((hop_num++))
        echo ""
    done
    
    # Análise de X-Originating-IP
    local orig_ip
    orig_ip=$(grep -i "^X-Originating-IP:" "$header_file" | head -1 | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
    
    if [[ -n "$orig_ip" ]]; then
        echo -e "${YELLOW}🎯 IP de Origem (X-Originating-IP):${NC}"
        echo "   IP: $orig_ip"
        
        # Verificar geolocalização
        local geo_info
        geo_info=$(curl -s "http://ip-api.com/json/$orig_ip?fields=status,country,regionName,city,isp,org,as,mobile,proxy,hosting" 2>/dev/null)
        
        if echo "$geo_info" | jq -e '.status == "success"' > /dev/null 2>&1; then
            local country city isp hosting proxy
            country=$(echo "$geo_info" | jq -r '.country // "N/A"')
            city=$(echo "$geo_info" | jq -r '.city // "N/A"')
            isp=$(echo "$geo_info" | jq -r '.isp // "N/A"')
            hosting=$(echo "$geo_info" | jq -r '.hosting // false')
            proxy=$(echo "$geo_info" | jq -r '.proxy // false')
            
            echo "   Localização: $city, $country"
            echo "   ISP: $isp"
            
            if [[ "$hosting" == "true" ]]; then
                echo -e "   ${YELLOW}⚠ IP de datacenter/hosting${NC}"
            fi
            
            if [[ "$proxy" == "true" ]]; then
                echo -e "   ${RED}⚠ IP identificado como proxy/VPN${NC}"
            fi
        fi
        echo ""
    fi
}

# Função para análise de conteúdo e técnicas
content_techniques_analysis() {
    local header_file="$1"
    
    echo -e "${BLUE}5. ANÁLISE DE CONTEÚDO E TÉCNICAS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Análise de Content-Type
    echo -e "${YELLOW}📄 Tipo de Conteúdo:${NC}"
    local content_type
    content_type=$(grep -i "^Content-Type:" "$header_file" | head -1 | cut -d' ' -f2-)
    
    if [[ -n "$content_type" ]]; then
        echo "   Content-Type: $content_type"
        
        if echo "$content_type" | grep -qi "text/html"; then
            echo -e "   ${YELLOW}⚠ Email em HTML - possível uso de técnicas de ocultação${NC}"
        elif echo "$content_type" | grep -qi "text/plain"; then
            echo -e "   ${GREEN}✓ Email em texto simples${NC}"
        elif echo "$content_type" | grep -qi "multipart"; then
            echo -e "   ${YELLOW}⚠ Email multipart - pode conter anexos${NC}"
        fi
    else
        echo -e "   ${YELLOW}⚠ Content-Type não especificado${NC}"
    fi
    echo ""
    
    # Análise de codificação
    echo -e "${YELLOW}🔤 Codificação:${NC}"
    local encoding
    encoding=$(grep -i "Content-Transfer-Encoding:" "$header_file" | head -1 | cut -d' ' -f2-)
    
    if [[ -n "$encoding" ]]; then
        echo "   Codificação: $encoding"
        
        if echo "$encoding" | grep -qi "base64"; then
            echo -e "   ${YELLOW}⚠ Codificação Base64 - conteúdo pode estar ofuscado${NC}"
        elif echo "$encoding" | grep -qi "quoted-printable"; then
            echo -e "   ${GREEN}✓ Codificação padrão${NC}"
        fi
    fi
    echo ""
    
    # Análise de anexos (se houver indicações)
    echo -e "${YELLOW}📎 Análise de Anexos:${NC}"
    if grep -qi "Content-Disposition:.*attachment" "$header_file"; then
        echo -e "   ${RED}⚠ ATENÇÃO: Email contém anexos${NC}"
        
        # Extrair nomes de arquivos
        local attachments
        attachments=$(grep -i "filename=" "$header_file" | sed 's/.*filename="\([^"]*\)".*/\1/')
        
        if [[ -n "$attachments" ]]; then
            echo "   Anexos detectados:"
            echo "$attachments" | while read -r filename; do
                echo "     - $filename"
                
                # Verificar extensões suspeitas
                if echo "$filename" | grep -qiE "\.(exe|scr|bat|cmd|com|pif|vbs|js|jar|zip|rar)$"; then
                    echo -e "       ${RED}⚠ PERIGOSO: Extensão executável${NC}"
                fi
            done
        fi
    else
        echo -e "   ${GREEN}✓ Nenhum anexo detectado${NC}"
    fi
    echo ""
    
    # Análise de URLs (se presentes no cabeçalho)
    echo -e "${YELLOW}🔗 URLs no Cabeçalho:${NC}"
    local urls
    urls=$(grep -oE 'https?://[^[:space:]]+' "$header_file" | sort -u)
    
    if [[ -n "$urls" ]]; then
        echo "   URLs encontradas:"
        echo "$urls" | while read -r url; do
            echo "     - $url"
            
            # Verificar se é URL suspeita
            if echo "$url" | grep -qiE "(bit\.ly|tinyurl|t\.co|goo\.gl|short|tiny)"; then
                echo -e "       ${YELLOW}⚠ URL encurtada - pode ocultar destino real${NC}"
            fi
            
            if echo "$url" | grep -qiE "(temp|fake|phish|scam|malware|virus)"; then
                echo -e "       ${RED}⚠ Domínio suspeito detectado${NC}"
            fi
        done
    else
        echo -e "   ${GREEN}✓ Nenhuma URL encontrada no cabeçalho${NC}"
    fi
    echo ""
}

# Função para análise de ameaças e IOCs
threat_ioc_analysis() {
    local header_file="$1"
    
    echo -e "${BLUE}6. ANÁLISE DE AMEAÇAS E INDICADORES DE COMPROMISSO (IOCs)${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Extrair IOCs do cabeçalho
    echo -e "${YELLOW}🎯 IOCs Extraídos:${NC}"
    
    # IPs
    local ips
    ips=$(grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$header_file" | sort -u)
    
    if [[ -n "$ips" ]]; then
        echo "   IPs encontrados:"
        echo "$ips" | while read -r ip; do
            if [[ ! "$ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
                echo "     - $ip (público)"
            else
                echo "     - $ip (privado)"
            fi
        done
    fi
    echo ""
    
    # Domínios
    local domains
    domains=$(grep -oE '\b[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b' "$header_file" | grep -v -E '^[0-9.]+$' | sort -u)
    
    if [[ -n "$domains" ]]; then
        echo "   Domínios encontrados:"
        echo "$domains" | while read -r domain; do
            echo "     - $domain"
            
            # Verificar domínios suspeitos
            if echo "$domain" | grep -qiE "(temp|fake|phish|scam|malware|virus|bit\.ly|tinyurl)"; then
                echo -e "       ${RED}⚠ Domínio suspeito${NC}"
            fi
        done
    fi
    echo ""
    
    # Análise de padrões de phishing/spam
    echo -e "${YELLOW}🚨 Padrões de Ameaça Detectados:${NC}"
    local threat_patterns=0
    
    # Verificar assunto suspeito
    local subject
    subject=$(grep -i "^Subject:" "$header_file" | head -1 | cut -d' ' -f2-)
    
    if echo "$subject" | grep -qiE "(urgent|security|alert|suspend|verify|confirm|action.*required|account.*compromised|payment|bitcoin|crypto|ransom|extortion|video|webcam|adult|porn)"; then
        echo -e "   ${RED}⚠ Assunto com palavras-chave de phishing/extorsão${NC}"
        ((threat_patterns++))
    fi
    
    # Verificar remetente suspeito
    local from_addr
    from_addr=$(grep -i "^From:" "$header_file" | head -1)
    
    if echo "$from_addr" | grep -qiE "(noreply|no-reply|admin|security|support|service|alert|notification)"; then
        echo -e "   ${YELLOW}⚠ Remetente com padrão típico de phishing${NC}"
        ((threat_patterns++))
    fi
    
    # Verificar falhas de autenticação
    if grep -qi "spf.*fail\|dkim.*fail\|dmarc.*fail" "$header_file"; then
        echo -e "   ${RED}⚠ Falhas de autenticação detectadas${NC}"
        ((threat_patterns++))
    fi
    
    # Verificar X-Mailer suspeito
    if grep -qiE "X-Mailer:.*(mass|bulk|spam|bot|script|php|python)" "$header_file"; then
        echo -e "   ${RED}⚠ Cliente de email para envio em massa${NC}"
        ((threat_patterns++))
    fi
    
    if [[ $threat_patterns -eq 0 ]]; then
        echo -e "   ${GREEN}✓ Nenhum padrão óbvio de ameaça detectado${NC}"
    else
        echo -e "   ${RED}⚠ Total de padrões suspeitos: $threat_patterns${NC}"
    fi
    echo ""
}

# Exportar funções
export -f path_origin_analysis
export -f content_techniques_analysis
export -f threat_ioc_analysis
