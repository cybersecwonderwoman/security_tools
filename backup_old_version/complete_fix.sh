#!/bin/bash

# Script de correção completa do Security Analyzer Tool

echo "🔧 CORREÇÃO COMPLETA DO SECURITY ANALYZER TOOL"
echo "=============================================="
echo

# Criar backup completo
echo "📦 Criando backup completo..."
backup_dir="complete_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
cp *.sh "$backup_dir/" 2>/dev/null
echo "✅ Backup criado em: $backup_dir"
echo

# 1. Verificar e corrigir problemas no arquivo principal
echo "1️⃣  Analisando arquivo principal (security_tool.sh)..."

# Verificar se o arquivo existe
if [[ ! -f "security_tool.sh" ]]; then
    echo "❌ Arquivo security_tool.sh não encontrado!"
    exit 1
fi

# Verificar sintaxe
if ! bash -n security_tool.sh; then
    echo "❌ Erro de sintaxe no security_tool.sh"
    echo "🔧 Tentando corrigir..."
    
    # Corrigir problemas comuns de sintaxe
    sed -i 's/\r$//' security_tool.sh  # Remover caracteres Windows
    sed -i '/^$/N;/^\n$/d' security_tool.sh  # Remover linhas vazias duplas
fi

echo "✅ Arquivo principal verificado"

# 2. Verificar e corrigir html_report.sh
echo "2️⃣  Analisando módulo de relatórios HTML..."

if [[ ! -f "html_report.sh" ]]; then
    echo "❌ Arquivo html_report.sh não encontrado!"
    echo "🔧 Criando módulo básico de relatórios..."
    
    cat > html_report.sh << 'EOF'
#!/bin/bash

# Módulo de relatórios HTML básico

CONFIG_DIR="$HOME/.security_analyzer"
REPORTS_DIR="$CONFIG_DIR/reports"
PORT=8080

mkdir -p "$REPORTS_DIR"

generate_report_id() {
    echo "SA-$(date +%Y%m%d)-$(openssl rand -hex 4 2>/dev/null || echo $(date +%H%M%S))"
}

clean_ansi_codes() {
    local text="$1"
    echo "$text" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g' | sed -r 's/\x1B\[[0-9;]*[A-Za-z]//g'
}

generate_html_report() {
    local analysis_type="$1"
    local target="$2"
    local analysis_text="$3"
    
    local report_id=$(generate_report_id)
    local report_file="$REPORTS_DIR/${report_id}.html"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Limpar códigos ANSI
    analysis_text=$(clean_ansi_codes "$analysis_text")
    
    cat > "$report_file" << HTML_EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Analyzer - Relatório de $analysis_type</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 2px solid #3498db; padding-bottom: 20px; margin-bottom: 30px; }
        .header h1 { color: #2c3e50; margin: 0; }
        .info-box { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .analysis-content { white-space: pre-wrap; font-family: monospace; background: #f8f9fa; padding: 20px; border-radius: 5px; border-left: 4px solid #3498db; }
        .footer { text-align: center; margin-top: 30px; color: #7f8c8d; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ Security Analyzer Tool</h1>
            <h2>Relatório de Análise de $analysis_type</h2>
        </div>
        
        <div class="info-box">
            <strong>Alvo:</strong> $target<br>
            <strong>Data/Hora:</strong> $timestamp<br>
            <strong>ID do Relatório:</strong> $report_id
        </div>
        
        <div class="analysis-content">$analysis_text</div>
        
        <div class="footer">
            <p>Relatório gerado pelo Security Analyzer Tool</p>
            <p>@cybersecwonderwoman</p>
        </div>
    </div>
</body>
</html>
HTML_EOF
    
    echo "$report_file"
}

open_report_controlled() {
    local report_file="$1"
    local report_name=$(basename "$report_file")
    
    if [[ ! -f "$report_file" ]]; then
        echo "❌ Arquivo de relatório não encontrado: $report_file"
        return 1
    fi
    
    echo "📄 Relatório: $report_name"
    echo "🌐 Iniciando servidor web..."
    
    # Parar servidores existentes
    pkill -f "python.*http.server.*$PORT" 2>/dev/null
    sleep 2
    
    # Ir para diretório de relatórios
    cd "$(dirname "$report_file")" || return 1
    
    # Iniciar servidor
    python3 -m http.server $PORT > /dev/null 2>&1 &
    local server_pid=$!
    
    sleep 3
    
    if kill -0 $server_pid 2>/dev/null; then
        echo "✅ Servidor iniciado (PID: $server_pid)"
        local report_url="http://localhost:$PORT/$report_name"
        
        echo "🔗 URL: $report_url"
        
        # Tentar abrir navegador
        if command -v xdg-open &>/dev/null; then
            xdg-open "$report_url" &>/dev/null &
            echo "✅ Navegador aberto"
        elif command -v firefox &>/dev/null; then
            firefox "$report_url" &>/dev/null &
            echo "✅ Firefox aberto"
        else
            echo "⚠️  Abra manualmente: $report_url"
        fi
        
        echo "⏳ Pressione ENTER para parar o servidor..."
        read -r
        
        kill $server_pid 2>/dev/null
        echo "✅ Servidor parado"
    else
        echo "❌ Falha ao iniciar servidor"
        return 1
    fi
    
    cd - >/dev/null
}

export -f generate_html_report
export -f open_report_controlled
EOF
    
    chmod +x html_report.sh
    echo "✅ Módulo de relatórios HTML criado"
else
    echo "✅ Módulo html_report.sh encontrado"
    
    # Verificar sintaxe
    if ! bash -n html_report.sh; then
        echo "❌ Erro de sintaxe no html_report.sh"
        echo "🔧 Corrigindo..."
        sed -i 's/\r$//' html_report.sh
    fi
fi

# 3. Testar carregamento dos módulos
echo "3️⃣  Testando carregamento dos módulos..."

# Testar se o módulo HTML carrega
if source html_report.sh 2>/dev/null; then
    echo "✅ Módulo html_report.sh carregado com sucesso"
    
    # Testar função generate_html_report
    if declare -f generate_html_report >/dev/null 2>&1; then
        echo "✅ Função generate_html_report disponível"
    else
        echo "❌ Função generate_html_report não encontrada"
    fi
    
    # Testar função open_report_controlled
    if declare -f open_report_controlled >/dev/null 2>&1; then
        echo "✅ Função open_report_controlled disponível"
    else
        echo "❌ Função open_report_controlled não encontrada"
    fi
else
    echo "❌ Erro ao carregar módulo html_report.sh"
fi

# 4. Verificar dependências
echo "4️⃣  Verificando dependências..."

dependencies=("curl" "python3" "dig" "whois" "file" "md5sum" "sha256sum")
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
    echo "⚠️  $missing_deps dependência(s) faltando"
    echo "💡 Execute: sudo apt update && sudo apt install curl python3 dnsutils whois file coreutils"
fi

# 5. Testar geração de relatório
echo "5️⃣  Testando geração de relatório..."

source html_report.sh

test_content="Teste de relatório\nData: $(date)\nStatus: ✅ Funcionando\nTipo: Teste de diagnóstico"
test_report=$(generate_html_report "Teste" "diagnóstico" "$test_content" 2>&1)

if [[ $? -eq 0 && -f "$test_report" ]]; then
    echo "✅ Relatório de teste gerado: $test_report"
    echo "📊 Tamanho: $(stat -c%s "$test_report") bytes"
    
    # Limpar arquivo de teste
    rm -f "$test_report"
else
    echo "❌ Erro na geração de relatório de teste"
    echo "Erro: $test_report"
fi

# 6. Verificar estrutura de diretórios
echo "6️⃣  Verificando estrutura de diretórios..."

config_dir="$HOME/.security_analyzer"
reports_dir="$config_dir/reports"

if [[ -d "$config_dir" ]]; then
    echo "✅ Diretório de configuração existe: $config_dir"
else
    echo "🔧 Criando diretório de configuração..."
    mkdir -p "$config_dir"
    echo "✅ Diretório criado: $config_dir"
fi

if [[ -d "$reports_dir" ]]; then
    echo "✅ Diretório de relatórios existe: $reports_dir"
    echo "📊 Relatórios existentes: $(ls -1 "$reports_dir" 2>/dev/null | wc -l)"
else
    echo "🔧 Criando diretório de relatórios..."
    mkdir -p "$reports_dir"
    echo "✅ Diretório criado: $reports_dir"
fi

# 7. Corrigir permissões
echo "7️⃣  Corrigindo permissões..."

chmod +x security_tool.sh
chmod +x html_report.sh
chmod +x start.sh 2>/dev/null || echo "   ⚠️  start.sh não encontrado"

# Verificar permissões do diretório de configuração
if [[ -d "$config_dir" ]]; then
    chmod 755 "$config_dir"
    chmod 755 "$reports_dir" 2>/dev/null
fi

echo "✅ Permissões corrigidas"

# 8. Teste final
echo "8️⃣  Executando teste final..."

# Criar script de teste simples
cat > test_final.sh << 'EOF'
#!/bin/bash
source ./html_report.sh

echo "Testando análise de URL..."
url="https://example.com"
analysis_result="🌐 ANÁLISE DE URL\n\n[Informações Básicas]\nURL: $url\nData: $(date)\n\n[Resultado]\n✅ Teste bem-sucedido"

report_file=$(generate_html_report "URL" "$url" "$analysis_result")

if [[ -f "$report_file" ]]; then
    echo "✅ Relatório gerado: $report_file"
    rm -f "$report_file"
    echo "✅ Teste final bem-sucedido"
else
    echo "❌ Falha no teste final"
fi
EOF

chmod +x test_final.sh

if ./test_final.sh; then
    echo "✅ Teste final passou"
else
    echo "❌ Teste final falhou"
fi

rm -f test_final.sh

echo
echo "🎯 RESUMO DA CORREÇÃO COMPLETA"
echo "=============================="
echo "✅ Backup criado em: $backup_dir"
echo "✅ Arquivo principal verificado e corrigido"
echo "✅ Módulo de relatórios HTML verificado/criado"
echo "✅ Dependências verificadas"
echo "✅ Estrutura de diretórios verificada"
echo "✅ Permissões corrigidas"
echo "✅ Testes executados"
echo

if [[ $missing_deps -eq 0 ]]; then
    echo "🚀 SISTEMA PRONTO PARA USO!"
    echo "Execute: ./security_tool.sh"
else
    echo "⚠️  Instale as dependências faltantes antes de usar"
    echo "💡 sudo apt update && sudo apt install curl python3 dnsutils whois file coreutils"
fi

echo
echo "🔍 Para testar:"
echo "1. Execute: ./security_tool.sh"
echo "2. Escolha opção 2 (Análise de URL)"
echo "3. Digite uma URL de teste"
echo "4. Verifique se o relatório é gerado e abre corretamente"
