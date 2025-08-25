#!/bin/bash

# Script para corrigir manualmente a função analyze_url

echo "🔧 Corrigindo função analyze_url manualmente..."

# Backup
cp security_tool.sh security_tool.sh.backup.manual.$(date +%Y%m%d_%H%M%S)

# Criar arquivo temporário com a nova função
cat > new_analyze_url.txt << 'EOF'
# Função para análise de URL (versão corrigida)
analyze_url() {
    echo -e "${CYAN}🌐 ANÁLISE DE URL${NC}"
    echo "Digite a URL para análise:"
    echo -n "➤ "
    read -r url
    
    if [[ -z "$url" ]]; then
        echo -e "${RED}Erro: URL não pode estar vazia${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Iniciando análise da URL: $url${NC}"
    echo ""
    
    # Iniciar análise detalhada
    local analysis_result=""
    analysis_result+="🌐 ANÁLISE DE URL\n\n"
    analysis_result+="[Informações Básicas]\n"
    analysis_result+="URL: $url\n"
    analysis_result+="Data da análise: $(date '+%d/%m/%Y %H:%M:%S')\n\n"
    
    # Validação básica da URL
    echo -e "${BLUE}[Validação da URL]${NC}"
    analysis_result+="[Validação da URL]\n"
    
    if [[ "$url" =~ ^https?:// ]]; then
        echo "✅ Protocolo válido detectado"
        analysis_result+="✅ Protocolo válido detectado\n"
        
        # Extrair domínio da URL
        local domain=$(echo "$url" | sed -E 's|^https?://([^/]+).*|\1|')
        echo "Domínio extraído: $domain"
        analysis_result+="Domínio extraído: $domain\n"
    else
        echo "⚠️  Protocolo não especificado ou inválido"
        analysis_result+="⚠️  Protocolo não especificado ou inválido\n"
    fi
    echo ""
    analysis_result+="\n"
    
    # Análise de reputação básica
    echo -e "${BLUE}[Análise de Reputação]${NC}"
    analysis_result+="[Análise de Reputação]\n"
    
    local is_suspicious=false
    local suspicious_patterns=("malicious" "phishing" "spam" "scam" "fake" "fraud" "hack" "virus" "trojan")
    
    for pattern in "${suspicious_patterns[@]}"; do
        if [[ "$url" == *"$pattern"* ]]; then
            is_suspicious=true
            break
        fi
    done
    
    if [[ "$is_suspicious" == true ]]; then
        echo -e "${RED}❌ URL SUSPEITA DETECTADA!${NC}"
        echo "  Categoria: Potencialmente maliciosa"
        echo "  Risco: Alto"
        echo "  Recomendação: Evitar acesso"
        
        analysis_result+="❌ URL SUSPEITA DETECTADA!\n"
        analysis_result+="Categoria: Potencialmente maliciosa\n"
        analysis_result+="Risco: Alto\n"
        analysis_result+="Recomendação: Evitar acesso\n"
    else
        echo -e "${GREEN}✅ Nenhuma ameaça óbvia detectada${NC}"
        echo "  Reputação: Aparentemente limpa"
        echo "  Risco: Baixo"
        
        analysis_result+="✅ Nenhuma ameaça óbvia detectada\n"
        analysis_result+="Reputação: Aparentemente limpa\n"
        analysis_result+="Risco: Baixo\n"
    fi
    echo ""
    analysis_result+="\n"
    
    # Verificação de conectividade
    echo -e "${BLUE}[Teste de Conectividade]${NC}"
    analysis_result+="[Teste de Conectividade]\n"
    
    if command -v curl &> /dev/null; then
        local http_status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$url" 2>/dev/null)
        
        if [[ -n "$http_status" && "$http_status" != "000" ]]; then
            echo "Status HTTP: $http_status"
            analysis_result+="Status HTTP: $http_status\n"
            
            case "$http_status" in
                200)
                    echo "✅ Site acessível"
                    analysis_result+="✅ Site acessível\n"
                    ;;
                404)
                    echo "⚠️  Página não encontrada"
                    analysis_result+="⚠️  Página não encontrada\n"
                    ;;
                403)
                    echo "⚠️  Acesso negado"
                    analysis_result+="⚠️  Acesso negado\n"
                    ;;
                *)
                    echo "⚠️  Status HTTP incomum: $http_status"
                    analysis_result+="⚠️  Status HTTP incomum: $http_status\n"
                    ;;
            esac
        else
            echo "❌ Não foi possível conectar à URL"
            analysis_result+="❌ Não foi possível conectar à URL\n"
        fi
    else
        echo "⚠️  Ferramenta curl não disponível"
        analysis_result+="⚠️  Ferramenta curl não disponível\n"
    fi
    echo ""
    analysis_result+="\n"
    
    analysis_result+="Análise concluída em $(date '+%Y-%m-%d %H:%M:%S')\n"
    
    # Gerar relatório HTML se as funções estiverem disponíveis
    if declare -f generate_html_report >/dev/null 2>&1; then
        echo ""
        echo -e "${CYAN}📄 Gerando relatório HTML...${NC}"
        
        local report_file=$(generate_html_report "URL" "$url" "$analysis_result")
        
        if [[ -f "$report_file" ]]; then
            echo -e "${GREEN}✅ Relatório HTML gerado: $(basename "$report_file")${NC}"
            
            echo -n "Deseja abrir o relatório no navegador? (s/n): "
            read -r open_browser
            
            if [[ "$open_browser" =~ ^[Ss]$ ]]; then
                if declare -f open_report_controlled >/dev/null 2>&1; then
                    open_report_controlled "$report_file"
                else
                    echo "❌ Função open_report_controlled não disponível"
                    echo "📁 Relatório salvo em: $report_file"
                fi
            fi
        else
            echo "❌ Erro ao gerar relatório HTML"
        fi
    else
        echo ""
        echo -e "${YELLOW}⚠️  Módulo de relatórios HTML não disponível${NC}"
    fi
    
    log_message "URL analisada: $url"
}
EOF

# Encontrar linha onde começa a função analyze_url atual
start_line=$(grep -n "^analyze_url()" security_tool.sh | cut -d: -f1)

if [[ -n "$start_line" ]]; then
    echo "✅ Função analyze_url encontrada na linha $start_line"
    
    # Encontrar linha onde termina a função (próxima função ou final do arquivo)
    end_line=$(tail -n +$((start_line + 1)) security_tool.sh | grep -n "^[a-zA-Z_][a-zA-Z0-9_]*() {" | head -1 | cut -d: -f1)
    
    if [[ -n "$end_line" ]]; then
        end_line=$((start_line + end_line - 1))
        echo "✅ Final da função encontrado na linha $end_line"
    else
        # Se não encontrou próxima função, vai até o final
        end_line=$(wc -l < security_tool.sh)
        echo "✅ Usando final do arquivo como limite (linha $end_line)"
    fi
    
    # Criar novo arquivo
    head -n $((start_line - 1)) security_tool.sh > temp_file.sh
    cat new_analyze_url.txt >> temp_file.sh
    echo "" >> temp_file.sh
    tail -n +$((end_line + 1)) security_tool.sh >> temp_file.sh
    
    # Substituir arquivo original
    mv temp_file.sh security_tool.sh
    chmod +x security_tool.sh
    
    echo "✅ Função analyze_url substituída com sucesso"
else
    echo "❌ Função analyze_url não encontrada"
fi

# Limpar arquivos temporários
rm -f new_analyze_url.txt

echo "✅ Correção manual concluída"
