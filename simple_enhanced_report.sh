#!/bin/bash

# Script para gerar e exibir relatórios aprimorados

# Função para gerar e exibir relatório aprimorado
generate_and_show_report() {
    local analysis_type="$1"
    local target="$2"
    local log_file="$3"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    # Garantir que o diretório de relatórios existe
    mkdir -p "$HOME/.security_analyzer/reports"
    local report_dir="$HOME/.security_analyzer/reports"
    local report_file="$report_dir/report_$(date '+%Y%m%d_%H%M%S').html"
    
    # Ler o conteúdo do log
    local log_content=$(cat "$log_file" | tail -n 50)
    
    # Determinar o nível de risco com base no conteúdo do log
    local risk_level="Baixo"
    local risk_color="#28a745"
    local risk_emoji="✅"
    
    # Verificar indicadores de malware/phishing/ameaças
    if echo "$log_content" | grep -qi "malware\|phishing\|suspicious\|malicious\|threat\|ameaça\|suspeito"; then
        risk_level="Médio"
        risk_color="#f9c513"
        risk_emoji="⚠️"
    fi
    
    if echo "$log_content" | grep -qi "AMEAÇA DETECTADA\|THREAT DETECTED\|malicious\|malicioso"; then
        risk_level="Alto"
        risk_color="#d73a49"
        risk_emoji="🚨"
    fi
    
    # Extrair IOCs (Indicadores de Compromisso)
    local ips=$(echo "$log_content" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u | head -5)
    local domains=$(echo "$log_content" | grep -oE '\b[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b' | sort -u | head -5)
    local emails=$(echo "$log_content" | grep -oE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' | sort -u | head -5)
    
    # Criar recomendações com base no tipo de análise
    local recommendations=""
    case "$analysis_type" in
        "Análise de Arquivo")
            recommendations="<li>Verifique a assinatura digital do arquivo</li>
<li>Execute o arquivo em um ambiente sandbox antes de usá-lo em produção</li>
<li>Mantenha seu antivírus atualizado</li>"
            ;;
        "Análise de URL")
            recommendations="<li>Verifique se o site utiliza HTTPS</li>
<li>Confirme a legitimidade do domínio antes de inserir informações sensíveis</li>
<li>Utilize ferramentas de proteção contra phishing</li>"
            ;;
        "Análise de Domínio")
            recommendations="<li>Verifique a data de criação do domínio (domínios recentes podem ser suspeitos)</li>
<li>Confirme se o domínio possui registros SPF, DKIM e DMARC válidos</li>
<li>Monitore o domínio para alterações suspeitas</li>"
            ;;
        "Análise de Email")
            recommendations="<li>Verifique o remetente antes de abrir anexos ou clicar em links</li>
<li>Não compartilhe informações sensíveis via email sem confirmar a identidade do solicitante</li>
<li>Utilize filtros de spam e anti-phishing</li>"
            ;;
        "Análise de Hash")
            recommendations="<li>Compare o hash com bases de dados de malware conhecidos</li>
<li>Verifique a integridade do arquivo original</li>
<li>Utilize ferramentas de análise de malware para arquivos suspeitos</li>"
            ;;
        "Análise de Cabeçalho de Email")
            recommendations="<li>Verifique a autenticidade do email através dos registros SPF, DKIM e DMARC</li>
<li>Analise o caminho de roteamento do email para identificar servidores suspeitos</li>
<li>Procure por inconsistências nos cabeçalhos que possam indicar spoofing</li>"
            ;;
        *)
            recommendations="<li>Mantenha seu software e sistemas operacionais atualizados</li>
<li>Utilize software antivírus e mantenha-o atualizado</li>
<li>Pratique bons hábitos de segurança digital</li>"
            ;;
    esac
    
    # Criar tabela de IOCs
    local iocs_table=""
    
    # Adicionar IPs encontrados
    if [ -n "$ips" ]; then
        iocs_table+="<h4>Endereços IP</h4>
<table>
  <tr>
    <th>IP</th>
    <th>Reputação</th>
  </tr>"
        
        while read -r ip; do
            if echo "$log_content" | grep -q "malicious.*$ip\|suspicious.*$ip"; then
                iocs_table+="
  <tr>
    <td>$ip</td>
    <td>⚠️ Suspeito</td>
  </tr>"
            else
                iocs_table+="
  <tr>
    <td>$ip</td>
    <td>✅ Não conhecido como malicioso</td>
  </tr>"
            fi
        done <<< "$ips"
        
        iocs_table+="
</table>"
    fi
    
    # Adicionar domínios encontrados
    if [ -n "$domains" ]; then
        iocs_table+="<h4>Domínios</h4>
<table>
  <tr>
    <th>Domínio</th>
    <th>Reputação</th>
  </tr>"
        
        while read -r domain; do
            if echo "$log_content" | grep -q "malicious.*$domain\|suspicious.*$domain"; then
                iocs_table+="
  <tr>
    <td>$domain</td>
    <td>⚠️ Suspeito</td>
  </tr>"
            else
                iocs_table+="
  <tr>
    <td>$domain</td>
    <td>✅ Não conhecido como malicioso</td>
  </tr>"
            fi
        done <<< "$domains"
        
        iocs_table+="
</table>"
    fi
    
    # Adicionar emails encontrados
    if [ -n "$emails" ]; then
        iocs_table+="<h4>Endereços de Email</h4>
<table>
  <tr>
    <th>Email</th>
    <th>Reputação</th>
  </tr>"
        
        while read -r email; do
            if echo "$log_content" | grep -q "malicious.*$email\|suspicious.*$email\|phishing.*$email"; then
                iocs_table+="
  <tr>
    <td>$email</td>
    <td>⚠️ Suspeito</td>
  </tr>"
            else
                iocs_table+="
  <tr>
    <td>$email</td>
    <td>✅ Não conhecido como malicioso</td>
  </tr>"
            fi
        done <<< "$emails"
        
        iocs_table+="
</table>"
    fi
    
    # Criar o relatório HTML
    cat > "$report_file" << EOL
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório de Segurança</title>
    <style>
        :root {
            --primary-color: #0366d6;
            --secondary-color: #f6f8fa;
            --text-color: #24292e;
            --border-color: #e1e4e8;
            --success-color: #28a745;
            --warning-color: #f9c513;
            --danger-color: #d73a49;
            --critical-color: #cb2431;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            max-width: 1100px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f8f9fa;
        }
        
        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 30px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .header h1 {
            color: var(--primary-color);
            margin-bottom: 10px;
        }
        
        .header img {
            width: 80px;
            height: auto;
            margin-bottom: 15px;
        }
        
        .summary-box {
            background-color: var(--secondary-color);
            border-left: 4px solid ${risk_color};
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .risk-level {
            color: ${risk_color};
            font-weight: bold;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        
        table th, table td {
            padding: 12px 15px;
            border: 1px solid var(--border-color);
        }
        
        table th {
            background-color: var(--secondary-color);
            font-weight: bold;
        }
        
        table tr:nth-child(even) {
            background-color: #f8f8f8;
        }
        
        .recommendations {
            background-color: #f0f7ff;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
        }
        
        .recommendations h2 {
            color: var(--primary-color);
            margin-top: 0;
        }
        
        .log-section {
            background-color: #f6f8fa;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
            overflow-x: auto;
        }
        
        .log-content {
            font-family: monospace;
            white-space: pre-wrap;
            font-size: 14px;
        }
        
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid var(--border-color);
            color: #666;
            font-size: 0.9em;
        }
        
        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin: 20px 0;
        }
        
        .action-button {
            padding: 8px 16px;
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .action-button:hover {
            opacity: 0.9;
        }
        
        @media print {
            body {
                padding: 0;
                background-color: white;
            }
            
            .container {
                box-shadow: none;
                padding: 0;
            }
            
            .action-buttons {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <img src="https://cdn-icons-png.flaticon.com/512/2092/2092757.png" alt="Security Icon">
            <h1>Relatório de Análise de Segurança</h1>
            <p>Gerado em: $timestamp</p>
        </div>
        
        <div class="action-buttons">
            <button class="action-button" onclick="window.print()">Imprimir Relatório</button>
        </div>
        
        <h2>Resumo da Análise</h2>
        
        <div class="summary-box">
            <h3>${risk_emoji} Nível de Risco: <span class="risk-level">$risk_level</span></h3>
            <p><strong>Tipo de Análise:</strong> $analysis_type</p>
            <p><strong>Alvo:</strong> $target</p>
        </div>
        
        <h2>Indicadores de Compromisso (IOCs)</h2>
        
        $iocs_table
        
        <div class="recommendations">
            <h2>Recomendações de Segurança</h2>
            <ul>
                $recommendations
            </ul>
        </div>
        
        <h2>Log da Análise</h2>
        
        <div class="log-section">
            <pre class="log-content">$log_content</pre>
        </div>
        
        <div class="footer">
            <p>Relatório gerado pelo <strong>Security Analyzer Tool</strong></p>
            <p><small>Este relatório é apenas informativo e não substitui uma análise profissional de segurança.</small></p>
        </div>
    </div>
</body>
</html>
EOL
    
    # Determinar uma porta disponível
    local PORT=8000
    while nc -z localhost $PORT 2>/dev/null; do
        PORT=$((PORT+1))
    done
    
    echo -e "${GREEN}Abrindo relatório aprimorado no navegador...${NC}"
    echo -e "${GREEN}URL: http://localhost:$PORT/$(basename "$report_file")${NC}"
    
    # Iniciar servidor web em segundo plano
    (cd "$(dirname "$report_file")" && python3 -m http.server $PORT > /dev/null 2>&1 &)
    
    # Abrir navegador
    if command -v xdg-open > /dev/null; then
        xdg-open "http://localhost:$PORT/$(basename "$report_file")" > /dev/null 2>&1
    elif command -v open > /dev/null; then
        open "http://localhost:$PORT/$(basename "$report_file")" > /dev/null 2>&1
    else
        echo -e "${YELLOW}Não foi possível abrir o navegador automaticamente.${NC}"
        echo -e "${YELLOW}Acesse: http://localhost:$PORT/$(basename "$report_file")${NC}"
    fi
}
