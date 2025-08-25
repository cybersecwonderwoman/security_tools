#!/bin/bash

# Script para diagnosticar problemas na Security Tools

echo "🔍 DIAGNÓSTICO DE PROBLEMAS - Security Analyzer Tool"
echo "=================================================="
echo

# 1. Verificar se o script principal existe e tem permissões
echo "1. Verificando script principal..."
if [[ -f "./security_tool.sh" ]]; then
    echo "✅ security_tool.sh encontrado"
    ls -la security_tool.sh
    echo
else
    echo "❌ security_tool.sh não encontrado"
    exit 1
fi

# 2. Verificar módulo de relatórios HTML
echo "2. Verificando módulo de relatórios HTML..."
if [[ -f "./html_report.sh" ]]; then
    echo "✅ html_report.sh encontrado"
    ls -la html_report.sh
    
    # Verificar se as funções principais estão definidas
    echo "   Verificando funções principais:"
    if grep -q "generate_html_report" html_report.sh; then
        echo "   ✅ generate_html_report encontrada"
    else
        echo "   ❌ generate_html_report não encontrada"
    fi
    
    if grep -q "open_report_controlled" html_report.sh; then
        echo "   ✅ open_report_controlled encontrada"
    else
        echo "   ❌ open_report_controlled não encontrada"
    fi
    echo
else
    echo "❌ html_report.sh não encontrado"
    echo
fi

# 3. Verificar diretório de relatórios
echo "3. Verificando diretório de relatórios..."
REPORTS_DIR="$HOME/.security_analyzer/reports"
if [[ -d "$REPORTS_DIR" ]]; then
    echo "✅ Diretório de relatórios existe: $REPORTS_DIR"
    echo "   Número de relatórios: $(ls -1 "$REPORTS_DIR" | wc -l)"
    echo "   Últimos 3 relatórios:"
    ls -lt "$REPORTS_DIR" | head -4
    echo
else
    echo "❌ Diretório de relatórios não existe"
    echo
fi

# 4. Verificar dependências para relatórios
echo "4. Verificando dependências para relatórios..."
dependencies=("python3" "curl" "firefox" "google-chrome" "xdg-open")
for dep in "${dependencies[@]}"; do
    if command -v "$dep" &> /dev/null; then
        echo "   ✅ $dep encontrado"
    else
        echo "   ❌ $dep não encontrado"
    fi
done
echo

# 5. Testar geração de relatório simples
echo "5. Testando geração de relatório simples..."
if [[ -f "./html_report.sh" ]]; then
    source ./html_report.sh
    
    if declare -f generate_html_report >/dev/null 2>&1; then
        echo "   ✅ Função generate_html_report carregada"
        
        # Tentar gerar um relatório de teste
        test_content="Teste de relatório\nData: $(date)\nConteúdo de teste"
        test_report=$(generate_html_report "Teste" "diagnóstico" "$test_content" 2>&1)
        
        if [[ $? -eq 0 && -n "$test_report" ]]; then
            echo "   ✅ Relatório de teste gerado: $test_report"
            if [[ -f "$test_report" ]]; then
                echo "   ✅ Arquivo de relatório existe"
                echo "   Tamanho: $(stat -c%s "$test_report") bytes"
            else
                echo "   ❌ Arquivo de relatório não foi criado"
            fi
        else
            echo "   ❌ Erro ao gerar relatório de teste"
            echo "   Erro: $test_report"
        fi
    else
        echo "   ❌ Função generate_html_report não foi carregada"
    fi
else
    echo "   ❌ html_report.sh não disponível"
fi
echo

# 6. Testar análise de URL específica
echo "6. Testando análise de URL (opção 2)..."
echo "   Simulando entrada para análise de URL..."

# Criar um script temporário para testar a opção 2
cat > test_url_analysis.sh << 'EOF'
#!/bin/bash
source ./security_tool.sh

# Simular entrada do usuário
echo "http://example.com" | analyze_url
EOF

chmod +x test_url_analysis.sh

if ./test_url_analysis.sh > test_url_output.log 2>&1; then
    echo "   ✅ Análise de URL executada"
    echo "   Saída:"
    cat test_url_output.log | head -10
else
    echo "   ❌ Erro na análise de URL"
    echo "   Erro:"
    cat test_url_output.log
fi

# Limpar arquivos temporários
rm -f test_url_analysis.sh test_url_output.log
echo

# 7. Verificar logs de erro
echo "7. Verificando logs de erro..."
LOG_FILE="$HOME/.security_analyzer/analysis.log"
if [[ -f "$LOG_FILE" ]]; then
    echo "   ✅ Log file existe: $LOG_FILE"
    echo "   Últimas 5 entradas:"
    tail -5 "$LOG_FILE"
else
    echo "   ❌ Log file não encontrado"
fi
echo

# 8. Verificar porta para servidor web
echo "8. Verificando disponibilidade da porta para servidor web..."
PORT=8080
if netstat -tuln 2>/dev/null | grep -q ":$PORT "; then
    echo "   ⚠️  Porta $PORT já está em uso"
    echo "   Processos usando a porta:"
    lsof -i :$PORT 2>/dev/null || echo "   Não foi possível identificar o processo"
else
    echo "   ✅ Porta $PORT disponível"
fi
echo

echo "🏁 DIAGNÓSTICO CONCLUÍDO"
echo "========================"
echo
echo "📋 RESUMO DOS PROBLEMAS ENCONTRADOS:"
echo "1. Relatórios não abrem: Verificar se o navegador está sendo executado corretamente"
echo "2. Análise de URL (opção 2): Verificar se a função analyze_url está funcionando"
echo
echo "💡 PRÓXIMOS PASSOS:"
echo "1. Execute este diagnóstico e analise os resultados"
echo "2. Verifique se há erros específicos nos logs"
echo "3. Teste manualmente a abertura de um relatório HTML"
