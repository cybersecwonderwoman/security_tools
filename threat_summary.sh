#!/bin/bash

# ========================================
# Threat Summary Generator - Gerador de Resumo de Ameaças
# ========================================

source "$(dirname "$0")/config.sh" 2>/dev/null || true

# Função para gerar resumo de ameaças
generate_threat_summary() {
    local analysis_type="$1"
    local target="$2"
    local threats_found="$3"
    local details="$4"
    
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    RESUMO DE AMEAÇAS                         ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Determinar nível de risco
    local risk_level
    local risk_color
    
    if [[ $threats_found -eq 0 ]]; then
        risk_level="BAIXO"
        risk_color="$GREEN"
    elif [[ $threats_found -le 2 ]]; then
        risk_level="MÉDIO"
        risk_color="$YELLOW"
    elif [[ $threats_found -le 4 ]]; then
        risk_level="ALTO"
        risk_color="$RED"
    else
        risk_level="CRÍTICO"
        risk_color="$RED"
    fi
    
    echo -e "${BLUE}Tipo de Análise:${NC} $analysis_type"
    echo -e "${BLUE}Alvo:${NC} $target"
    echo -e "${BLUE}Indicadores de Ameaça:${NC} $threats_found"
    echo -e "${BLUE}Nível de Risco:${NC} ${risk_color}$risk_level${NC}"
    echo ""
    
    # Recomendações baseadas no nível de risco
    echo -e "${BLUE}Recomendações:${NC}"
    local recommendations=""
    case "$risk_level" in
        "BAIXO")
            echo -e "  ${GREEN}✓ Alvo aparenta ser seguro${NC}"
            echo -e "  ${GREEN}✓ Nenhuma ação imediata necessária${NC}"
            echo -e "  ${GREEN}✓ Monitoramento de rotina recomendado${NC}"
            recommendations="- ✅ Alvo aparenta ser seguro\n- ✅ Nenhuma ação imediata necessária\n- ✅ Monitoramento de rotina recomendado"
            ;;
        "MÉDIO")
            echo -e "  ${YELLOW}⚠ Investigação adicional recomendada${NC}"
            echo -e "  ${YELLOW}⚠ Monitoramento aumentado${NC}"
            echo -e "  ${YELLOW}⚠ Verificar contexto da ameaça${NC}"
            recommendations="- ⚠️ Investigação adicional recomendada\n- ⚠️ Monitoramento aumentado\n- ⚠️ Verificar contexto da ameaça"
            ;;
        "ALTO")
            echo -e "  ${RED}⚠ ATENÇÃO: Múltiplos indicadores de ameaça${NC}"
            echo -e "  ${RED}⚠ Bloqueio preventivo recomendado${NC}"
            echo -e "  ${RED}⚠ Análise forense detalhada necessária${NC}"
            recommendations="- 🔴 ATENÇÃO: Múltiplos indicadores de ameaça\n- 🔴 Bloqueio preventivo recomendado\n- 🔴 Análise forense detalhada necessária"
            ;;
        "CRÍTICO")
            echo -e "  ${RED}🚨 ALERTA CRÍTICO: Ameaça confirmada${NC}"
            echo -e "  ${RED}🚨 Bloqueio imediato necessário${NC}"
            echo -e "  ${RED}🚨 Notificar equipe de segurança${NC}"
            echo -e "  ${RED}🚨 Iniciar procedimentos de resposta a incidentes${NC}"
            recommendations="- 🚨 ALERTA CRÍTICO: Ameaça confirmada\n- 🚨 Bloqueio imediato necessário\n- 🚨 Notificar equipe de segurança\n- 🚨 Iniciar procedimentos de resposta a incidentes"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Timestamp:${NC} $(date '+%Y-%m-%d %H:%M:%S %Z')"
    
    # Gerar markdown formatado
    local markdown_content=$(cat << EOF
# Relatório de Análise de Segurança

## Resumo de Ameaças

**Tipo de Análise:** $analysis_type  
**Alvo:** $target  
**Indicadores de Ameaça:** $threats_found  
**Nível de Risco:** **$risk_level**  

## Recomendações

$recommendations

## Detalhes da Análise

$details

---

*Relatório gerado em: $(date '+%Y-%m-%d %H:%M:%S %Z')*
EOF
)

    # Abrir o relatório diretamente no navegador
    if [[ -f "$(dirname "$0")/serve_report.sh" ]]; then
        echo -e "${GREEN}Abrindo relatório no navegador...${NC}"
        "$(dirname "$0")/serve_report.sh" "$markdown_content"
    else
        echo -e "${RED}Erro: Script serve_report.sh não encontrado${NC}"
        # Salvar markdown em arquivo como fallback
        local markdown_file="$REPORTS_DIR/threat_summary_$(date '+%Y%m%d_%H%M%S').md"
        echo -e "$markdown_content" > "$markdown_file"
        echo -e "${BLUE}Relatório markdown salvo em:${NC} $markdown_file"
    fi
    
    return $threats_found
}

# Função para análise de IOCs (Indicators of Compromise)
analyze_iocs() {
    local target="$1"
    local iocs=()
    
    echo -e "${BLUE}[Análise de IOCs] Extraindo indicadores de compromisso${NC}"
    
    # Extrair IPs
    local ips
    ips=$(echo "$target" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u)
    if [[ -n "$ips" ]]; then
        while read -r ip; do
            iocs+=("IP:$ip")
        done <<< "$ips"
    fi
    
    # Extrair domínios
    local domains
    domains=$(echo "$target" | grep -oE '\b[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b' | sort -u)
    if [[ -n "$domains" ]]; then
        while read -r domain; do
            iocs+=("DOMAIN:$domain")
        done <<< "$domains"
    fi
    
    # Extrair emails
    local emails
    emails=$(echo "$target" | grep -oE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' | sort -u)
    if [[ -n "$emails" ]]; then
        while read -r email; do
            iocs+=("EMAIL:$email")
        done <<< "$emails"
    fi
    
    # Extrair hashes (MD5, SHA1, SHA256)
    local hashes
    hashes=$(echo "$target" | grep -oE '\b[a-fA-F0-9]{32,64}\b' | sort -u)
    if [[ -n "$hashes" ]]; then
        while read -r hash; do
            case ${#hash} in
                32) iocs+=("MD5:$hash") ;;
                40) iocs+=("SHA1:$hash") ;;
                64) iocs+=("SHA256:$hash") ;;
            esac
        done <<< "$hashes"
    fi
    
    if [[ ${#iocs[@]} -gt 0 ]]; then
        echo "  IOCs extraídos: ${#iocs[@]}"
        for ioc in "${iocs[@]}"; do
            echo "    $ioc"
        done
    else
        echo "  Nenhum IOC identificado"
    fi
    
    # Salvar IOCs em arquivo
    local ioc_file="$REPORTS_DIR/iocs_$(date '+%Y%m%d_%H%M%S').txt"
    printf '%s\n' "${iocs[@]}" > "$ioc_file"
    echo "  IOCs salvos em: $ioc_file"
}

# Função para verificar IOCs em bases de threat intelligence
check_iocs_threat_intel() {
    local ioc_file="$1"
    local threats=0
    
    if [[ ! -f "$ioc_file" ]]; then
        return 0
    fi
    
    echo -e "${BLUE}[Threat Intelligence] Verificando IOCs em bases de dados${NC}"
    
    while read -r ioc; do
        local ioc_type="${ioc%%:*}"
        local ioc_value="${ioc#*:}"
        
        case "$ioc_type" in
            "IP")
                if [[ -f "$(dirname "$0")/ip_reputation_checker.sh" ]]; then
                    source "$(dirname "$0")/ip_reputation_checker.sh"
                    if declare -f check_ip_reputation > /dev/null 2>&1; then
                        if ! check_ip_reputation "$ioc_value" > /dev/null 2>&1; then
                            echo -e "    ${RED}⚠ IP malicioso: $ioc_value${NC}"
                            ((threats++))
                        fi
                    fi
                fi
                ;;
            "DOMAIN")
                # Verificação básica de domínios suspeitos
                if echo "$ioc_value" | grep -qiE "(bit\.ly|tinyurl|t\.co|goo\.gl|ow\.ly|short|tiny|temp|fake|phish|scam|malware|virus)"; then
                    echo -e "    ${YELLOW}⚠ Domínio suspeito: $ioc_value${NC}"
                    ((threats++))
                fi
                ;;
            "EMAIL")
                # Verificação de emails suspeitos
                if echo "$ioc_value" | grep -qiE "(noreply|no-reply|admin|security|alert|urgent|verify|confirm|update|suspend)@"; then
                    echo -e "    ${YELLOW}⚠ Email suspeito: $ioc_value${NC}"
                    ((threats++))
                fi
                ;;
        esac
    done < "$ioc_file"
    
    return $threats
}

# Exportar funções
export -f generate_threat_summary
export -f analyze_iocs
export -f check_iocs_threat_intel
