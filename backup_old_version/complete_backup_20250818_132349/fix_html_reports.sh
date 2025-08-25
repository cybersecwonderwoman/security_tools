#!/bin/bash

# Script para corrigir problemas com relatórios HTML

echo "🔧 Corrigindo sistema de relatórios HTML..."

# Verificar se o arquivo html_report.sh existe
if [[ ! -f "html_report.sh" ]]; then
    echo "❌ Arquivo html_report.sh não encontrado!"
    exit 1
fi

# Backup do arquivo original
cp html_report.sh html_report.sh.backup.$(date +%Y%m%d_%H%M%S)

# Verificar e corrigir a função open_report_controlled
echo "🔍 Verificando função open_report_controlled..."

if ! grep -q "open_report_controlled" html_report.sh; then
    echo "❌ Função open_report_controlled não encontrada!"
    
    # Adicionar função corrigida
    cat >> html_report.sh << 'EOF'

# Função para abrir relatório com controle do usuário (versão corrigida)
open_report_controlled() {
    local report_file="$1"
    local report_name=$(basename "$report_file")
    
    if [[ ! -f "$report_file" ]]; then
        echo "❌ Arquivo de relatório não encontrado: $report_file"
        return 1
    fi
    
    echo ""
    echo "📄 Relatório HTML: $report_name"
    echo "🌐 Iniciando servidor web temporário..."
    
    # Parar qualquer servidor existente na porta
    pkill -f "python.*http.server.*$PORT" 2>/dev/null
    pkill -f "python.*SimpleHTTPServer.*$PORT" 2>/dev/null
    sleep 2
    
    # Ir para o diretório de relatórios
    cd "$(dirname "$report_file")" || {
        echo "❌ Erro: Não foi possível acessar o diretório do relatório"
        return 1
    }
    
    # Verificar se a porta está disponível
    if netstat -tuln 2>/dev/null | grep -q ":$PORT "; then
        echo "⚠️  Porta $PORT em uso, tentando porta alternativa..."
        PORT=$((PORT + 1))
    fi
    
    # Iniciar servidor em background
    if command -v python3 &>/dev/null; then
        python3 -m http.server $PORT > /dev/null 2>&1 &
        local server_pid=$!
    elif command -v python &>/dev/null; then
        python -m SimpleHTTPServer $PORT > /dev/null 2>&1 &
        local server_pid=$!
    else
        echo "❌ Python não encontrado. Não é possível iniciar servidor web."
        return 1
    fi
    
    # Aguardar servidor inicializar
    sleep 3
    
    # Verificar se o servidor está rodando
    if kill -0 $server_pid 2>/dev/null; then
        echo "✅ Servidor iniciado (PID: $server_pid, Porta: $PORT)"
        
        local report_url="http://localhost:$PORT/$report_name"
        
        # Verificar se o relatório está acessível
        if command -v curl &>/dev/null && curl -s -I "$report_url" >/dev/null 2>&1; then
            echo "✅ Relatório acessível em: $report_url"
            echo ""
            echo "🌐 Tentando abrir navegador..."
            
            # Tentar abrir com diferentes navegadores
            local opened=false
            
            # Lista de navegadores para tentar
            local browsers=("firefox" "google-chrome" "chromium-browser" "opera" "xdg-open")
            
            for browser in "${browsers[@]}"; do
                if command -v "$browser" &>/dev/null; then
                    echo "🔗 Abrindo com $browser..."
                    
                    case "$browser" in
                        "firefox")
                            firefox --new-window "$report_url" &>/dev/null &
                            ;;
                        "google-chrome")
                            google-chrome --new-window "$report_url" &>/dev/null &
                            ;;
                        "chromium-browser")
                            chromium-browser --new-window "$report_url" &>/dev/null &
                            ;;
                        "opera")
                            opera --new-window "$report_url" &>/dev/null &
                            ;;
                        "xdg-open")
                            xdg-open "$report_url" &>/dev/null &
                            ;;
                    esac
                    
                    opened=true
                    break
                fi
            done
            
            if [[ "$opened" == true ]]; then
                echo "✅ Navegador executado com sucesso"
                echo ""
                echo "📋 INSTRUÇÕES:"
                echo "   • O relatório deve abrir automaticamente no navegador"
                echo "   • Se não aparecer, acesse manualmente: $report_url"
                echo "   • Pressione ENTER quando terminar de visualizar"
                echo ""
                echo -n "⏳ Pressione ENTER para finalizar o servidor..."
                read -r
                
                # Parar servidor
                echo ""
                echo "🛑 Finalizando servidor..."
                kill $server_pid 2>/dev/null
                sleep 2
                
                # Verificar se o servidor foi parado
                if kill -0 $server_pid 2>/dev/null; then
                    echo "⚠️  Forçando parada do servidor..."
                    kill -9 $server_pid 2>/dev/null
                fi
                
                echo "✅ Servidor finalizado com sucesso"
            else
                echo "❌ Nenhum navegador compatível encontrado"
                echo ""
                echo "📋 ACESSO MANUAL:"
                echo "   • Abra seu navegador manualmente"
                echo "   • Acesse: $report_url"
                echo "   • Pressione ENTER quando terminar"
                echo ""
                echo -n "⏳ Pressione ENTER para finalizar o servidor..."
                read -r
                kill $server_pid 2>/dev/null
            fi
        else
            echo "❌ Relatório não está acessível via HTTP"
            echo "📁 Você pode abrir o arquivo diretamente: $report_file"
            kill $server_pid 2>/dev/null
            return 1
        fi
    else
        echo "❌ Falha ao iniciar servidor web"
        return 1
    fi
    
    # Retornar ao diretório original
    cd - >/dev/null
}

# Exportar função
export -f open_report_controlled
EOF
    
    echo "✅ Função open_report_controlled adicionada"
else
    echo "✅ Função open_report_controlled já existe"
fi

# Verificar se a função generate_html_report está funcionando
echo ""
echo "🔍 Testando geração de relatório..."

# Carregar o módulo
source html_report.sh

if declare -f generate_html_report >/dev/null 2>&1; then
    echo "✅ Função generate_html_report disponível"
    
    # Teste básico
    test_content="Teste de relatório\nData: $(date)\nStatus: ✅ Funcionando"
    test_report=$(generate_html_report "Teste" "diagnóstico" "$test_content" 2>&1)
    
    if [[ $? -eq 0 && -n "$test_report" ]]; then
        if [[ -f "$test_report" ]]; then
            echo "✅ Teste de geração de relatório bem-sucedido"
            echo "📁 Relatório de teste: $test_report"
            
            # Limpar arquivo de teste
            rm -f "$test_report" 2>/dev/null
        else
            echo "⚠️  Relatório gerado mas arquivo não encontrado"
        fi
    else
        echo "❌ Erro no teste de geração de relatório"
        echo "Erro: $test_report"
    fi
else
    echo "❌ Função generate_html_report não disponível"
fi

echo ""
echo "🔧 Verificando dependências para relatórios..."

# Verificar dependências
dependencies=("python3" "curl")
missing_deps=0

for dep in "${dependencies[@]}"; do
    if command -v "$dep" &>/dev/null; then
        echo "✅ $dep encontrado"
    else
        echo "❌ $dep não encontrado"
        missing_deps=$((missing_deps + 1))
    fi
done

# Verificar navegadores
echo ""
echo "🌐 Verificando navegadores disponíveis..."
browsers=("firefox" "google-chrome" "chromium-browser" "opera")
browser_found=false

for browser in "${browsers[@]}"; do
    if command -v "$browser" &>/dev/null; then
        echo "✅ $browser encontrado"
        browser_found=true
    fi
done

if [[ "$browser_found" == false ]]; then
    echo "⚠️  Nenhum navegador específico encontrado, tentando xdg-open..."
    if command -v xdg-open &>/dev/null; then
        echo "✅ xdg-open encontrado (fallback)"
    else
        echo "❌ xdg-open não encontrado"
        echo "⚠️  Instale um navegador web para visualizar relatórios"
    fi
fi

echo ""
echo "📋 RESUMO DAS CORREÇÕES:"
echo "✅ Backup criado: html_report.sh.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Função open_report_controlled verificada/corrigida"
echo "✅ Teste de geração de relatório executado"
echo "✅ Dependências verificadas"

if [[ $missing_deps -eq 0 ]]; then
    echo "✅ Todas as dependências estão disponíveis"
else
    echo "⚠️  $missing_deps dependência(s) faltando"
fi

echo ""
echo "🎯 Os relatórios HTML devem funcionar corretamente agora!"
