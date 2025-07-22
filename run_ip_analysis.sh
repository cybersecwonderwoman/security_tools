#!/bin/bash

# Script para executar análise de IP

# Verificar se um IP foi fornecido
if [ $# -eq 0 ]; then
    echo "Uso: $0 <endereço_ip>"
    echo "Exemplo: $0 8.8.8.8"
    exit 1
fi

IP="$1"
LOG_FILE="/tmp/ip_analysis_$IP.log"

# Executar o script de análise de IP e salvar a saída no log
/home/anny-ribeiro/amazonQ/app/ip_analyzer_tool.sh "$IP" | tee "$LOG_FILE"

# Criar relatório HTML
REPORT_DIR="$HOME/.security_analyzer/reports"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/ip_report_$(date '+%Y%m%d_%H%M%S').html"

# Extrair informações do log
COUNTRY=$(grep "País:" "$LOG_FILE" | head -1 | cut -d':' -f2 | tr -d ' ')
REGION=$(grep "Região:" "$LOG_FILE" | head -1 | cut -d':' -f2 | tr -d ' ')
CITY=$(grep "Cidade:" "$LOG_FILE" | head -1 | cut -d':' -f2 | tr -d ' ')
ORG=$(grep "Organização:" "$LOG_FILE" | head -1 | cut -d':' -f2- | sed 's/^ *//')
RISK_SCORE=$(grep "Pontuação de Risco:" "$LOG_FILE" | head -1 | cut -d':' -f2 | tr -d ' ')
OPEN_PORTS=$(grep "Portas abertas:" "$LOG_FILE" | head -1 | cut -d':' -f2 | sed 's/^ *//')

# Determinar nível de risco
if [ -n "$RISK_SCORE" ] && [ "$RISK_SCORE" -ge 70 ]; then
    RISK_LEVEL="Alto"
    RISK_COLOR="#d73a49"
elif [ -n "$RISK_SCORE" ] && [ "$RISK_SCORE" -ge 30 ]; then
    RISK_LEVEL="Médio"
    RISK_COLOR="#f9c513"
else
    RISK_LEVEL="Baixo"
    RISK_COLOR="#28a745"
fi

# Criar o relatório HTML
cat > "$REPORT_FILE" << EOL
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório de Análise de IP</title>
    <style>
        :root {
            --primary-color: #0366d6;
            --secondary-color: #f6f8fa;
            --text-color: #24292e;
            --border-color: #e1e4e8;
            --success-color: #28a745;
            --warning-color: #f9c513;
            --danger-color: #d73a49;
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
            border-left: 4px solid ${RISK_COLOR};
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .risk-level {
            color: ${RISK_COLOR};
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
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <img src="https://cdn-icons-png.flaticon.com/512/2092/2092757.png" alt="Security Icon">
            <h1>Relatório de Análise de IP</h1>
            <p>Gerado em: $(date '+%d/%m/%Y %H:%M:%S')</p>
        </div>
        
        <div class="action-buttons">
            <button class="action-button" onclick="window.print()">Imprimir Relatório</button>
        </div>
        
        <h2>Resumo da Análise</h2>
        
        <div class="summary-box">
            <h3>Nível de Risco: <span class="risk-level">$RISK_LEVEL</span></h3>
            <p><strong>IP Analisado:</strong> $IP</p>
            <p><strong>Pontuação de Risco:</strong> $RISK_SCORE</p>
        </div>
        
        <h2>Informações Geográficas</h2>
        
        <table>
            <tr>
                <th>País</th>
                <td>$COUNTRY</td>
            </tr>
            <tr>
                <th>Região</th>
                <td>$REGION</td>
            </tr>
            <tr>
                <th>Cidade</th>
                <td>$CITY</td>
            </tr>
            <tr>
                <th>Organização</th>
                <td>$ORG</td>
            </tr>
        </table>
        
        <h2>Informações Técnicas</h2>
        
        <table>
            <tr>
                <th>Portas Abertas</th>
                <td>$OPEN_PORTS</td>
            </tr>
        </table>
        
        <div class="recommendations">
            <h2>Recomendações de Segurança</h2>
            <ul>
                <li>Verifique se o IP está em listas de bloqueio (RBLs)</li>
                <li>Monitore o tráfego de e para este IP</li>
                <li>Se o IP for malicioso, considere bloqueá-lo em seu firewall</li>
                <li>Verifique logs de acesso para atividades suspeitas deste IP</li>
            </ul>
        </div>
        
        <h2>Log da Análise</h2>
        
        <div class="log-section">
            <pre class="log-content">$(cat "$LOG_FILE")</pre>
        </div>
        
        <div class="footer">
            <p>Relatório gerado pelo <strong>IP Analyzer Tool</strong></p>
            <p><small>Este relatório é apenas informativo e não substitui uma análise profissional de segurança.</small></p>
        </div>
    </div>
</body>
</html>
EOL

# Determinar uma porta disponível
PORT=8000
while nc -z localhost $PORT 2>/dev/null; do
    PORT=$((PORT+1))
done

echo -e "\nAbrindo relatório no navegador..."
echo -e "URL: http://localhost:$PORT/$(basename "$REPORT_FILE")"

# Iniciar servidor web em segundo plano
(cd "$(dirname "$REPORT_FILE")" && python3 -m http.server $PORT > /dev/null 2>&1 &)

# Abrir navegador
if command -v xdg-open > /dev/null; then
    xdg-open "http://localhost:$PORT/$(basename "$REPORT_FILE")" > /dev/null 2>&1
elif command -v open > /dev/null; then
    open "http://localhost:$PORT/$(basename "$REPORT_FILE")" > /dev/null 2>&1
else
    echo "Não foi possível abrir o navegador automaticamente."
    echo "Acesse: http://localhost:$PORT/$(basename "$REPORT_FILE")"
fi

echo "Análise de IP concluída! Relatório gerado em: $REPORT_FILE"
