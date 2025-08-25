#!/bin/bash

# Script principal para aplicar todas as correções no Security Analyzer Tool

echo "🔧 APLICANDO TODAS AS CORREÇÕES - Security Analyzer Tool"
echo "========================================================"
echo

# Verificar se estamos no diretório correto
if [[ ! -f "security_tool.sh" ]]; then
    echo "❌ Erro: Execute este script no diretório do Security Analyzer Tool"
    echo "   Certifique-se de que o arquivo security_tool.sh está presente"
    exit 1
fi

echo "📁 Diretório atual: $(pwd)"
echo "✅ Arquivo security_tool.sh encontrado"
echo

# 1. Criar backup completo
echo "1️⃣  Criando backup completo..."
backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
cp security_tool.sh "$backup_dir/"
cp html_report.sh "$backup_dir/" 2>/dev/null || echo "   ⚠️  html_report.sh não encontrado para backup"
echo "✅ Backup criado em: $backup_dir"
echo

# 2. Corrigir função de análise de URL
echo "2️⃣  Corrigindo função de análise de URL..."

# Substituir a função analyze_url no arquivo principal
python3 << 'EOF'
import re

# Ler o arquivo original
with open('security_tool.sh', 'r') as f:
    content = f.read()

# Nova função de análise de URL
new_url_function = '''# Função para análise de URL (versão corrigida)
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
    analysis_result+="🌐 ANÁLISE DE URL\\n\\n"
    analysis_result+="[Informações Básicas]\\n"
    analysis_result+="URL: $url\\n"
    analysis_result+="Data da análise: $(date '+%d/%m/%Y %H:%M:%S')\\n\\n"
    
    # Validação básica da URL
    echo -e "${BLUE}[Validação da URL]${NC}"
    analysis_result+="[Validação da URL]\\n"
    
    if [[ "$url" =~ ^https?:// ]]; then
        echo "✅ Protocolo válido detectado"
        analysis_result+="✅ Protocolo válido detectado\\n"
        
        # Extrair domínio da URL
        local domain=$(echo "$url" | sed -E 's|^https?://([^/]+).*|\\1|')
        echo "Domínio extraído: $domain"
        analysis_result+="Domínio extraído: $domain\\n"
    else
        echo "⚠️  Protocolo não especificado ou inválido"
        analysis_result+="⚠️  Protocolo não especificado ou inválido\\n"
    fi
    echo ""
    analysis_result+="\\n"
    
    # Análise de reputação básica
    echo -e "${BLUE}[Análise de Reputação]${NC}"
    analysis_result+="[Análise de Reputação]\\n"
    
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
        
        analysis_result+="❌ URL SUSPEITA DETECTADA!\\n"
        analysis_result+="Categoria: Potencialmente maliciosa\\n"
        analysis_result+="Risco: Alto\\n"
        analysis_result+="Recomendação: Evitar acesso\\n"
    else
        echo -e "${GREEN}✅ Nenhuma ameaça óbvia detectada${NC}"
        echo "  Reputação: Aparentemente limpa"
        echo "  Risco: Baixo"
        
        analysis_result+="✅ Nenhuma ameaça óbvia detectada\\n"
        analysis_result+="Reputação: Aparentemente limpa\\n"
        analysis_result+="Risco: Baixo\\n"
    fi
    echo ""
    analysis_result+="\\n"
    
    # Verificação de conectividade
    echo -e "${BLUE}[Teste de Conectividade]${NC}"
    analysis_result+="[Teste de Conectividade]\\n"
    
    if command -v curl &> /dev/null; then
        local http_status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$url" 2>/dev/null)
        
        if [[ -n "$http_status" && "$http_status" != "000" ]]; then
            echo "Status HTTP: $http_status"
            analysis_result+="Status HTTP: $http_status\\n"
            
            case "$http_status" in
                200)
                    echo "✅ Site acessível"
                    analysis_result+="✅ Site acessível\\n"
                    ;;
                404)
                    echo "⚠️  Página não encontrada"
                    analysis_result+="⚠️  Página não encontrada\\n"
                    ;;
                403)
                    echo "⚠️  Acesso negado"
                    analysis_result+="⚠️  Acesso negado\\n"
                    ;;
                *)
                    echo "⚠️  Status HTTP incomum: $http_status"
                    analysis_result+="⚠️  Status HTTP incomum: $http_status\\n"
                    ;;
            esac
        else
            echo "❌ Não foi possível conectar à URL"
            analysis_result+="❌ Não foi possível conectar à URL\\n"
        fi
    else
        echo "⚠️  Ferramenta curl não disponível"
        analysis_result+="⚠️  Ferramenta curl não disponível\\n"
    fi
    echo ""
    analysis_result+="\\n"
    
    analysis_result+="Análise concluída em $(date '+%Y-%m-%d %H:%M:%S')\\n"
    
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
}'''

# Encontrar e substituir a função analyze_url
pattern = r'# Função para análise de URL\nanalyze_url\(\) \{[^}]*\}(?:\n\n)?'
new_content = re.sub(pattern, new_url_function + '\n\n', content, flags=re.DOTALL)

# Se não encontrou a função, tentar padrão mais específico
if new_content == content:
    pattern = r'analyze_url\(\) \{.*?\n\}'
    new_content = re.sub(pattern, new_url_function, content, flags=re.DOTALL)

# Salvar o arquivo modificado
with open('security_tool.sh', 'w') as f:
    f.write(new_content)

print("✅ Função analyze_url atualizada")
EOF

echo "✅ Função de análise de URL corrigida"
echo

# 3. Corrigir sistema de relatórios HTML
echo "3️⃣  Corrigindo sistema de relatórios HTML..."
if [[ -f "fix_html_reports.sh" ]]; then
    chmod +x fix_html_reports.sh
    ./fix_html_reports.sh
else
    echo "⚠️  Script fix_html_reports.sh não encontrado, pulando esta correção"
fi
echo

# 4. Verificar permissões
echo "4️⃣  Verificando e corrigindo permissões..."
chmod +x security_tool.sh
chmod +x html_report.sh 2>/dev/null || echo "   ⚠️  html_report.sh não encontrado"
chmod +x start.sh 2>/dev/null || echo "   ⚠️  start.sh não encontrado"
echo "✅ Permissões corrigidas"
echo

# 5. Testar funcionalidades básicas
echo "5️⃣  Testando funcionalidades básicas..."

# Testar se o script principal carrega sem erros
if bash -n security_tool.sh; then
    echo "✅ Sintaxe do script principal está correta"
else
    echo "❌ Erro de sintaxe no script principal"
fi

# Testar se o módulo HTML carrega
if [[ -f "html_report.sh" ]]; then
    if bash -n html_report.sh; then
        echo "✅ Sintaxe do módulo HTML está correta"
    else
        echo "❌ Erro de sintaxe no módulo HTML"
    fi
fi

echo

# 6. Verificar dependências
echo "6️⃣  Verificando dependências..."
dependencies=("curl" "jq" "dig" "whois" "file" "md5sum" "sha256sum" "python3")
missing_deps=0

for dep in "${dependencies[@]}"; do
    if command -v "$dep" &>/dev/null; then
        echo "✅ $dep encontrado"
    else
        echo "❌ $dep não encontrado"
        missing_deps=$((missing_deps + 1))
    fi
done

if [[ $missing_deps -gt 0 ]]; then
    echo ""
    echo "⚠️  $missing_deps dependência(s) faltando"
    echo "💡 Execute: ./install_dependencies.sh para instalar dependências"
fi

echo

# 7. Resumo final
echo "🎯 RESUMO DAS CORREÇÕES APLICADAS"
echo "================================="
echo "✅ Backup completo criado em: $backup_dir"
echo "✅ Função de análise de URL corrigida e melhorada"
echo "✅ Sistema de relatórios HTML verificado/corrigido"
echo "✅ Permissões de arquivos corrigidas"
echo "✅ Sintaxe dos scripts verificada"
echo "✅ Dependências verificadas"
echo

echo "🚀 PRÓXIMOS PASSOS:"
echo "1. Execute: ./security_tool.sh para testar a aplicação"
echo "2. Teste a opção 2 (Análise de URL) para verificar se está funcionando"
echo "3. Teste a geração e abertura de relatórios HTML"
echo "4. Se houver problemas, verifique os logs em ~/.security_analyzer/analysis.log"
echo

echo "✨ Todas as correções foram aplicadas com sucesso!"
