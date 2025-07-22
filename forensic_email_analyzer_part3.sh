#!/bin/bash

# ========================================
# Forensic Email Analyzer Part 3 - Conclusões e Recomendações
# ========================================

source "$(dirname "$0")/config.sh" 2>/dev/null || true

# Função para conclusão e recomendações
conclusion_recommendations() {
    local header_file="$1"
    
    echo -e "${BLUE}7. CONCLUSÃO E RECOMENDAÇÕES${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Calcular score de legitimidade
    local legitimacy_score=0
    local total_checks=10
    local threat_level="BAIXO"
    local is_legitimate=true
    
    # Verificações de legitimidade
    echo -e "${YELLOW}📊 Análise de Legitimidade:${NC}"
    
    # 1. SPF
    if grep -qi "Received-SPF:.*pass" "$header_file"; then
        echo -e "   ${GREEN}✓ SPF passou${NC}"
        ((legitimacy_score++))
    else
        echo -e "   ${RED}✗ SPF falhou ou ausente${NC}"
        is_legitimate=false
    fi
    
    # 2. DKIM
    if grep -qi "dkim=pass" "$header_file"; then
        echo -e "   ${GREEN}✓ DKIM passou${NC}"
        ((legitimacy_score++))
    else
        echo -e "   ${RED}✗ DKIM falhou ou ausente${NC}"
        is_legitimate=false
    fi
    
    # 3. DMARC
    if grep -qi "dmarc=pass" "$header_file"; then
        echo -e "   ${GREEN}✓ DMARC passou${NC}"
        ((legitimacy_score++))
    else
        echo -e "   ${RED}✗ DMARC falhou ou ausente${NC}"
        is_legitimate=false
    fi
    
    # 4. Message-ID válido
    local message_id
    message_id=$(grep -i "^Message-ID:" "$header_file" | head -1)
    if [[ -n "$message_id" ]] && echo "$message_id" | grep -qE "<[^@]+@[^>]+>"; then
        echo -e "   ${GREEN}✓ Message-ID válido${NC}"
        ((legitimacy_score++))
    else
        echo -e "   ${RED}✗ Message-ID inválido ou ausente${NC}"
    fi
    
    # 5. Cliente de email legítimo
    if grep -qiE "X-Mailer:.*(outlook|thunderbird|apple mail|gmail)" "$header_file"; then
        echo -e "   ${GREEN}✓ Cliente de email legítimo${NC}"
        ((legitimacy_score++))
    elif grep -qiE "X-Mailer:.*(mass|bulk|spam|bot|script)" "$header_file"; then
        echo -e "   ${RED}✗ Cliente suspeito para envio em massa${NC}"
    else
        echo -e "   ${YELLOW}⚠ Cliente de email não identificado${NC}"
        ((legitimacy_score++))  # Neutro
    fi
    
    # 6. Número de hops razoável
    local hop_count
    hop_count=$(grep -c "^Received:" "$header_file")
    if [[ $hop_count -ge 2 && $hop_count -le 8 ]]; then
        echo -e "   ${GREEN}✓ Número de hops normal ($hop_count)${NC}"
        ((legitimacy_score++))
    else
        echo -e "   ${YELLOW}⚠ Número de hops incomum ($hop_count)${NC}"
    fi
    
    # 7. Assunto não suspeito
    local subject
    subject=$(grep -i "^Subject:" "$header_file" | head -1 | cut -d' ' -f2-)
    if ! echo "$subject" | grep -qiE "(urgent|security|alert|suspend|verify|confirm|action.*required|account.*compromised|payment|bitcoin|crypto|ransom|extortion)"; then
        echo -e "   ${GREEN}✓ Assunto não contém palavras-chave suspeitas${NC}"
        ((legitimacy_score++))
    else
        echo -e "   ${RED}✗ Assunto contém palavras-chave de phishing/extorsão${NC}"
        is_legitimate=false
    fi
    
    # 8. Remetente não suspeito
    local from_addr
    from_addr=$(grep -i "^From:" "$header_file" | head -1)
    if ! echo "$from_addr" | grep -qiE "(noreply|no-reply|admin|security|support|service|alert|notification)@"; then
        echo -e "   ${GREEN}✓ Remetente não segue padrão típico de phishing${NC}"
        ((legitimacy_score++))
    else
        echo -e "   ${YELLOW}⚠ Remetente com padrão comum em phishing${NC}"
    fi
    
    # 9. IPs com boa reputação
    local malicious_ips=0
    local ips
    ips=$(grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$header_file" | sort -u)
    
    if [[ -n "$ips" ]]; then
        echo "$ips" | while read -r ip; do
            if [[ ! "$ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
                # Verificação básica de IPs maliciosos conhecidos
                if [[ "$ip" =~ ^184\.107\.85\. ]] || [[ "$ip" =~ ^185\.220\. ]]; then
                    ((malicious_ips++))
                fi
            fi
        done
    fi
    
    if [[ $malicious_ips -eq 0 ]]; then
        echo -e "   ${GREEN}✓ Nenhum IP malicioso conhecido detectado${NC}"
        ((legitimacy_score++))
    else
        echo -e "   ${RED}✗ IPs maliciosos detectados${NC}"
        is_legitimate=false
    fi
    
    # 10. Sem anexos suspeitos
    if ! grep -qi "Content-Disposition:.*attachment" "$header_file"; then
        echo -e "   ${GREEN}✓ Nenhum anexo detectado${NC}"
        ((legitimacy_score++))
    elif ! grep -qiE "filename=.*\.(exe|scr|bat|cmd|com|pif|vbs|js|jar)" "$header_file"; then
        echo -e "   ${YELLOW}⚠ Anexos presentes, mas não executáveis${NC}"
        ((legitimacy_score++))
    else
        echo -e "   ${RED}✗ Anexos executáveis detectados${NC}"
        is_legitimate=false
    fi
    
    echo ""
    echo -e "${YELLOW}📈 Score de Legitimidade: $legitimacy_score/$total_checks${NC}"
    
    # Determinar nível de ameaça
    if [[ $legitimacy_score -ge 8 ]]; then
        threat_level="BAIXO"
        echo -e "   ${GREEN}✓ Email provavelmente legítimo${NC}"
    elif [[ $legitimacy_score -ge 6 ]]; then
        threat_level="MÉDIO"
        echo -e "   ${YELLOW}⚠ Email suspeito - investigação recomendada${NC}"
    elif [[ $legitimacy_score -ge 4 ]]; then
        threat_level="ALTO"
        echo -e "   ${RED}⚠ Email altamente suspeito${NC}"
        is_legitimate=false
    else
        threat_level="CRÍTICO"
        echo -e "   ${RED}🚨 Email muito provavelmente fraudulento${NC}"
        is_legitimate=false
    fi
    echo ""
    
    # Conclusão final
    echo -e "${YELLOW}🎯 CONCLUSÃO FINAL:${NC}"
    
    if $is_legitimate && [[ $legitimacy_score -ge 7 ]]; then
        echo -e "   ${GREEN}✅ EMAIL LEGÍTIMO${NC}"
        echo "   O email passou na maioria das verificações de autenticidade."
        echo "   Probabilidade de ser fraudulento: BAIXA"
    else
        echo -e "   ${RED}❌ EMAIL FRAUDULENTO/SUSPEITO${NC}"
        echo "   O email falhou em verificações críticas de autenticidade."
        echo "   Probabilidade de ser fraudulento: ALTA"
        
        # Identificar tipo de ameaça
        local threat_type="Phishing Genérico"
        
        if echo "$subject" | grep -qiE "(payment|bitcoin|crypto|ransom|extortion|video|webcam|adult|porn)"; then
            threat_type="Sextorsão/Extorsão"
        elif echo "$subject" | grep -qiE "(urgent|security|alert|suspend|verify|confirm|account.*compromised)"; then
            threat_type="Phishing de Credenciais"
        elif grep -qi "Content-Disposition:.*attachment" "$header_file"; then
            threat_type="Malware via Anexo"
        fi
        
        echo "   Tipo de ameaça identificado: $threat_type"
    fi
    echo ""
    
    # Recomendações específicas
    echo -e "${YELLOW}💡 RECOMENDAÇÕES:${NC}"
    
    if $is_legitimate; then
        echo -e "   ${GREEN}Para emails legítimos:${NC}"
        echo "   • Proceder normalmente com o email"
        echo "   • Manter vigilância de rotina"
        echo "   • Verificar links antes de clicar (boa prática)"
    else
        echo -e "   ${RED}Para emails fraudulentos/suspeitos:${NC}"
        echo ""
        echo -e "   ${RED}🚫 NÃO FAÇA:${NC}"
        echo "   • NÃO clique em links no email"
        echo "   • NÃO baixe ou abra anexos"
        echo "   • NÃO forneça informações pessoais"
        echo "   • NÃO responda ao email"
        
        if echo "$subject" | grep -qiE "(payment|bitcoin|crypto|ransom|extortion)"; then
            echo "   • NÃO efetue pagamentos em criptomoedas"
        fi
        echo ""
        
        echo -e "   ${GREEN}✅ FAÇA:${NC}"
        echo "   • Delete o email imediatamente"
        echo "   • Marque como spam/phishing"
        echo "   • Relate para a equipe de TI/Segurança"
        echo "   • Verifique se outros usuários receberam emails similares"
        echo "   • Execute scan antivírus se clicou em algo"
        echo "   • Altere senhas se forneceu credenciais"
        echo "   • Monitore contas financeiras"
        
        if echo "$subject" | grep -qiE "(payment|bitcoin|crypto|ransom|extortion)"; then
            echo "   • Ignore completamente as ameaças (são falsas)"
            echo "   • Considere denunciar às autoridades se persistir"
        fi
    fi
    echo ""
    
    # Ações adicionais para administradores
    echo -e "${YELLOW}🔧 AÇÕES PARA ADMINISTRADORES:${NC}"
    
    if ! $is_legitimate; then
        echo "   • Bloquear remetente nos filtros de email"
        echo "   • Adicionar IPs maliciosos à blacklist"
        echo "   • Atualizar regras de detecção de spam"
        echo "   • Treinar usuários sobre este tipo de ameaça"
        echo "   • Monitorar logs para emails similares"
        
        # Extrair IOCs para bloqueio
        local sender_domain
        sender_domain=$(grep -i "^From:" "$header_file" | grep -oE "@[^>]*" | tr -d '@>' | head -1)
        
        if [[ -n "$sender_domain" ]]; then
            echo "   • Considerar bloqueio do domínio: $sender_domain"
        fi
        
        local malicious_ips_list
        malicious_ips_list=$(grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$header_file" | grep -E "^184\.107\.85\.|^185\.220\." | sort -u)
        
        if [[ -n "$malicious_ips_list" ]]; then
            echo "   • Bloquear IPs maliciosos detectados:"
            echo "$malicious_ips_list" | while read -r ip; do
                echo "     - $ip"
            done
        fi
    fi
    echo ""
    
    # Salvar relatório forense
    local forensic_report="$REPORTS_DIR/forensic_analysis_$(date '+%Y%m%d_%H%M%S').json"
    
    cat > "$forensic_report" << EOF
{
    "analysis_timestamp": "$(date -Iseconds)",
    "file_analyzed": "$header_file",
    "legitimacy_score": $legitimacy_score,
    "total_checks": $total_checks,
    "threat_level": "$threat_level",
    "is_legitimate": $is_legitimate,
    "conclusion": "$(if $is_legitimate; then echo "EMAIL LEGÍTIMO"; else echo "EMAIL FRAUDULENTO/SUSPEITO"; fi)",
    "threat_type": "$threat_type",
    "recommendations": "$(if $is_legitimate; then echo "Proceder normalmente"; else echo "Deletar e reportar"; fi)"
}
EOF
    
    echo -e "${BLUE}📄 Relatório forense salvo em: $forensic_report${NC}"
    echo ""
}

# Função para análise completa integrada
complete_forensic_analysis() {
    local header_file="$1"
    
    # Carregar todas as partes do analisador
    if [[ -f "$(dirname "$0")/forensic_email_analyzer.sh" ]]; then
        source "$(dirname "$0")/forensic_email_analyzer.sh"
    fi
    
    if [[ -f "$(dirname "$0")/forensic_email_analyzer_part2.sh" ]]; then
        source "$(dirname "$0")/forensic_email_analyzer_part2.sh"
    fi
    
    # Executar análise completa
    forensic_email_analysis "$header_file"
}

# Exportar funções
export -f conclusion_recommendations
export -f complete_forensic_analysis
