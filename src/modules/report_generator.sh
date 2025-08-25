#!/bin/bash

# ========================================
# Advanced Report Generator
# Sistema avançado de geração de relatórios
# ========================================

# Carregar dependências
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.conf"
source "$SCRIPT_DIR/../utils/security.sh"
source "$SCRIPT_DIR/../utils/logger.sh"

# Inicializar gerador de relatórios
init_report_generator() {
    create_secure_directory "$REPORTS_DIR"
    log_info "Gerador de relatórios inicializado" "REPORT_GEN"
}

# Gerar relatório HTML avançado
generate_html_report() {
    local analysis_type="$1"
    local target="$2"
    local analysis_text="$3"
    local risk_level="${4:-BAIXO}"
    
    local report_id=$(generate_secure_hash "$target")
    local report_file="$REPORTS_DIR/report_${report_id}.html"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    log_info "Gerando relatório HTML: $report_file" "REPORT_GEN"
    
    # Limpar códigos ANSI do texto
    local clean_text=$(clean_ansi_codes "$analysis_text")
    
    # Determinar classe CSS baseada no risco
    local risk_class=$(get_risk_class "$risk_level")
    
    # Gerar HTML
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Analyzer - Relatório de $analysis_type</title>
    <style>
        $(get_report_css)
    </style>
</head>
<body>
    <div class="container">
        <header class="report-header">
            <div class="header-content">
                <h1>🛡️ Security Analyzer Tool</h1>
                <div class="report-info">
                    <span class="report-type">Relatório de $analysis_type</span>
                    <span class="report-date">$timestamp</span>
                </div>
            </div>
        </header>

        <main class="report-content">
            <section class="summary-section">
                <h2>📋 Resumo Executivo</h2>
                <div class="summary-card $risk_class">
                    <div class="summary-header">
                        <h3>Alvo Analisado</h3>
                        <span class="risk-badge $risk_class">$risk_level</span>
                    </div>
                    <div class="target-info">
                        <strong>$target</strong>
                    </div>
                    <div class="analysis-summary">
                        $(generate_executive_summary "$analysis_type" "$risk_level")
                    </div>
                </div>
            </section>

            <section class="details-section">
                <h2>🔍 Análise Detalhada</h2>
                <div class="analysis-content">
                    <pre>$(echo "$clean_text" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')</pre>
                </div>
            </section>

            <section class="recommendations-section">
                <h2>💡 Recomendações</h2>
                <div class="recommendations-content">
                    $(generate_recommendations_html "$analysis_type" "$risk_level")
                </div>
            </section>

            <section class="metadata-section">
                <h2>📊 Metadados do Relatório</h2>
                <div class="metadata-grid">
                    <div class="metadata-item">
                        <span class="metadata-label">ID do Relatório:</span>
                        <span class="metadata-value">$report_id</span>
                    </div>
                    <div class="metadata-item">
                        <span class="metadata-label">Tipo de Análise:</span>
                        <span class="metadata-value">$analysis_type</span>
                    </div>
                    <div class="metadata-item">
                        <span class="metadata-label">Data/Hora:</span>
                        <span class="metadata-value">$timestamp</span>
                    </div>
                    <div class="metadata-item">
                        <span class="metadata-label">Versão da Ferramenta:</span>
                        <span class="metadata-value">$APP_VERSION</span>
                    </div>
                </div>
            </section>
        </main>

        <footer class="report-footer">
            <div class="footer-content">
                <p>Relatório gerado por <strong>$APP_NAME v$APP_VERSION</strong></p>
                <p>Desenvolvido por <strong>$APP_AUTHOR</strong></p>
                <p class="disclaimer">
                    ⚠️ Este relatório é apenas para fins informativos. 
                    Sempre verifique os resultados com ferramentas adicionais.
                </p>
            </div>
        </footer>
    </div>

    <script>
        $(get_report_javascript)
    </script>
</body>
</html>
EOF

    # Verificar se o arquivo foi criado com sucesso
    if [[ -f "$report_file" ]]; then
        log_info "Relatório HTML gerado com sucesso: $(basename "$report_file")" "REPORT_GEN"
        echo "$report_file"
        return 0
    else
        log_error "Falha ao gerar relatório HTML" "REPORT_GEN"
        return 1
    fi
}

# Obter CSS para o relatório
get_report_css() {
    cat << 'EOF'
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #3498db;
            --success-color: #27ae60;
            --warning-color: #f39c12;
            --danger-color: #e74c3c;
            --light-color: #ecf0f1;
            --dark-color: #34495e;
            --text-color: #2c3e50;
            --background-color: #f8f9fa;
            --border-color: #dee2e6;
            --shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--background-color);
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            box-shadow: var(--shadow);
            min-height: 100vh;
        }

        .report-header {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            padding: 2rem 0;
        }

        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-content h1 {
            font-size: 2.5rem;
            font-weight: 300;
        }

        .report-info {
            text-align: right;
        }

        .report-type {
            display: block;
            font-size: 1.2rem;
            font-weight: 500;
        }

        .report-date {
            display: block;
            font-size: 0.9rem;
            opacity: 0.8;
            margin-top: 0.5rem;
        }

        .report-content {
            padding: 2rem;
        }

        section {
            margin-bottom: 3rem;
        }

        h2 {
            color: var(--primary-color);
            border-bottom: 2px solid var(--secondary-color);
            padding-bottom: 0.5rem;
            margin-bottom: 1.5rem;
            font-size: 1.5rem;
        }

        .summary-card {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: var(--shadow);
        }

        .summary-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .risk-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: bold;
            text-transform: uppercase;
            font-size: 0.8rem;
        }

        .risk-badge.baixo {
            background-color: var(--success-color);
            color: white;
        }

        .risk-badge.medio {
            background-color: var(--warning-color);
            color: white;
        }

        .risk-badge.alto {
            background-color: var(--danger-color);
            color: white;
        }

        .target-info {
            font-size: 1.2rem;
            margin-bottom: 1rem;
            padding: 1rem;
            background-color: var(--light-color);
            border-radius: 4px;
            word-break: break-all;
        }

        .analysis-summary {
            font-size: 1rem;
            line-height: 1.6;
        }

        .analysis-content {
            background-color: #f8f9fa;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            padding: 1.5rem;
            overflow-x: auto;
        }

        .analysis-content pre {
            font-family: 'Courier New', monospace;
            font-size: 0.9rem;
            line-height: 1.4;
            white-space: pre-wrap;
            word-wrap: break-word;
        }

        .recommendations-content {
            background-color: #e8f4fd;
            border-left: 4px solid var(--secondary-color);
            padding: 1.5rem;
            border-radius: 0 4px 4px 0;
        }

        .recommendations-content ul {
            list-style-type: none;
            padding-left: 0;
        }

        .recommendations-content li {
            margin-bottom: 0.8rem;
            padding-left: 1.5rem;
            position: relative;
        }

        .recommendations-content li:before {
            content: "💡";
            position: absolute;
            left: 0;
        }

        .metadata-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
        }

        .metadata-item {
            background-color: var(--light-color);
            padding: 1rem;
            border-radius: 4px;
            display: flex;
            flex-direction: column;
        }

        .metadata-label {
            font-weight: bold;
            color: var(--dark-color);
            margin-bottom: 0.5rem;
        }

        .metadata-value {
            font-family: monospace;
            background-color: white;
            padding: 0.5rem;
            border-radius: 2px;
            border: 1px solid var(--border-color);
        }

        .report-footer {
            background-color: var(--primary-color);
            color: white;
            padding: 2rem;
            text-align: center;
        }

        .footer-content p {
            margin-bottom: 0.5rem;
        }

        .disclaimer {
            font-size: 0.9rem;
            opacity: 0.8;
            margin-top: 1rem !important;
            padding-top: 1rem;
            border-top: 1px solid rgba(255,255,255,0.2);
        }

        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                text-align: center;
            }

            .header-content h1 {
                font-size: 2rem;
                margin-bottom: 1rem;
            }

            .report-content {
                padding: 1rem;
            }

            .metadata-grid {
                grid-template-columns: 1fr;
            }
        }

        .print-button {
            position: fixed;
            top: 20px;
            right: 20px;
            background-color: var(--secondary-color);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            box-shadow: var(--shadow);
            z-index: 1000;
        }

        .print-button:hover {
            background-color: var(--primary-color);
        }

        @media print {
            .print-button {
                display: none;
            }
            
            .container {
                box-shadow: none;
            }
            
            .report-header {
                background: var(--primary-color) !important;
            }
        }
EOF
}

# Obter JavaScript para o relatório
get_report_javascript() {
    cat << 'EOF'
        // Adicionar botão de impressão
        document.addEventListener('DOMContentLoaded', function() {
            const printButton = document.createElement('button');
            printButton.className = 'print-button';
            printButton.innerHTML = '🖨️ Imprimir';
            printButton.onclick = function() {
                window.print();
            };
            document.body.appendChild(printButton);

            // Adicionar funcionalidade de cópia para valores de metadados
            const metadataValues = document.querySelectorAll('.metadata-value');
            metadataValues.forEach(function(element) {
                element.style.cursor = 'pointer';
                element.title = 'Clique para copiar';
                element.addEventListener('click', function() {
                    navigator.clipboard.writeText(this.textContent).then(function() {
                        const original = element.textContent;
                        element.textContent = 'Copiado!';
                        setTimeout(function() {
                            element.textContent = original;
                        }, 1000);
                    });
                });
            });

            // Adicionar timestamp de visualização
            const viewTime = new Date().toLocaleString('pt-BR');
            const viewInfo = document.createElement('div');
            viewInfo.style.cssText = 'position: fixed; bottom: 10px; right: 10px; background: rgba(0,0,0,0.7); color: white; padding: 5px 10px; border-radius: 3px; font-size: 12px; z-index: 1000;';
            viewInfo.textContent = 'Visualizado em: ' + viewTime;
            document.body.appendChild(viewInfo);
        });
EOF
}

# Limpar códigos ANSI
clean_ansi_codes() {
    local text="$1"
    
    # Remover códigos ANSI de escape
    text=$(echo "$text" | sed -E 's/\x1B\[[0-9;]*[mK]//g')
    text=$(echo "$text" | sed -E 's/\033\[[0-9;]*[mK]//g')
    text=$(echo "$text" | tr -d '\033')
    
    echo "$text"
}

# Obter classe CSS baseada no risco
get_risk_class() {
    local risk_level="$1"
    
    case "$risk_level" in
        "ALTO") echo "alto" ;;
        "MÉDIO"|"MEDIO") echo "medio" ;;
        *) echo "baixo" ;;
    esac
}

# Gerar resumo executivo
generate_executive_summary() {
    local analysis_type="$1"
    local risk_level="$2"
    
    case "$analysis_type" in
        "Arquivo")
            case "$risk_level" in
                "ALTO")
                    echo "O arquivo analisado apresenta características de alto risco e pode representar uma ameaça à segurança. Recomenda-se não executar este arquivo e isolá-lo imediatamente."
                    ;;
                "MÉDIO"|"MEDIO")
                    echo "O arquivo analisado apresenta algumas características suspeitas que requerem atenção. Análise adicional é recomendada antes da execução."
                    ;;
                *)
                    echo "O arquivo analisado não apresenta ameaças óbvias, mas verificação adicional com ferramentas antivírus atualizadas é sempre recomendada."
                    ;;
            esac
            ;;
        "URL")
            case "$risk_level" in
                "ALTO")
                    echo "A URL analisada apresenta características de alto risco e pode ser maliciosa. Recomenda-se não acessar este endereço."
                    ;;
                "MÉDIO"|"MEDIO")
                    echo "A URL analisada apresenta algumas características suspeitas. Acesse com cautela e evite inserir informações pessoais."
                    ;;
                *)
                    echo "A URL analisada aparenta ser segura, mas sempre mantenha precauções básicas de segurança ao navegar."
                    ;;
            esac
            ;;
        *)
            echo "Análise concluída. Revise os detalhes abaixo para uma avaliação completa dos riscos identificados."
            ;;
    esac
}

# Gerar recomendações em HTML
generate_recommendations_html() {
    local analysis_type="$1"
    local risk_level="$2"
    
    echo "<ul>"
    
    case "$analysis_type" in
        "Arquivo")
            case "$risk_level" in
                "ALTO")
                    echo "<li>Isole o arquivo em quarentena imediatamente</li>"
                    echo "<li>Execute análise em ambiente sandbox</li>"
                    echo "<li>Verifique outros arquivos do mesmo diretório</li>"
                    echo "<li>Execute varredura completa do sistema</li>"
                    ;;
                "MÉDIO"|"MEDIO")
                    echo "<li>Analise com antivírus atualizado</li>"
                    echo "<li>Verifique a origem e integridade do arquivo</li>"
                    echo "<li>Execute em ambiente isolado se necessário</li>"
                    ;;
                *)
                    echo "<li>Mantenha antivírus sempre atualizado</li>"
                    echo "<li>Monitore comportamento se executado</li>"
                    echo "<li>Verifique assinatura digital quando disponível</li>"
                    ;;
            esac
            ;;
        "URL")
            case "$risk_level" in
                "ALTO")
                    echo "<li>NÃO acesse esta URL</li>"
                    echo "<li>Bloqueie o domínio em seu firewall</li>"
                    echo "<li>Relate como site malicioso às autoridades</li>"
                    ;;
                "MÉDIO"|"MEDIO")
                    echo "<li>Use navegador com proteção ativa</li>"
                    echo "<li>Não insira informações pessoais</li>"
                    echo "<li>Verifique certificado SSL</li>"
                    ;;
                *)
                    echo "<li>Mantenha navegador atualizado</li>"
                    echo "<li>Use HTTPS sempre que possível</li>"
                    echo "<li>Instale extensões de segurança</li>"
                    ;;
            esac
            ;;
    esac
    
    # Recomendações gerais
    echo "<li>Mantenha backups atualizados de dados importantes</li>"
    echo "<li>Use autenticação de dois fatores quando disponível</li>"
    echo "<li>Monitore atividades suspeitas no sistema</li>"
    
    echo "</ul>"
}

# Abrir relatório no navegador de forma controlada
open_report_controlled() {
    local report_file="$1"
    
    if [[ ! -f "$report_file" ]]; then
        log_error "Arquivo de relatório não encontrado: $report_file" "REPORT_GEN"
        return 1
    fi
    
    log_info "Abrindo relatório: $(basename "$report_file")" "REPORT_GEN"
    
    # Iniciar servidor web temporário
    start_report_server "$report_file"
}

# Iniciar servidor web para relatórios
start_report_server() {
    local report_file="$1"
    local report_name=$(basename "$report_file")
    
    # Verificar se Python está disponível
    if command -v python3 &>/dev/null; then
        echo "🌐 Iniciando servidor web temporário..."
        echo "📄 Relatório: $report_name"
        echo "🔗 URL: http://$WEB_SERVER_HOST:$WEB_SERVER_PORT/$report_name"
        echo ""
        echo "Pressione Ctrl+C para parar o servidor"
        echo ""
        
        # Copiar relatório para diretório temporário se necessário
        local temp_dir=$(mktemp -d)
        cp "$report_file" "$temp_dir/"
        
        # Iniciar servidor Python
        cd "$temp_dir"
        python3 -m http.server $WEB_SERVER_PORT --bind $WEB_SERVER_HOST 2>/dev/null &
        local server_pid=$!
        
        # Aguardar servidor inicializar
        sleep 2
        
        # Tentar abrir no navegador
        local url="http://$WEB_SERVER_HOST:$WEB_SERVER_PORT/$report_name"
        
        if command -v xdg-open &>/dev/null; then
            xdg-open "$url" 2>/dev/null
        elif command -v open &>/dev/null; then
            open "$url" 2>/dev/null
        else
            echo "Abra manualmente: $url"
        fi
        
        # Aguardar entrada do usuário
        echo "Pressione ENTER para parar o servidor..."
        read -r
        
        # Parar servidor
        kill $server_pid 2>/dev/null
        rm -rf "$temp_dir"
        
        log_info "Servidor web parado" "REPORT_GEN"
    else
        echo "Python3 não disponível. Abrindo arquivo diretamente..."
        
        if command -v xdg-open &>/dev/null; then
            xdg-open "$report_file"
        elif command -v open &>/dev/null; then
            open "$report_file"
        else
            echo "Abra manualmente: $report_file"
        fi
    fi
}

# Listar relatórios disponíveis
list_reports() {
    echo "📋 RELATÓRIOS DISPONÍVEIS"
    echo "========================"
    
    if [[ ! -d "$REPORTS_DIR" ]]; then
        echo "Nenhum relatório encontrado."
        return 1
    fi
    
    local reports=($(find "$REPORTS_DIR" -name "*.html" -type f 2>/dev/null | sort -r))
    
    if [[ ${#reports[@]} -eq 0 ]]; then
        echo "Nenhum relatório encontrado."
        return 1
    fi
    
    local count=1
    for report in "${reports[@]}"; do
        local report_name=$(basename "$report")
        local report_date=$(stat -c %y "$report" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
        local report_size=$(stat -c %s "$report" 2>/dev/null)
        local size_kb=$((report_size / 1024))
        
        printf "%2d. %s\n" "$count" "$report_name"
        printf "    Data: %s | Tamanho: %dKB\n" "$report_date" "$size_kb"
        printf "    Caminho: %s\n\n" "$report"
        
        count=$((count + 1))
    done
    
    echo "Total: $((count - 1)) relatórios"
}

# Limpar relatórios antigos
cleanup_old_reports() {
    if [[ -d "$REPORTS_DIR" ]]; then
        local deleted_count=0
        
        # Remover relatórios mais antigos que REPORTS_RETENTION_DAYS
        while IFS= read -r -d '' report; do
            rm "$report"
            deleted_count=$((deleted_count + 1))
        done < <(find "$REPORTS_DIR" -name "*.html" -type f -mtime +$REPORTS_RETENTION_DAYS -print0 2>/dev/null)
        
        if [[ $deleted_count -gt 0 ]]; then
            log_info "Removidos $deleted_count relatórios antigos" "REPORT_GEN"
            echo "🗑️  Removidos $deleted_count relatórios antigos"
        else
            echo "✅ Nenhum relatório antigo para remover"
        fi
    fi
}
