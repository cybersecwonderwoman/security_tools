#!/bin/bash

# ========================================
# Enhanced Markdown Report Generator - Gerador Aprimorado de Relatórios em Markdown
# ========================================

# Função para gerar relatório aprimorado em Markdown
generate_enhanced_report() {
    local analysis_type="$1"
    local target="$2"
    local log_content="$3"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    # Garantir que o diretório de relatórios existe
    mkdir -p "$HOME/.security_analyzer/reports"
    local report_file="$HOME/.security_analyzer/reports/enhanced_report_$(date '+%Y%m%d_%H%M%S').md"
    
    # Determinar o nível de risco com base no conteúdo do log
    local risk_level="Baixo"
    local risk_color="green"
    local risk_emoji="✅"
    local recommendations=()
    local malicious_indicators=0
    
    # Verificar indicadores de malware/phishing/ameaças
    if echo "$log_content" | grep -qi "malware\|phishing\|suspicious\|malicious\|threat\|ameaça\|suspeito"; then
        risk_level="Médio"
        risk_color="orange"
        risk_emoji="⚠️"
        malicious_indicators=$((malicious_indicators + 1))
        recommendations+=("- Recomendamos análise adicional para confirmar a natureza da ameaça")
        recommendations+=("- Considere isolar o sistema/arquivo até que uma análise completa seja realizada")
    fi
    
    if echo "$log_content" | grep -qi "AMEAÇA DETECTADA\|THREAT DETECTED\|malicious\|malicioso"; then
        risk_level="Alto"
        risk_color="red"
        risk_emoji="🚨"
        malicious_indicators=$((malicious_indicators + 2))
        recommendations+=("- Bloqueie imediatamente o acesso ao recurso identificado")
        recommendations+=("- Execute uma varredura completa do sistema")
        recommendations+=("- Verifique outros sistemas que possam ter sido expostos")
    fi
    
    # Verificar tipo específico de análise para recomendações personalizadas
    case "$analysis_type" in
        "Análise de Arquivo")
            if echo "$log_content" | grep -qi "executable\|executável\|.exe\|.dll\|.bat"; then
                recommendations+=("- Analise o arquivo executável em um ambiente sandbox antes de executá-lo")
                recommendations+=("- Verifique a assinatura digital do arquivo")
            fi
            ;;
        "Análise de URL")
            recommendations+=("- Verifique se o site utiliza HTTPS")
            recommendations+=("- Confirme a legitimidade do domínio antes de inserir informações sensíveis")
            if echo "$log_content" | grep -qi "phishing\|malicious\|malware"; then
                recommendations+=("- Não acesse esta URL, ela pode conter conteúdo malicioso")
                recommendations+=("- Reporte a URL para o Google Safe Browsing ou Microsoft SmartScreen")
            fi
            ;;
        "Análise de Domínio")
            recommendations+=("- Verifique a data de criação do domínio (domínios recentes podem ser suspeitos)")
            recommendations+=("- Confirme se o domínio possui registros SPF, DKIM e DMARC válidos")
            ;;
        "Análise de Email")
            recommendations+=("- Verifique o remetente antes de abrir anexos ou clicar em links")
            recommendations+=("- Não compartilhe informações sensíveis via email sem confirmar a identidade do solicitante")
            if echo "$log_content" | grep -qi "spoofing\|phishing\|spam"; then
                recommendations+=("- Este email apresenta características de phishing/spoofing")
                recommendations+=("- Não clique em links ou baixe anexos deste email")
            fi
            ;;
        "Análise de Hash")
            if echo "$log_content" | grep -qi "malicious\|malware\|virus\|trojan"; then
                recommendations+=("- Este hash está associado a software malicioso conhecido")
                recommendations+=("- Remova imediatamente o arquivo correspondente do sistema")
            else
                recommendations+=("- Nenhuma ameaça conhecida associada a este hash")
            fi
            ;;
        "Análise de Cabeçalho de Email")
            if echo "$log_content" | grep -qi "SPF.*fail\|DKIM.*fail\|DMARC.*fail"; then
                recommendations+=("- Email falhou em verificações de autenticidade (SPF/DKIM/DMARC)")
                recommendations+=("- Trate este email com extrema cautela")
            fi
            ;;
    esac
    
    # Adicionar recomendações padrão se nenhuma específica foi adicionada
    if [ ${#recommendations[@]} -eq 0 ]; then
        recommendations+=("- Mantenha seu software e sistemas operacionais atualizados")
        recommendations+=("- Utilize software antivírus e mantenha-o atualizado")
        recommendations+=("- Pratique bons hábitos de segurança digital")
    fi
    
    # Ajustar nível de risco com base no número de indicadores maliciosos
    if [ $malicious_indicators -gt 3 ]; then
        risk_level="Crítico"
        risk_color="darkred"
        risk_emoji="☠️"
    fi
    
    # Extrair IOCs (Indicadores de Compromisso)
    local ips=$(echo "$log_content" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u | head -5)
    local domains=$(echo "$log_content" | grep -oE '\b[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b' | sort -u | head -5)
    local emails=$(echo "$log_content" | grep -oE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' | sort -u | head -5)
    local hashes=$(echo "$log_content" | grep -oE '\b[a-fA-F0-9]{32,64}\b' | sort -u | head -5)
    
    # Criar conteúdo do relatório
    cat > "$report_file" << EOL
# Relatório de Análise de Segurança

<div style="text-align: center; margin-bottom: 30px;">
  <img src="https://cdn-icons-png.flaticon.com/512/2092/2092757.png" alt="Security Icon" style="width: 100px; height: auto;">
  <h2>Security Analyzer Tool</h2>
  <p><em>Relatório gerado em: $timestamp</em></p>
</div>

## Resumo da Análise

<div style="padding: 15px; border-left: 4px solid ${risk_color}; background-color: #f8f8f8; margin-bottom: 20px;">
  <h3>${risk_emoji} Nível de Risco: <span style="color: ${risk_color};">${risk_level}</span></h3>
  <p><strong>Tipo de Análise:</strong> ${analysis_type}</p>
  <p><strong>Alvo:</strong> ${target}</p>
  <p><strong>Indicadores de Malware/Ameaças:</strong> ${malicious_indicators}</p>
</div>

## Detalhes da Análise

### Indicadores de Compromisso (IOCs)

EOL

    # Adicionar IPs encontrados
    if [ -n "$ips" ]; then
        cat >> "$report_file" << EOL
#### Endereços IP

| IP | Reputação |
|-----|-----------|
EOL
        echo "$ips" | while read -r ip; do
            if echo "$log_content" | grep -q "malicious.*$ip\|suspicious.*$ip"; then
                echo "| $ip | ⚠️ Suspeito |" >> "$report_file"
            else
                echo "| $ip | ✅ Não conhecido como malicioso |" >> "$report_file"
            fi
        done
    fi

    # Adicionar domínios encontrados
    if [ -n "$domains" ]; then
        cat >> "$report_file" << EOL

#### Domínios

| Domínio | Reputação |
|---------|-----------|
EOL
        echo "$domains" | while read -r domain; do
            if echo "$log_content" | grep -q "malicious.*$domain\|suspicious.*$domain"; then
                echo "| $domain | ⚠️ Suspeito |" >> "$report_file"
            else
                echo "| $domain | ✅ Não conhecido como malicioso |" >> "$report_file"
            fi
        done
    fi

    # Adicionar emails encontrados
    if [ -n "$emails" ]; then
        cat >> "$report_file" << EOL

#### Endereços de Email

| Email | Reputação |
|-------|-----------|
EOL
        echo "$emails" | while read -r email; do
            if echo "$log_content" | grep -q "malicious.*$email\|suspicious.*$email\|phishing.*$email"; then
                echo "| $email | ⚠️ Suspeito |" >> "$report_file"
            else
                echo "| $email | ✅ Não conhecido como malicioso |" >> "$report_file"
            fi
        done
    fi

    # Adicionar hashes encontrados
    if [ -n "$hashes" ]; then
        cat >> "$report_file" << EOL

#### Hashes

| Hash | Tipo | Reputação |
|------|------|-----------|
EOL
        echo "$hashes" | while read -r hash; do
            local hash_type=""
            case ${#hash} in
                32) hash_type="MD5" ;;
                40) hash_type="SHA1" ;;
                64) hash_type="SHA256" ;;
                *) hash_type="Desconhecido" ;;
            esac
            
            if echo "$log_content" | grep -q "malicious.*$hash\|suspicious.*$hash"; then
                echo "| $hash | $hash_type | ⚠️ Suspeito |" >> "$report_file"
            else
                echo "| $hash | $hash_type | ✅ Não conhecido como malicioso |" >> "$report_file"
            fi
        done
    fi

    # Adicionar recomendações
    cat >> "$report_file" << EOL

## Recomendações de Segurança

EOL

    for recommendation in "${recommendations[@]}"; do
        echo "$recommendation" >> "$report_file"
    done

    # Adicionar log completo
    cat >> "$report_file" << EOL

## Log Completo da Análise

\`\`\`
$log_content
\`\`\`

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>Relatório gerado pelo <strong>Security Analyzer Tool</strong></p>
  <p><small>Este relatório é apenas informativo e não substitui uma análise profissional de segurança.</small></p>
</div>
EOL
    
    echo "$report_file"
}

# Função para abrir relatório no navegador com design aprimorado
open_enhanced_report_in_browser() {
    local report_file="$1"
    local html_file="${report_file%.md}.html"
    
    # Converter Markdown para HTML com design aprimorado
    cat > "$html_file" << EOL
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório de Segurança</title>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
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
        
        .markdown-body {
            box-sizing: border-box;
            min-width: 200px;
            max-width: 100%;
            margin: 0 auto;
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
        
        .risk-low {
            color: var(--success-color);
            font-weight: bold;
        }
        
        .risk-medium {
            color: var(--warning-color);
            font-weight: bold;
        }
        
        .risk-high {
            color: var(--danger-color);
            font-weight: bold;
        }
        
        .risk-critical {
            color: var(--critical-color);
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .summary-box {
            background-color: var(--secondary-color);
            border-left: 4px solid var(--primary-color);
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
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
        
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid var(--border-color);
            color: #666;
            font-size: 0.9em;
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
        }
        
        /* Estilos para os ícones */
        .icon-success {
            color: var(--success-color);
        }
        
        .icon-warning {
            color: var(--warning-color);
        }
        
        .icon-danger {
            color: var(--danger-color);
        }
        
        /* Botões de ação */
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
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .action-button:hover {
            opacity: 0.9;
        }
        
        .action-button.secondary {
            background-color: #6c757d;
        }
        
        .action-button.danger {
            background-color: var(--danger-color);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <img src="https://cdn-icons-png.flaticon.com/512/2092/2092757.png" alt="Security Icon">
            <h1>Relatório de Análise de Segurança</h1>
            <p>Gerado em: $(date '+%d/%m/%Y %H:%M:%S')</p>
        </div>
        
        <div class="action-buttons">
            <button class="action-button" onclick="window.print()">
                <i class="fas fa-print"></i> Imprimir Relatório
            </button>
            <button class="action-button secondary" onclick="downloadPDF()">
                <i class="fas fa-file-pdf"></i> Exportar como PDF
            </button>
        </div>
        
        <div id="content" class="markdown-body"></div>
        
        <div class="footer">
            <p>Relatório gerado pelo <strong>Security Analyzer Tool</strong></p>
            <p><small>Este relatório é apenas informativo e não substitui uma análise profissional de segurança.</small></p>
        </div>
    </div>

    <script>
        // Carregar o conteúdo do markdown
        fetch('$(basename "$report_file")')
            .then(response => response.text())
            .then(text => {
                document.getElementById('content').innerHTML = marked.parse(text);
                
                // Aplicar classes de risco
                applyStyles();
            });
            
        function applyStyles() {
            // Aplicar estilos após o markdown ser renderizado
            setTimeout(() => {
                // Estilizar tabelas
                const tables = document.querySelectorAll('table');
                tables.forEach(table => {
                    if (!table.classList.contains('styled')) {
                        table.classList.add('styled');
                    }
                });
                
                // Estilizar níveis de risco
                const riskElements = document.querySelectorAll('h3');
                riskElements.forEach(el => {
                    if (el.textContent.includes('Nível de Risco')) {
                        if (el.textContent.includes('Baixo')) {
                            el.querySelector('span').classList.add('risk-low');
                        } else if (el.textContent.includes('Médio')) {
                            el.querySelector('span').classList.add('risk-medium');
                        } else if (el.textContent.includes('Alto')) {
                            el.querySelector('span').classList.add('risk-high');
                        } else if (el.textContent.includes('Crítico')) {
                            el.querySelector('span').classList.add('risk-critical');
                        }
                    }
                });
                
                // Estilizar seção de recomendações
                const h2Elements = document.querySelectorAll('h2');
                h2Elements.forEach(h2 => {
                    if (h2.textContent.includes('Recomendações')) {
                        const nextElement = h2.nextElementSibling;
                        const recommendationsDiv = document.createElement('div');
                        recommendationsDiv.className = 'recommendations';
                        
                        // Mover o h2 e todos os elementos até o próximo h2 para dentro da div
                        const parent = h2.parentNode;
                        let currentElement = h2;
                        let nextH2Found = false;
                        
                        while (currentElement && !nextH2Found) {
                            const nextSibling = currentElement.nextElementSibling;
                            if (currentElement.tagName === 'H2' && currentElement !== h2) {
                                nextH2Found = true;
                            } else {
                                recommendationsDiv.appendChild(currentElement);
                                currentElement = nextSibling;
                            }
                        }
                        
                        if (nextH2Found) {
                            parent.insertBefore(recommendationsDiv, currentElement);
                        } else {
                            parent.appendChild(recommendationsDiv);
                        }
                    }
                });
            }, 100);
        }
        
        function downloadPDF() {
            alert("Funcionalidade de exportação para PDF será implementada em uma versão futura.");
            // Em uma implementação real, usaríamos uma biblioteca como jsPDF ou html2pdf
        }
    </script>
    
    <!-- Adicionar Font Awesome para ícones -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/js/all.min.js"></script>
</body>
</html>
EOL
    
    # Determinar uma porta disponível
    local PORT=8000
    while nc -z localhost $PORT 2>/dev/null; do
        PORT=$((PORT+1))
    done
    
    echo -e "${GREEN}Abrindo relatório aprimorado no navegador...${NC}"
    echo -e "${GREEN}URL: http://localhost:$PORT/${html_file##*/}${NC}"
    
    # Iniciar servidor web em segundo plano
    (cd "$(dirname "$html_file")" && python3 -m http.server $PORT > /dev/null 2>&1 &)
    
    # Abrir navegador
    if command -v xdg-open > /dev/null; then
        xdg-open "http://localhost:$PORT/${html_file##*/}" > /dev/null 2>&1
    elif command -v open > /dev/null; then
        open "http://localhost:$PORT/${html_file##*/}" > /dev/null 2>&1
    else
        echo -e "${YELLOW}Não foi possível abrir o navegador automaticamente.${NC}"
        echo -e "${YELLOW}Acesse: http://localhost:$PORT/${html_file##*/}${NC}"
    fi
}
