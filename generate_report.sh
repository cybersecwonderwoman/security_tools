#!/bin/bash

# Script para gerar relatórios HTML a partir dos logs de análise

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Verificar argumentos
if [ $# -lt 3 ]; then
    echo "Uso: $0 <tipo_analise> <alvo> <arquivo_log>"
    exit 1
fi

# Parâmetros
ANALYSIS_TYPE="$1"
TARGET="$2"
LOG_FILE="$3"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

# Garantir que o diretório de relatórios existe
mkdir -p "$HOME/.security_analyzer/reports"
REPORT_DIR="$HOME/.security_analyzer/reports"
REPORT_FILE="$REPORT_DIR/report_$(date '+%Y%m%d_%H%M%S').html"

# Ler o conteúdo do log
LOG_CONTENT=$(cat "$LOG_FILE" | tail -n 50)

# Determinar o nível de risco com base no conteúdo do log
RISK_LEVEL="Baixo"
RISK_COLOR="#28a745"
RISK_EMOJI="✅"

# Verificar indicadores de malware/phishing/ameaças
if echo "$LOG_CONTENT" | grep -qi "malware\|phishing\|suspicious\|malicious\|threat\|ameaça\|suspeito"; then
    RISK_LEVEL="Médio"
    RISK_COLOR="#f9c513"
    RISK_EMOJI="⚠️"
fi

if echo "$LOG_CONTENT" | grep -qi "AMEAÇA DETECTADA\|THREAT DETECTED\|malicious\|malicioso"; then
    RISK_LEVEL="Alto"
    RISK_COLOR="#d73a49"
    RISK_EMOJI="🚨"
fi

# Extrair IOCs (Indicadores de Compromisso)
# Extrair informações específicas para análise de IP
if [ "$ANALYSIS_TYPE" = "Análise de IP" ]; then
    # Verificar se há informações de geolocalização no log
    IP_COUNTRY=$(echo "$LOG_CONTENT" | grep -o "País: [A-Za-z ]*" | head -1 | cut -d" " -f2-)
    IP_ORG=$(echo "$LOG_CONTENT" | grep -o "Organização: [^\n]*" | head -1 | cut -d" " -f2-)
    
    # Verificar se há informações de risco no log
    RISK_SCORE=$(echo "$LOG_CONTENT" | grep -o "Pontuação de Risco: [0-9]*" | head -1 | cut -d" " -f4)
    
    # Ajustar nível de risco com base na pontuação específica de IP
    if [ -n "$RISK_SCORE" ] && [ "$RISK_SCORE" -ge 50 ] 2>/dev/null; then
        RISK_LEVEL="Alto"
        RISK_COLOR="#d73a49"
        RISK_EMOJI="🚨"
    elif [ -n "$RISK_SCORE" ] && [ "$RISK_SCORE" -ge 20 ] 2>/dev/null; then
        RISK_LEVEL="Médio"
        RISK_COLOR="#f9c513"
        RISK_EMOJI="⚠️"
    fi
    
    # Extrair fatores de risco
    IP_RISK_FACTORS=$(echo "$LOG_CONTENT" | grep -A 10 "Fatores de risco identificados:" | grep "^  - " | sed "s/^  - //")
    if [ -n "$IP_RISK_FACTORS" ]; then
        IP_RISK_FACTORS_HTML="<h4>Fatores de Risco Identificados</h4><ul>"
        while IFS= read -r line; do
            IP_RISK_FACTORS_HTML+="<li>$line</li>"
        done <<< "$IP_RISK_FACTORS"
        IP_RISK_FACTORS_HTML+="</ul>"
    fi
fi
IPS=$(echo "$LOG_CONTENT" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u | head -5)
DOMAINS=$(echo "$LOG_CONTENT" | grep -oE '\b[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b' | sort -u | head -5)
EMAILS=$(echo "$LOG_CONTENT" | grep -oE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' | sort -u | head -5)

# Criar recomendações com base no tipo de análise
RECOMMENDATIONS=""
case "$ANALYSIS_TYPE" in
    "Análise de Arquivo")
        RECOMMENDATIONS="<li>Verifique a assinatura digital do arquivo</li>
<li>Execute o arquivo em um ambiente sandbox antes de usá-lo em produção</li>
<li>Mantenha seu antivírus atualizado</li>"
        ;;
    "Análise de URL")
        RECOMMENDATIONS="<li>Verifique se o site utiliza HTTPS</li>
<li>Confirme a legitimidade do domínio antes de inserir informações sensíveis</li>
<li>Utilize ferramentas de proteção contra phishing</li>"
        ;;
    "Análise de Domínio")
        RECOMMENDATIONS="<li>Verifique a data de criação do domínio (domínios recentes podem ser suspeitos)</li>
<li>Confirme se o domínio possui registros SPF, DKIM e DMARC válidos</li>
<li>Monitore o domínio para alterações suspeitas</li>"
        ;;
    "Análise de Email")
        RECOMMENDATIONS="<li>Verifique o remetente antes de abrir anexos ou clicar em links</li>
<li>Não compartilhe informações sensíveis via email sem confirmar a identidade do solicitante</li>
<li>Utilize filtros de spam e anti-phishing</li>"
        ;;
    "Análise de Hash")
        RECOMMENDATIONS="<li>Compare o hash com bases de dados de malware conhecidos</li>
<li>Verifique a integridade do arquivo original</li>
<li>Utilize ferramentas de análise de malware para arquivos suspeitos</li>"
        ;;
    "Análise de Cabeçalho de Email")
        ;;
    "Análise de IP")
        RECOMMENDATIONS="<li>Verifique se o IP está em listas de bloqueio (RBLs)</li>
<li>Monitore o tráfego de e para este IP</li>
<li>Se o IP for malicioso, considere bloqueá-lo em seu firewall</li>
<li>Verifique logs de acesso para atividades suspeitas deste IP</li>"
        RECOMMENDATIONS="<li>Verifique a autenticidade do email através dos registros SPF, DKIM e DMARC</li>
<li>Analise o caminho de roteamento do email para identificar servidores suspeitos</li>
<li>Procure por inconsistências nos cabeçalhos que possam indicar spoofing</li>"
        ;;
    *)
        RECOMMENDATIONS="<li>Mantenha seu software e sistemas operacionais atualizados</li>
<li>Utilize software antivírus e mantenha-o atualizado</li>
<li>Pratique bons hábitos de segurança digital</li>"
        ;;
esac

# Criar tabela de IOCs
IOCS_TABLE=""

# Adicionar IPs encontrados
if [ -n "$IPS" ]; then
    IOCS_TABLE+="<h4>Endereços IP</h4>
<table>
  <tr>
    <th>IP</th>
    <th>Reputação</th>
  </tr>"
    
    while read -r ip; do
        if echo "$LOG_CONTENT" | grep -q "malicious.*$ip\|suspicious.*$ip"; then
            IOCS_TABLE+="
  <tr>
    <td>$ip</td>
    <td>⚠️ Suspeito</td>
  </tr>"
        else
            IOCS_TABLE+="
  <tr>
    <td>$ip</td>
    <td>✅ Não conhecido como malicioso</td>
  </tr>"
        fi
    done <<< "$IPS"
    
    IOCS_TABLE+="
</table>"
fi

# Adicionar domínios encontrados
if [ -n "$DOMAINS" ]; then
    IOCS_TABLE+="<h4>Domínios</h4>
<table>
  <tr>
    <th>Domínio</th>
    <th>Reputação</th>
  </tr>"
    
    while read -r domain; do
        if echo "$LOG_CONTENT" | grep -q "malicious.*$domain\|suspicious.*$domain"; then
            IOCS_TABLE+="
  <tr>
    <td>$domain</td>
    <td>⚠️ Suspeito</td>
  </tr>"
        else
            IOCS_TABLE+="
  <tr>
    <td>$domain</td>
    <td>✅ Não conhecido como malicioso</td>
  </tr>"
        fi
    done <<< "$DOMAINS"
    
    IOCS_TABLE+="
</table>"
fi

# Adicionar emails encontrados
if [ -n "$EMAILS" ]; then
    IOCS_TABLE+="<h4>Endereços de Email</h4>
<table>
  <tr>
    <th>Email</th>
    <th>Reputação</th>
  </tr>"
    
    while read -r email; do
        if echo "$LOG_CONTENT" | grep -q "malicious.*$email\|suspicious.*$email\|phishing.*$email"; then
            IOCS_TABLE+="
  <tr>
    <td>$email</td>
    <td>⚠️ Suspeito</td>
  </tr>"
        else
            IOCS_TABLE+="
  <tr>
    <td>$email</td>
    <td>✅ Não conhecido como malicioso</td>
  </tr>"
        fi
    done <<< "$EMAILS"
    
    IOCS_TABLE+="
</table>"
fi

# Criar o relatório HTML
cat > "$REPORT_FILE" << EOL
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
            <p>Gerado em: $TIMESTAMP</p>
        </div>
        
        <div class="action-buttons">
            <button class="action-button" onclick="window.print()">Imprimir Relatório</button>
        </div>
        
        <h2>Resumo da Análise</h2>
        
        <div class="summary-box">
        <!-- Informações específicas para análise de IP -->
        {% if [ "$ANALYSIS_TYPE" = "Análise de IP" ]; then %}
        <p><strong>País:</strong> ${IP_COUNTRY:-Desconhecido}</p>
        <p><strong>Organização:</strong> ${IP_ORG:-Desconhecida}</p>
        {% if [ -n "$RISK_SCORE" ]; then %}
        <p><strong>Pontuação de Risco:</strong> ${RISK_SCORE}/100</p>
        {% fi %}
        {% fi %}
            <h3>${RISK_EMOJI} Nível de Risco: <span class="risk-level">$RISK_LEVEL</span></h3>
            <p><strong>Tipo de Análise:</strong> $ANALYSIS_TYPE</p>
            <p><strong>Alvo:</strong> $TARGET</p>
        </div>
        
        <!-- Fatores de risco para análise de IP -->
        {% if [ "$ANALYSIS_TYPE" = "Análise de IP" ] && [ -n "$IP_RISK_FACTORS" ]; then %}
        <h2>Fatores de Risco Identificados</h2>
        <ul>
        {% echo "$IP_RISK_FACTORS" | while read -r factor; do %}
            <li>$factor</li>
        {% done %}
        </ul>
        {% fi %}
        
        <h2>Detalhes da Análise</h2>
        
        <div class="log-section">
            <h3>Log da Análise</h3>
            <pre class="log-content">$LOG_CONTENT</pre>
        </div>
        
        <div class="recommendations">
            <h2>Recomendações de Segurança</h2>
            <ul>
                <li>Mantenha seus sistemas atualizados</li>
                <li>Use antivírus atualizado</li>
                <li>Seja cauteloso com links e anexos suspeitos</li>
                <li>Verifique a autenticidade de emails antes de responder</li>
                <li>Monitore atividades suspeitas em sua rede</li>
            </ul>
        </div>
        
        <div class="footer">
            <p>Relatório gerado pelo <strong>Security Analyzer Tool</strong></p>
            <p><small>Este relatório é apenas informativo e não substitui uma análise profissional de segurança.</small></p>
            <p><small>Desenvolvido por @cybersecwonderwoman</small></p>
        </div>
    </div>
</body>
</html>
EOL

# Determinar uma porta disponível para o servidor web
PORT=8000
while nc -z localhost $PORT 2>/dev/null; do
    PORT=$((PORT+1))
done

echo ""
echo -e "${GREEN}Relatório gerado com sucesso!${NC}"
echo "Arquivo: $REPORT_FILE"
echo ""

# Verificar se python3 está disponível
if command -v python3 > /dev/null; then
    echo "Iniciando servidor web local..."
    echo "URL: http://localhost:$PORT/$(basename "$REPORT_FILE")"
    
    # Iniciar servidor web em segundo plano
    (cd "$(dirname "$REPORT_FILE")" && python3 -m http.server $PORT > /dev/null 2>&1 &)
    
    # Aguardar um momento para o servidor iniciar
    sleep 2
    
    # Abrir navegador
    if command -v xdg-open > /dev/null; then
        echo "Abrindo no navegador..."
        xdg-open "http://localhost:$PORT/$(basename "$REPORT_FILE")" > /dev/null 2>&1 &
    elif command -v open > /dev/null; then
        echo "Abrindo no navegador..."
        open "http://localhost:$PORT/$(basename "$REPORT_FILE")" > /dev/null 2>&1 &
    else
        echo "Não foi possível abrir o navegador automaticamente."
        echo "Abra manualmente: http://localhost:$PORT/$(basename "$REPORT_FILE")"
    fi
    
    echo ""
    echo -e "${YELLOW}Nota: O servidor web ficará ativo na porta $PORT${NC}"
    echo -e "${YELLOW}Para parar o servidor: pkill -f 'python3 -m http.server $PORT'${NC}"
else
    echo -e "${YELLOW}Python3 não encontrado. Abrindo arquivo diretamente...${NC}"
    
    # Tentar abrir o arquivo HTML diretamente
    if command -v xdg-open > /dev/null; then
        xdg-open "$REPORT_FILE" > /dev/null 2>&1 &
    elif command -v open > /dev/null; then
        open "$REPORT_FILE" > /dev/null 2>&1 &
    else
        echo "Não foi possível abrir o navegador automaticamente."
        echo "Abra manualmente: $REPORT_FILE"
    fi
fi
