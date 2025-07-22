#!/bin/bash

# ========================================
# Forensic Email Analyzer - Análise Forense Detalhada de Emails
# ========================================

source "$(dirname "$0")/config.sh" 2>/dev/null || true

# Função principal de análise forense
forensic_email_analysis() {
    local header_file="$1"
    
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    ANÁLISE FORENSE DETALHADA DO EMAIL                        ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # 1. Resumo Executivo
    generate_executive_summary "$header_file"
    
    # 2. Análise Técnica do Cabeçalho
    technical_header_analysis "$header_file"
    
    # 3. Análise de Autenticação
    authentication_analysis "$header_file"
    
    # 4. Análise de Caminho e Origem
    path_origin_analysis "$header_file"
    
    # 5. Análise de Conteúdo e Técnicas
    content_techniques_analysis "$header_file"
    
    # 6. Análise de Ameaças e IOCs
    threat_ioc_analysis "$header_file"
    
    # 7. Conclusão e Recomendações
    conclusion_recommendations "$header_file"
}

# Função para gerar resumo executivo
generate_executive_summary() {
    local header_file="$1"
    
    echo -e "${BLUE}1. RESUMO EXECUTIVO${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Extrair informações básicas
    local from_header subject_header date_header
    from_header=$(grep -i "^From:" "$header_file" | head -1 | cut -d' ' -f2-)
    subject_header=$(grep -i "^Subject:" "$header_file" | head -1 | cut -d' ' -f2-)
    date_header=$(grep -i "^Date:" "$header_file" | head -1 | cut -d' ' -f2-)
    
    echo -e "${YELLOW}📧 Informações Básicas:${NC}"
    echo "   Remetente: $from_header"
    echo "   Assunto: $subject_header"
    echo "   Data: $date_header"
    echo ""
    
    # Análise preliminar do tipo de ameaça
    local threat_type="Desconhecido"
    local threat_indicators=0
    
    if echo "$subject_header" | grep -qiE "(urgent|security|alert|suspend|verify|confirm|action.*required|account.*compromised)"; then
        threat_type="Possível Phishing/Engenharia Social"
        ((threat_indicators++))
    fi
    
    if echo "$subject_header" | grep -qiE "(payment|bitcoin|crypto|ransom|extortion|video|webcam|adult|porn)"; then
        threat_type="Possível Sextorsão/Extorsão"
        ((threat_indicators++))
    fi
    
    if echo "$from_header" | grep -qiE "(noreply|no-reply|admin|security|support|service)"; then
        ((threat_indicators++))
    fi
    
    echo -e "${YELLOW}🎯 Classificação Preliminar:${NC}"
    echo "   Tipo de Ameaça: $threat_type"
    echo "   Indicadores Iniciais: $threat_indicators"
    echo ""
}

# Função para análise técnica do cabeçalho
technical_header_analysis() {
    local header_file="$1"
    
    echo -e "${BLUE}2. ANÁLISE TÉCNICA DO CABEÇALHO${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Análise de Message-ID
    local message_id
    message_id=$(grep -i "^Message-ID:" "$header_file" | head -1 | cut -d' ' -f2-)
    
    echo -e "${YELLOW}📨 Message-ID Analysis:${NC}"
    if [[ -n "$message_id" ]]; then
        echo "   Message-ID: $message_id"
        
        # Verificar formato do Message-ID
        if echo "$message_id" | grep -qE "<[^@]+@[^>]+>"; then
            local msg_domain
            msg_domain=$(echo "$message_id" | sed 's/.*@\([^>]*\).*/\1/')
            echo "   Domínio do Message-ID: $msg_domain"
            
            # Comparar com domínio do From
            local from_domain
            from_domain=$(grep -i "^From:" "$header_file" | grep -oE "@[^>]*" | tr -d '@>' | head -1)
            
            if [[ "$msg_domain" != "$from_domain" ]]; then
                echo -e "   ${RED}⚠ SUSPEITO: Domínio do Message-ID difere do From${NC}"
            else
                echo -e "   ${GREEN}✓ Domínio do Message-ID consistente${NC}"
            fi
        else
            echo -e "   ${RED}⚠ SUSPEITO: Formato de Message-ID inválido${NC}"
        fi
    else
        echo -e "   ${RED}⚠ CRÍTICO: Message-ID ausente${NC}"
    fi
    echo ""
    
    # Análise de User-Agent/X-Mailer
    local user_agent x_mailer
    user_agent=$(grep -i "^User-Agent:" "$header_file" | head -1 | cut -d' ' -f2-)
    x_mailer=$(grep -i "^X-Mailer:" "$header_file" | head -1 | cut -d' ' -f2-)
    
    echo -e "${YELLOW}🛠 Cliente de Email:${NC}"
    if [[ -n "$x_mailer" ]]; then
        echo "   X-Mailer: $x_mailer"
        
        # Verificar se é suspeito
        if echo "$x_mailer" | grep -qiE "(mass|bulk|spam|bot|script|php|python)"; then
            echo -e "   ${RED}⚠ SUSPEITO: Cliente de email para envio em massa${NC}"
        elif echo "$x_mailer" | grep -qiE "(outlook|thunderbird|apple mail|gmail)"; then
            echo -e "   ${GREEN}✓ Cliente de email legítimo${NC}"
        fi
    elif [[ -n "$user_agent" ]]; then
        echo "   User-Agent: $user_agent"
    else
        echo -e "   ${YELLOW}⚠ Informação de cliente não disponível${NC}"
    fi
    echo ""
}

# Função para análise de autenticação
authentication_analysis() {
    local header_file="$1"
    
    echo -e "${BLUE}3. ANÁLISE DE AUTENTICAÇÃO (SPF, DKIM, DMARC)${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Análise SPF detalhada
    echo -e "${YELLOW}🛡 SPF (Sender Policy Framework):${NC}"
    if grep -qi "Received-SPF:" "$header_file"; then
        local spf_result spf_details
        spf_result=$(grep -i "Received-SPF:" "$header_file" | head -1 | awk '{print $2}')
        spf_details=$(grep -i "Received-SPF:" "$header_file" | head -1)
        
        echo "   Resultado: $spf_result"
        echo "   Detalhes: $spf_details"
        
        case "$spf_result" in
            "pass")
                echo -e "   ${GREEN}✓ LEGÍTIMO: Servidor autorizado a enviar pelo domínio${NC}"
                ;;
            "fail")
                echo -e "   ${RED}⚠ FALSIFICADO: Servidor NÃO autorizado pelo domínio${NC}"
                echo -e "   ${RED}   Indica que o email é fraudulento${NC}"
                ;;
            "softfail")
                echo -e "   ${YELLOW}⚠ SUSPEITO: Servidor provavelmente não autorizado${NC}"
                ;;
            "neutral"|"none")
                echo -e "   ${YELLOW}⚠ INDEFINIDO: Domínio não possui política SPF clara${NC}"
                ;;
        esac
    else
        echo -e "   ${YELLOW}⚠ SPF não verificado ou ausente${NC}"
    fi
    echo ""
    
    # Análise DKIM detalhada
    echo -e "${YELLOW}🔐 DKIM (DomainKeys Identified Mail):${NC}"
    if grep -qi "DKIM-Signature:" "$header_file"; then
        local dkim_domain dkim_selector
        dkim_domain=$(grep -i "DKIM-Signature:" "$header_file" | grep -o "d=[^;]*" | cut -d'=' -f2 | head -1)
        dkim_selector=$(grep -i "DKIM-Signature:" "$header_file" | grep -o "s=[^;]*" | cut -d'=' -f2 | head -1)
        
        echo -e "   ${GREEN}✓ PRESENTE: Email possui assinatura DKIM${NC}"
        echo "   Domínio: $dkim_domain"
        echo "   Seletor: $dkim_selector"
        
        # Verificar se DKIM passou na validação
        if grep -qi "dkim=pass" "$header_file"; then
            echo -e "   ${GREEN}✓ VÁLIDO: Assinatura DKIM verificada${NC}"
        elif grep -qi "dkim=fail" "$header_file"; then
            echo -e "   ${RED}⚠ INVÁLIDO: Assinatura DKIM falhou${NC}"
        else
            echo -e "   ${YELLOW}⚠ Status de validação não disponível${NC}"
        fi
    else
        echo -e "   ${RED}⚠ AUSENTE: Email não possui assinatura DKIM${NC}"
        echo -e "   ${RED}   Incomum para serviços legítimos (Gmail, Outlook, etc.)${NC}"
    fi
    echo ""
    
    # Análise DMARC detalhada
    echo -e "${YELLOW}🎯 DMARC (Domain-based Message Authentication):${NC}"
    if grep -qi "dmarc=" "$header_file"; then
        local dmarc_result
        dmarc_result=$(grep -i "dmarc=" "$header_file" | head -1)
        
        echo "   Resultado: $dmarc_result"
        
        if echo "$dmarc_result" | grep -qi "dmarc=pass"; then
            echo -e "   ${GREEN}✓ PASS: Email passou na política DMARC${NC}"
        elif echo "$dmarc_result" | grep -qi "dmarc=fail"; then
            echo -e "   ${RED}⚠ FAIL: Email falhou na política DMARC${NC}"
            echo -e "   ${RED}   Confirma que o email é fraudulento${NC}"
        fi
    else
        echo -e "   ${YELLOW}⚠ DMARC não verificado ou política ausente${NC}"
    fi
    echo ""
    
    # Resumo da autenticação
    local auth_score=0
    local auth_total=3
    
    if grep -qi "Received-SPF:.*pass" "$header_file"; then ((auth_score++)); fi
    if grep -qi "dkim=pass" "$header_file"; then ((auth_score++)); fi
    if grep -qi "dmarc=pass" "$header_file"; then ((auth_score++)); fi
    
    echo -e "${YELLOW}📊 Score de Autenticação: $auth_score/$auth_total${NC}"
    
    if [[ $auth_score -eq 3 ]]; then
        echo -e "   ${GREEN}✓ EXCELENTE: Todas as verificações passaram${NC}"
    elif [[ $auth_score -eq 2 ]]; then
        echo -e "   ${YELLOW}⚠ BOM: Maioria das verificações passou${NC}"
    elif [[ $auth_score -eq 1 ]]; then
        echo -e "   ${RED}⚠ RUIM: Poucas verificações passaram${NC}"
    else
        echo -e "   ${RED}⚠ CRÍTICO: Nenhuma verificação passou - EMAIL SUSPEITO${NC}"
    fi
    echo ""
}

# Exportar funções
export -f forensic_email_analysis
export -f generate_executive_summary
export -f technical_header_analysis
export -f authentication_analysis
