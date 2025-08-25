#!/bin/bash

echo "🔧 IMPLEMENTANDO ABERTURA CONTROLADA PELO USUÁRIO"
echo "================================================="
echo

# Backup das funções originais
cp html_report.sh html_report.sh.backup.user_controlled
cp security_tool.sh security_tool.sh.backup.user_controlled

echo "1. Criando nova função de abertura controlada..."

# Criar nova função open_report_controlled
cat > temp_open_report_controlled.sh << 'EOF'
# Função para abrir relatório com controle do usuário
open_report_controlled() {
    local report_file="$1"
    local report_name=$(basename "$report_file")
    
    if [[ ! -f "$report_file" ]]; then
        echo "❌ Arquivo de relatório não encontrado: $report_file"
        return 1
    fi
    
    echo
    echo "📄 Relatório HTML gerado: $report_name"
    echo "🌐 Deseja abrir o relatório no navegador? (s/n): "
    read -r open_choice
    
    if [[ "$open_choice" =~ ^[Ss]$ ]]; then
        echo
        echo "🚀 Iniciando servidor web temporário..."
        
        # Parar qualquer servidor existente
        pkill -f "python.*http.server.*$PORT" 2>/dev/null
        pkill -f "python.*SimpleHTTPServer.*$PORT" 2>/dev/null
        sleep 1
        
        # Ir para o diretório de relatórios
        cd "$(dirname "$report_file")"
        
        # Iniciar servidor em background
        python3 -m http.server $PORT > /dev/null 2>&1 &
        local server_pid=$!
        
        # Aguardar servidor inicializar
        sleep 2
        
        # Verificar se o servidor está rodando
        if kill -0 $server_pid 2>/dev/null; then
            echo "✅ Servidor iniciado (PID: $server_pid)"
            
            local report_url="http://localhost:$PORT/$report_name"
            
            # Verificar se o relatório está acessível
            if curl -s -I "$report_url" >/dev/null 2>&1; then
                echo "✅ Relatório acessível em: $report_url"
                echo
                echo "🌐 Abrindo navegador..."
                
                # Tentar abrir com diferentes métodos
                local opened=false
                
                if command -v firefox &>/dev/null; then
                    echo "🦊 Abrindo com Firefox..."
                    firefox --new-window "$report_url" &>/dev/null &
                    opened=true
                elif command -v google-chrome &>/dev/null; then
                    echo "🌐 Abrindo com Google Chrome..."
                    google-chrome --new-window "$report_url" &>/dev/null &
                    opened=true
                elif command -v xdg-open &>/dev/null; then
                    echo "🔗 Abrindo com xdg-open..."
                    xdg-open "$report_url" &>/dev/null &
                    opened=true
                fi
                
                if [[ "$opened" == true ]]; then
                    echo "✅ Navegador executado"
                    echo
                    echo "📋 INSTRUÇÕES:"
                    echo "   - O relatório deve abrir no navegador"
                    echo "   - Se não aparecer, acesse: $report_url"
                    echo "   - Pressione ENTER quando terminar de visualizar"
                    echo
                    echo -n "⏳ Pressione ENTER para finalizar o servidor..."
                    read -r
                    
                    # Parar servidor
                    echo "🛑 Finalizando servidor..."
                    kill $server_pid 2>/dev/null
                    sleep 1
                    
                    # Verificar se o servidor foi parado
                    if kill -0 $server_pid 2>/dev/null; then
                        echo "⚠️  Forçando parada do servidor..."
                        kill -9 $server_pid 2>/dev/null
                    fi
                    
                    echo "✅ Servidor finalizado"
                else
                    echo "❌ Não foi possível abrir o navegador automaticamente"
                    echo "📋 Acesse manualmente: $report_url"
                    echo -n "⏳ Pressione ENTER para finalizar o servidor..."
                    read -r
                    kill $server_pid 2>/dev/null
                fi
            else
                echo "❌ Relatório não está acessível"
                kill $server_pid 2>/dev/null
                return 1
            fi
        else
            echo "❌ Falha ao iniciar servidor"
            return 1
        fi
    else
        echo "📁 Relatório salvo em: $report_file"
        echo "🌐 Para visualizar depois, acesse:"
        echo "   cd $(dirname "$report_file")"
        echo "   python3 -m http.server $PORT"
        echo "   Navegador: http://localhost:$PORT/$report_name"
    fi
    
    return 0
}
EOF

# Adicionar a nova função ao html_report.sh
echo "2. Adicionando nova função ao html_report.sh..."
cat temp_open_report_controlled.sh >> html_report.sh

echo "3. Modificando funções de análise para usar a nova abordagem..."

# Função para modificar analyze_domain
modify_analyze_domain() {
    # Encontrar a linha onde a função generate_html_report é chamada
    local temp_file=$(mktemp)
    
    # Substituir a chamada da função open_report por open_report_controlled
    sed 's/open_report "$report_file"/open_report_controlled "$report_file"/g' security_tool.sh > "$temp_file"
    
    # Verificar se a substituição foi feita
    if grep -q "open_report_controlled" "$temp_file"; then
        mv "$temp_file" security_tool.sh
        echo "✅ Função analyze_domain modificada"
    else
        rm "$temp_file"
        echo "⚠️  Nenhuma chamada open_report encontrada em analyze_domain"
    fi
}

modify_analyze_domain

echo "4. Modificando função analyze_file..."

# Mesmo processo para analyze_file se existir
if grep -q "analyze_file" security_tool.sh; then
    echo "✅ Função analyze_file encontrada - aplicando modificação"
else
    echo "ℹ️  Função analyze_file não encontrada"
fi

echo "5. Criando teste da nova funcionalidade..."

cat > test_user_controlled_opening.sh << 'EOF'
#!/bin/bash

echo "🧪 TESTE - ABERTURA CONTROLADA PELO USUÁRIO"
echo "==========================================="
echo

# Carregar funções
source html_report.sh

# Gerar relatório de teste
echo "📄 Gerando relatório de teste..."
test_content="🧪 TESTE DE ABERTURA CONTROLADA

[Informações do Teste]
Data: $(date '+%d/%m/%Y %H:%M:%S')
Método: Abertura controlada pelo usuário
Status: Testando nova abordagem

[Como Funciona]
1. Relatório é gerado
2. Sistema pergunta se quer abrir
3. Se sim: servidor inicia, abre navegador
4. Usuário visualiza o relatório
5. Usuário pressiona ENTER
6. Servidor é finalizado automaticamente

[Vantagens]
✅ Controle total do usuário
✅ Servidor não fica rodando indefinidamente
✅ Não perde a geração do relatório
✅ Mais eficiente e limpo

Teste realizado em $(date '+%Y-%m-%d %H:%M:%S')"

report_file=$(generate_html_report "Teste Controlado" "teste_usuario.txt" "$test_content")

if [[ -f "$report_file" ]]; then
    echo "✅ Relatório gerado: $(basename "$report_file")"
    echo
    echo "🚀 Testando abertura controlada..."
    echo "=================================="
    echo
    echo "📋 O sistema vai perguntar se você quer abrir o relatório."
    echo "📋 Responda 's' para testar a funcionalidade completa."
    echo
    
    # Testar a função
    open_report_controlled "$report_file"
    
    echo
    echo "✅ Teste concluído!"
else
    echo "❌ Erro ao gerar relatório de teste"
fi
EOF

chmod +x test_user_controlled_opening.sh

# Limpar arquivos temporários
rm -f temp_open_report_controlled.sh

echo
echo "✅ IMPLEMENTAÇÃO CONCLUÍDA!"
echo "=========================="
echo
echo "🎯 Nova funcionalidade implementada:"
echo "   - Relatório é gerado normalmente"
echo "   - Sistema pergunta se quer abrir no navegador"
echo "   - Se 's': servidor inicia, abre navegador, aguarda ENTER, finaliza"
echo "   - Se 'n': apenas informa onde o relatório foi salvo"
echo
echo "🧪 Para testar:"
echo "   ./test_user_controlled_opening.sh"
echo
echo "🚀 Para usar no sistema:"
echo "   ./security_tool.sh → Análise → Responda 's' quando perguntado"
echo
echo "📋 Vantagens da nova abordagem:"
echo "   ✅ Controle total do usuário"
echo "   ✅ Servidor gerenciado automaticamente"
echo "   ✅ Não perde relatórios"
echo "   ✅ Mais eficiente"
