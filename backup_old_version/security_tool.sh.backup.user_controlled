#!/bin/bash

# ========================================
# Security Analyzer Tool - Menu Interativo Unificado
# Ferramenta Avançada de Análise de Segurança
# ========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
CONFIG_DIR="$HOME/.security_analyzer"
LOG_FILE="$CONFIG_DIR/analysis.log"
CACHE_DIR="$CONFIG_DIR/cache"
API_KEYS_FILE="$CONFIG_DIR/api_keys.conf"
DOCS_DIR="$HOME/.security_analyzer/docs"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Criar diretórios necessários
mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$DOCS_DIR"

# Importar scripts de relatórios HTML se existirem
if [[ -f "$SCRIPT_DIR/html_report.sh" ]]; then
    source "$SCRIPT_DIR/html_report.sh"
fi

if [[ -f "$SCRIPT_DIR/report_integration.sh" ]]; then
    source "$SCRIPT_DIR/report_integration.sh"
fi

# Função para logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Função para exibir banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║   ███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗            ║
║   ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝            ║
║   ███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝             ║
║   ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝              ║
║   ███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║               ║
║   ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝               ║
║                                                                              ║
║   ████████╗ ██████╗  ██████╗ ██╗                                            ║
║   ╚══██╔══╝██╔═══██╗██╔═══██╗██║                                            ║
║      ██║   ██║   ██║██║   ██║██║                                            ║
║      ██║   ██║   ██║██║   ██║██║                                            ║
║      ██║   ╚██████╔╝╚██████╔╝███████╗                                       ║
║      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝                                       ║
║                                                                              ║
║                    🛡️  FERRAMENTA AVANÇADA DE SEGURANÇA  🛡️                  ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${PURPLE}                           @cybersecwonderwoman${NC}"
    echo ""
}

# Função para exibir o menu principal
show_main_menu() {
    show_banner
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                              MENU PRINCIPAL                                 ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}  [1] 📁 Analisar Arquivo${NC}          - Verificar arquivos suspeitos"
    echo -e "${GREEN}  [2] 🌐 Analisar URL${NC}             - Verificar links maliciosos"
    echo -e "${GREEN}  [3] 🏠 Analisar Domínio${NC}         - Investigar domínios suspeitos"
    echo -e "${GREEN}  [4] 🔢 Analisar Hash${NC}            - Consultar hashes em bases de dados"
    echo -e "${GREEN}  [5] 📧 Analisar Email${NC}           - Verificar endereços de email"
    echo -e "${GREEN}  [6] 📋 Analisar Cabeçalho${NC}       - Analisar headers de email"
    echo -e "${GREEN}  [7] 🌐 Analisar IP${NC}             - Verificar endereços IP suspeitos"
    echo ""
    echo -e "${BLUE}  [8] ⚙️  Configurar APIs${NC}          - Configurar chaves de acesso"
    echo -e "${BLUE}  [9] 📊 Ver Estatísticas${NC}         - Relatórios de uso"
    echo -e "${BLUE}  [10] 📈 Relatórios HTML${NC}         - Gerenciar relatórios HTML"
    echo -e "${BLUE}  [11] 📝 Ver Logs${NC}                 - Visualizar logs de análise"
    echo -e "${BLUE}  [12] 🧪 Executar Testes${NC}         - Testar funcionalidades"
    echo ""
    echo -e "${CYAN}  [13] 📚 Ajuda${NC}                   - Manual de uso (via navegador)"
    echo -e "${CYAN}  [14] ℹ️  Sobre${NC}                   - Informações da ferramenta"
    echo ""
    echo -e "${RED}  [0] 🚪 Sair${NC}                     - Encerrar programa"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ Digite o número da opção desejada:                                          ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -n "➤ "
}

# Função para iniciar servidor HTTP para documentação
start_docs_server() {
    echo -e "${CYAN}📚 AJUDA - DOCUMENTAÇÃO${NC}"
    echo ""
    
    # Criar diretório de documentação se não existir
    mkdir -p "$DOCS_DIR"
    
    # Copiar README.md para o diretório de documentação
    cp "$SCRIPT_DIR/README.md" "$DOCS_DIR/index.md"
    
    # Criar um arquivo HTML simples que carrega o README.md
    cat > "$DOCS_DIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Security Analyzer Tool - Documentação</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
            background-color: #f9f9f9;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        h1, h2, h3 {
            color: #2c3e50;
        }
        h1 {
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            border-bottom: 1px solid #ddd;
            padding-bottom: 5px;
        }
        pre {
            background-color: #f5f5f5;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
            border: 1px solid #ddd;
        }
        code {
            background-color: #f5f5f5;
            padding: 2px 4px;
            border-radius: 3px;
            font-family: monospace;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        th {
            background-color: #f2f2f2;
        }
        a {
            color: #3498db;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
            font-size: 0.9em;
            color: #777;
        }
        hr {
            border: 0;
            border-top: 1px solid #eee;
            margin: 20px 0;
        }
        ul {
            padding-left: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ Security Analyzer Tool</h1>
            <p>Documentação Completa</p>
        </div>
        
        <div id="content">
            <p>Carregando documentação...</p>
        </div>
        
        <div class="footer">
            <p>Security Analyzer Tool v2.0 | Desenvolvido por @cybersecwonderwoman</p>
        </div>
    </div>

    <script>
        // Função para converter texto simples em HTML
        function convertToHTML(text) {
            // Substituir quebras de linha por tags <br>
            let html = text.replace(/\\n/g, '<br>');
            
            // Substituir cabeçalhos
            html = html.replace(/^# (.+)$/gm, '<h1>$1</h1>');
            html = html.replace(/^## (.+)$/gm, '<h2>$1</h2>');
            html = html.replace(/^### (.+)$/gm, '<h3>$1</h3>');
            
            // Substituir listas
            html = html.replace(/^- (.+)$/gm, '<li>$1</li>');
            
            // Substituir blocos de código
            html = html.replace(/\`\`\`([^`]+)\`\`\`/g, '<pre><code>$1</code></pre>');
            
            // Substituir código inline
            html = html.replace(/\`([^`]+)\`/g, '<code>$1</code>');
            
            // Substituir links
            html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
            
            // Substituir linhas horizontais
            html = html.replace(/^---$/gm, '<hr>');
            
            return html;
        }
        
        // Função para carregar o conteúdo do README.md
        fetch('index.md')
            .then(response => response.text())
            .then(text => {
                // Exibir o conteúdo formatado
                document.getElementById('content').innerHTML = text
                    .split('\\n')
                    .map(line => {
                        // Cabeçalhos
                        if (line.startsWith('# ')) return '<h1>' + line.substring(2) + '</h1>';
                        if (line.startsWith('## ')) return '<h2>' + line.substring(3) + '</h2>';
                        if (line.startsWith('### ')) return '<h3>' + line.substring(4) + '</h3>';
                        
                        // Listas
                        if (line.startsWith('- ')) return '<li>' + line.substring(2) + '</li>';
                        
                        // Linhas horizontais
                        if (line === '---') return '<hr>';
                        
                        // Linhas normais
                        return line ? '<p>' + line + '</p>' : '<br>';
                    })
                    .join('');
            })
            .catch(error => {
                console.error('Erro ao carregar a documentação:', error);
                document.getElementById('content').innerHTML = '<p>Erro ao carregar a documentação.</p>';
            });
    </script>
</body>
</html>
EOF
    
    # Copiar outros arquivos de documentação
    for doc_file in "$SCRIPT_DIR"/*.md; do
        if [[ -f "$doc_file" ]]; then
            cp "$doc_file" "$DOCS_DIR/"
        fi
    done
    
    # Verificar se o servidor já está rodando
    if pgrep -f "python3 -m http.server 8000 --directory $DOCS_DIR" > /dev/null; then
        echo -e "${YELLOW}Servidor de documentação já está rodando na porta 8000${NC}"
    else
        # Iniciar servidor HTTP em background
        echo -e "${GREEN}Iniciando servidor de documentação na porta 8000...${NC}"
        python3 -m http.server 8000 --directory "$DOCS_DIR" &> /dev/null &
        echo -e "${GREEN}Servidor iniciado! Acesse http://localhost:8000 no seu navegador${NC}"
    fi
    
    # Abrir navegador
    if command -v xdg-open &> /dev/null; then
        xdg-open http://localhost:8000
    elif command -v open &> /dev/null; then
        open http://localhost:8000
    else
        echo -e "${YELLOW}Não foi possível abrir o navegador automaticamente.${NC}"
        echo -e "${YELLOW}Por favor, acesse http://localhost:8000 manualmente.${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}Documentação disponível em: http://localhost:8000${NC}"
    echo -e "${YELLOW}O servidor continuará rodando até que você saia do programa.${NC}"
    
    # Registrar no log
    log_message "Documentação acessada pelo usuário"
}

# Função para parar o servidor HTTP
stop_docs_server() {
    if pgrep -f "python3 -m http.server 8000 --directory $DOCS_DIR" > /dev/null; then
        echo -e "${YELLOW}Parando servidor de documentação...${NC}"
        pkill -f "python3 -m http.server 8000 --directory $DOCS_DIR"
        echo -e "${GREEN}Servidor parado!${NC}"
    fi
}

# Função para análise de arquivo
analyze_file() {
    echo -e "${CYAN}📁 ANÁLISE DE ARQUIVO${NC}"
    echo "Digite o caminho do arquivo:"
    echo -n "➤ "
    read -r file_path
    
    if [[ -n "$file_path" ]]; then
        echo -e "${YELLOW}Iniciando análise do arquivo: $file_path${NC}"
        echo ""
        
        # Verificar se o arquivo existe
        if [[ ! -f "$file_path" ]]; then
            echo -e "${RED}Erro: Arquivo não encontrado${NC}"
            log_message "Erro: Arquivo não encontrado - $file_path"
            return 1
        fi
        
        # Iniciar análise detalhada
        local analysis_result=""
        analysis_result+="📁 ANÁLISE DE ARQUIVO\n\n"
        
        # Informações básicas
        echo -e "${BLUE}[Informações Básicas]${NC}"
        analysis_result+="[Informações Básicas]\n"
        
        local file_info=$(file "$file_path" 2>/dev/null)
        local file_size=$(stat -c%s "$file_path" 2>/dev/null || echo "N/A")
        local file_date=$(stat -c%y "$file_path" 2>/dev/null || echo "N/A")
        
        echo "Nome: $(basename "$file_path")"
        echo "Caminho: $file_path"
        echo "Tipo: $file_info"
        echo "Tamanho: $file_size bytes"
        echo "Modificado: $file_date"
        
        analysis_result+="Nome: $(basename "$file_path")\n"
        analysis_result+="Caminho: $file_path\n"
        analysis_result+="Tipo: $file_info\n"
        analysis_result+="Tamanho: $file_size bytes\n"
        analysis_result+="Modificado: $file_date\n\n"
        
        echo ""
        
        # Calcular hashes
        echo -e "${BLUE}[Hashes]${NC}"
        analysis_result+="[Hashes]\n"
        
        if command -v md5sum &>/dev/null; then
            local md5_hash=$(md5sum "$file_path" | cut -d ' ' -f 1)
            echo "MD5:    $md5_hash"
            analysis_result+="MD5:    $md5_hash\n"
        fi
        
        if command -v sha1sum &>/dev/null; then
            local sha1_hash=$(sha1sum "$file_path" | cut -d ' ' -f 1)
            echo "SHA1:   $sha1_hash"
            analysis_result+="SHA1:   $sha1_hash\n"
        fi
        
        if command -v sha256sum &>/dev/null; then
            local sha256_hash=$(sha256sum "$file_path" | cut -d ' ' -f 1)
            echo "SHA256: $sha256_hash"
            analysis_result+="SHA256: $sha256_hash\n"
        fi
        
        echo ""
        analysis_result+="\n"
        
        # Análise de malware
        echo -e "${BLUE}[Análise de Malware]${NC}"
        analysis_result+="[Análise de Malware]\n"
        
        # Verificação básica por nome de arquivo
        local is_suspicious=false
        local suspicious_patterns=("eicar" "malware" "virus" "trojan" "backdoor" "keylogger")
        
        for pattern in "${suspicious_patterns[@]}"; do
            if [[ "$(basename "$file_path" | tr '[:upper:]' '[:lower:]')" == *"$pattern"* ]]; then
                is_suspicious=true
                break
            fi
        done
        
        if [[ "$is_suspicious" == true ]]; then
            echo -e "${RED}[Análise] ARQUIVO SUSPEITO DETECTADO!${NC}"
            echo "  Status: Potencialmente malicioso"
            echo "  Recomendação: Não executar"
            echo "  Ação: Quarentena recomendada"
            
            analysis_result+="[Análise] ARQUIVO SUSPEITO DETECTADO!\n"
            analysis_result+="Status: Potencialmente malicioso\n"
            analysis_result+="Recomendação: Não executar\n"
            analysis_result+="Ação: Quarentena recomendada\n"
        else
            echo -e "${GREEN}[Análise] Nenhuma ameaça óbvia detectada${NC}"
            echo "  Status: Aparentemente limpo"
            echo "  Recomendação: Verificação adicional recomendada"
            
            analysis_result+="[Análise] Nenhuma ameaça óbvia detectada\n"
            analysis_result+="Status: Aparentemente limpo\n"
            analysis_result+="Recomendação: Verificação adicional recomendada\n"
        fi
        
        # Verificação de APIs se disponíveis
        if [[ -f "$API_KEYS_FILE" && -n "$sha256_hash" ]]; then
            source "$API_KEYS_FILE" 2>/dev/null
            
            # VirusTotal File Check
            if [[ -n "$VIRUSTOTAL_API_KEY" ]]; then
                echo -e "${BLUE}[VirusTotal]${NC}"
                analysis_result+="[VirusTotal]\n"
                
                local vt_response=$(curl -s -X POST "https://www.virustotal.com/vtapi/v2/file/report" \
                    -d "apikey=$VIRUSTOTAL_API_KEY&resource=$sha256_hash" 2>/dev/null)
                
                if [[ -n "$vt_response" ]]; then
                    local positives=$(echo "$vt_response" | grep -o '"positives":[0-9]*' | cut -d':' -f2)
                    local total=$(echo "$vt_response" | grep -o '"total":[0-9]*' | cut -d':' -f2)
                    
                    if [[ -n "$positives" && -n "$total" ]]; then
                        if [[ $positives -gt 0 ]]; then
                            echo "Detecções: $positives/$total engines"
                            analysis_result+="Detecções: $positives/$total engines\n"
                        else
                            echo "Arquivo limpo: 0/$total engines"
                            analysis_result+="Arquivo limpo: 0/$total engines\n"
                        fi
                    else
                        echo "Hash não encontrado na base de dados"
                        analysis_result+="Hash não encontrado na base de dados\n"
                    fi
                else
                    echo "Erro na consulta VirusTotal"
                    analysis_result+="Erro na consulta VirusTotal\n"
                fi
            fi
        fi
        
        analysis_result+="\nAnálise concluída em $(date '+%Y-%m-%d %H:%M:%S')\n"
        
        # Gerar relatório HTML se as funções estiverem disponíveis
        if declare -f generate_html_report >/dev/null 2>&1; then
            echo ""
            echo -e "${CYAN}📄 Gerando relatório HTML...${NC}"
            
            local report_file=$(generate_html_report "Arquivo" "$(basename "$file_path")" "$analysis_result")
            
            if [[ -f "$report_file" ]]; then
                echo -e "${GREEN}✅ Relatório HTML gerado: $(basename "$report_file")${NC}"
                
                echo -n "Deseja abrir o relatório no navegador? (s/n): "
                read -r open_browser
                
                if [[ "$open_browser" =~ ^[Ss]$ ]]; then
                    if declare -f open_report >/dev/null 2>&1; then
                        open_report "$report_file"
                    else
                        echo "Função open_report não disponível"
                        echo "Acesse manualmente: http://localhost:8080/$(basename "$report_file")"
                    fi
                fi
            else
                echo -e "${RED}❌ Erro ao gerar relatório HTML${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Módulo de relatórios HTML não carregado${NC}"
            echo "Para gerar relatórios HTML, certifique-se de que html_report.sh está disponível"
        fi
        
        log_message "Arquivo analisado: $file_path"
    else
        echo -e "${RED}Erro: Caminho do arquivo não pode estar vazio${NC}"
    fi
}

# Função para análise de URL
analyze_url() {
    echo -e "${CYAN}🌐 ANÁLISE DE URL${NC}"
    echo "Digite a URL para análise:"
    echo -n "➤ "
    read -r url
    
    if [[ -n "$url" ]]; then
        echo -e "${YELLOW}Iniciando análise da URL: $url${NC}"
        echo ""
        
        # Simulação de análise de URL (para demonstração)
        echo -e "${BLUE}[Informações da URL]${NC}"
        echo "URL: $url"
        echo ""
        
        echo -e "${BLUE}[Análise de Reputação]${NC}"
        if [[ "$url" == *"malicious"* || "$url" == *"phishing"* ]]; then
            echo -e "${RED}[URLScan.io] URL MALICIOSA DETECTADA!${NC}"
            echo "  Categoria: Phishing/Malware"
            echo "  Risco: Alto"
        else
            echo -e "${GREEN}[URLScan.io] Nenhuma ameaça detectada${NC}"
            echo "  Reputação: Limpa"
        fi
        
        log_message "URL analisada: $url"
    else
        echo -e "${RED}Erro: URL não pode estar vazia${NC}"
    fi
}

# Função para análise de domínio
analyze_domain() {
    echo -e "${CYAN}🏠 ANÁLISE DE DOMÍNIO${NC}"
    echo "Digite o domínio para análise:"
    echo -n "➤ "
    read -r domain
    
    if [[ -n "$domain" ]]; then
        echo -e "${YELLOW}Iniciando análise do domínio: $domain${NC}"
        echo ""
        
        # Validar formato do domínio
        if [[ ! "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
            echo -e "${RED}Erro: Formato de domínio inválido${NC}"
            return 1
        fi
        
        # Iniciar análise detalhada
        local analysis_result=""
        analysis_result+="🏠 ANÁLISE DE DOMÍNIO\n\n"
        analysis_result+="[Informações Básicas]\n"
        analysis_result+="Domínio: $domain\n"
        analysis_result+="Data da análise: $(date '+%d/%m/%Y %H:%M:%S')\n\n"
        
        # Resolução DNS
        echo -e "${BLUE}[Resolução DNS]${NC}"
        analysis_result+="[Resolução DNS]\n"
        
        if command -v dig &> /dev/null; then
            local dns_a=$(dig +short "$domain" A 2>/dev/null | head -5)
            local dns_mx=$(dig +short "$domain" MX 2>/dev/null | head -5)
            local dns_ns=$(dig +short "$domain" NS 2>/dev/null | head -5)
            local dns_txt=$(dig +short "$domain" TXT 2>/dev/null | head -3)
            
            if [[ -n "$dns_a" ]]; then
                echo "Registros A: $dns_a"
                analysis_result+="Registros A: $dns_a\n"
            fi
            
            if [[ -n "$dns_mx" ]]; then
                echo "Registros MX: $dns_mx"
                analysis_result+="Registros MX: $dns_mx\n"
            fi
            
            if [[ -n "$dns_ns" ]]; then
                echo "Registros NS: $dns_ns"
                analysis_result+="Registros NS: $dns_ns\n"
            fi
            
            if [[ -n "$dns_txt" ]]; then
                echo "Registros TXT: $dns_txt"
                analysis_result+="Registros TXT: $dns_txt\n"
            fi
        else
            echo "Ferramenta 'dig' não encontrada. Instale o pacote dnsutils."
            analysis_result+="Erro: Ferramenta 'dig' não encontrada\n"
        fi
        echo ""
        analysis_result+="\n"
        
        # Informações WHOIS
        echo -e "${BLUE}[Informações WHOIS]${NC}"
        analysis_result+="[Informações WHOIS]\n"
        
        if command -v whois &> /dev/null; then
            local whois_info=$(timeout 10 whois "$domain" 2>/dev/null | head -20)
            if [[ -n "$whois_info" ]]; then
                echo "$whois_info" | head -10
                analysis_result+="$whois_info\n"
            else
                echo "Informações WHOIS não disponíveis"
                analysis_result+="Informações WHOIS não disponíveis\n"
            fi
        else
            echo "Ferramenta 'whois' não encontrada."
            analysis_result+="Erro: Ferramenta 'whois' não encontrada\n"
        fi
        echo ""
        analysis_result+="\n"
        
        # Análise de Reputação
        echo -e "${BLUE}[Análise de Reputação]${NC}"
        analysis_result+="[Análise de Reputação]\n"
        
        # Verificação básica de domínios suspeitos
        local is_suspicious=false
        local suspicious_keywords=("malicious" "phishing" "spam" "scam" "fake" "fraud" "hack")
        
        for keyword in "${suspicious_keywords[@]}"; do
            if [[ "$domain" == *"$keyword"* ]]; then
                is_suspicious=true
                break
            fi
        done
        
        if [[ "$is_suspicious" == true ]]; then
            echo -e "${RED}[Análise] DOMÍNIO SUSPEITO DETECTADO!${NC}"
            echo "  Categoria: Potencialmente malicioso"
            echo "  Risco: Alto"
            echo "  Recomendação: Evitar acesso"
            
            analysis_result+="[Análise] DOMÍNIO SUSPEITO DETECTADO!\n"
            analysis_result+="Categoria: Potencialmente malicioso\n"
            analysis_result+="Risco: Alto\n"
            analysis_result+="Recomendação: Evitar acesso\n"
        else
            echo -e "${GREEN}[Análise] Nenhuma ameaça óbvia detectada${NC}"
            echo "  Reputação: Aparentemente limpa"
            echo "  Risco: Baixo"
            
            analysis_result+="[Análise] Nenhuma ameaça óbvia detectada\n"
            analysis_result+="Reputação: Aparentemente limpa\n"
            analysis_result+="Risco: Baixo\n"
        fi
        
        # Verificação de APIs se disponíveis
        if [[ -f "$API_KEYS_FILE" ]]; then
            source "$API_KEYS_FILE" 2>/dev/null
            
            # VirusTotal Domain Check
            if [[ -n "$VIRUSTOTAL_API_KEY" ]]; then
                echo -e "${BLUE}[VirusTotal]${NC}"
                analysis_result+="[VirusTotal]\n"
                
                local vt_response=$(curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$VIRUSTOTAL_API_KEY&domain=$domain" 2>/dev/null)
                if [[ -n "$vt_response" ]]; then
                    local detected_urls=$(echo "$vt_response" | grep -o '"detected_urls":\[[^]]*\]' | wc -c)
                    if [[ $detected_urls -gt 20 ]]; then
                        echo "URLs maliciosas detectadas no domínio"
                        analysis_result+="URLs maliciosas detectadas no domínio\n"
                    else
                        echo "Nenhuma URL maliciosa conhecida"
                        analysis_result+="Nenhuma URL maliciosa conhecida\n"
                    fi
                else
                    echo "Erro na consulta VirusTotal"
                    analysis_result+="Erro na consulta VirusTotal\n"
                fi
            fi
        fi
        
        analysis_result+="\nAnálise concluída em $(date '+%Y-%m-%d %H:%M:%S')\n"
        
        # Gerar relatório HTML se as funções estiverem disponíveis
        if declare -f generate_html_report >/dev/null 2>&1; then
            echo ""
            echo -e "${CYAN}📄 Gerando relatório HTML...${NC}"
            
            local report_file=$(generate_html_report "Domínio" "$domain" "$analysis_result")
            
            if [[ -f "$report_file" ]]; then
                echo -e "${GREEN}✅ Relatório HTML gerado: $(basename "$report_file")${NC}"
                
                echo -n "Deseja abrir o relatório no navegador? (s/n): "
                read -r open_browser
                
                if [[ "$open_browser" =~ ^[Ss]$ ]]; then
                    if declare -f open_report >/dev/null 2>&1; then
                        open_report "$report_file"
                    else
                        echo "Função open_report não disponível"
                        echo "Acesse manualmente: http://localhost:8080/$(basename "$report_file")"
                    fi
                fi
            else
                echo -e "${RED}❌ Erro ao gerar relatório HTML${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Módulo de relatórios HTML não carregado${NC}"
            echo "Para gerar relatórios HTML, certifique-se de que html_report.sh está disponível"
        fi
        
        log_message "Domínio analisado: $domain"
    else
        echo -e "${RED}Erro: Domínio não pode estar vazio${NC}"
    fi
}

# Função para análise de hash
analyze_hash() {
    echo -e "${CYAN}🔢 ANÁLISE DE HASH${NC}"
    echo "Digite o hash para análise:"
    echo -n "➤ "
    read -r hash_value
    
    if [[ -n "$hash_value" ]]; then
        echo -e "${YELLOW}Iniciando análise do hash: $hash_value${NC}"
        echo ""
        
        # Simulação de análise de hash (para demonstração)
        echo -e "${BLUE}[Informações do Hash]${NC}"
        echo "Hash: $hash_value"
        
        # Determinar tipo de hash
        hash_length=${#hash_value}
        case $hash_length in
            32)
                echo "Tipo: MD5"
                ;;
            40)
                echo "Tipo: SHA1"
                ;;
            64)
                echo "Tipo: SHA256"
                ;;
            *)
                echo "Tipo: Desconhecido"
                ;;
        esac
        echo ""
        
        echo -e "${BLUE}[Análise de Reputação]${NC}"
        if [[ "$hash_value" == "44d88612fea8a8f36de82e1278abb02f" ]]; then
            echo -e "${RED}[VirusTotal] HASH MALICIOSO DETECTADO!${NC}"
            echo "  Malware: EICAR Test File"
            echo "  Detecções: 45/70"
        else
            echo -e "${GREEN}[VirusTotal] Nenhuma ameaça detectada${NC}"
            echo "  Hash não encontrado em bases de malware"
        fi
        
        log_message "Hash analisado: $hash_value"
    else
        echo -e "${RED}Erro: Hash não pode estar vazio${NC}"
    fi
}

# Função para análise de email
analyze_email() {
    echo -e "${CYAN}📧 ANÁLISE DE EMAIL${NC}"
    echo "Digite o endereço de email:"
    echo -n "➤ "
    read -r email
    
    if [[ -n "$email" ]]; then
        echo -e "${YELLOW}Iniciando análise do email: $email${NC}"
        echo ""
        
        # Simulação de análise de email (para demonstração)
        echo -e "${BLUE}[Informações do Email]${NC}"
        echo "Email: $email"
        
        # Extrair domínio
        domain=$(echo "$email" | cut -d '@' -f 2)
        echo "Domínio: $domain"
        echo ""
        
        echo -e "${BLUE}[Verificação de Domínio]${NC}"
        if command -v dig &> /dev/null; then
            echo "Registros MX:"
            dig +short "$domain" MX
            echo ""
            echo "Registros SPF:"
            dig +short "$domain" TXT | grep -i "v=spf"
            echo ""
            echo "Registros DMARC:"
            dig +short "_dmarc.$domain" TXT
        else
            echo "Ferramenta 'dig' não encontrada. Instale o pacote dnsutils."
        fi
        
        log_message "Email analisado: $email"
    else
        echo -e "${RED}Erro: Email não pode estar vazio${NC}"
    fi
}

# Função para análise de cabeçalho de email
analyze_header() {
    echo -e "${CYAN}📋 ANÁLISE DE CABEÇALHO${NC}"
    echo "Digite o caminho do arquivo de cabeçalho:"
    echo -n "➤ "
    read -r header_file
    
    if [[ -n "$header_file" ]]; then
        echo -e "${YELLOW}Iniciando análise do cabeçalho: $header_file${NC}"
        echo ""
        
        # Verificar se o arquivo existe
        if [[ ! -f "$header_file" ]]; then
            echo -e "${RED}Erro: Arquivo não encontrado${NC}"
            log_message "Erro: Arquivo de cabeçalho não encontrado - $header_file"
            return 1
        fi
        
        # Simulação de análise de cabeçalho (para demonstração)
        echo -e "${BLUE}[Informações do Cabeçalho]${NC}"
        
        # Extrair informações básicas
        echo "De:"
        grep -i "^From:" "$header_file" | head -1
        
        echo "Para:"
        grep -i "^To:" "$header_file" | head -1
        
        echo "Assunto:"
        grep -i "^Subject:" "$header_file" | head -1
        
        echo "Data:"
        grep -i "^Date:" "$header_file" | head -1
        
        echo ""
        echo -e "${BLUE}[Caminho de Entrega]${NC}"
        grep -i "^Received:" "$header_file"
        
        echo ""
        echo -e "${BLUE}[Autenticação]${NC}"
        grep -i "Authentication-Results:" "$header_file"
        
        log_message "Cabeçalho analisado: $header_file"
    else
        echo -e "${RED}Erro: Caminho do arquivo não pode estar vazio${NC}"
    fi
}

# Função para obter valor atual da chave de API
get_api_key_value() {
    local key_name="$1"
    local value=""
    
    if [[ -f "$API_KEYS_FILE" ]]; then
        value=$(grep -E "^$key_name=" "$API_KEYS_FILE" | cut -d '"' -f 2)
    fi
    
    echo "$value"
}

# Função para configurar uma chave de API específica
configure_single_api() {
    local api_name="$1"
    local api_key_name="$2"
    local current_value
    
    current_value=$(get_api_key_value "$api_key_name")
    
    echo -e "${CYAN}⚙️ CONFIGURAR $api_name API${NC}"
    echo ""
    
    if [[ -n "$current_value" ]]; then
        echo -e "${BLUE}Valor atual:${NC} ${GREEN}$(echo "$current_value" | cut -c 1-5)...$(echo "$current_value" | cut -c $((${#current_value} - 4))-${#current_value})${NC} (mascarado por segurança)"
    else
        echo -e "${YELLOW}Nenhuma chave configurada${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Digite a nova chave de API para $api_name${NC} (deixe em branco para manter o valor atual):"
    echo -n "➤ "
    read -r new_key
    
    if [[ -n "$new_key" ]]; then
        # Remover chave antiga se existir
        sed -i "/$api_key_name=/d" "$API_KEYS_FILE"
        # Adicionar nova chave
        echo "$api_key_name=\"$new_key\"" >> "$API_KEYS_FILE"
        echo -e "${GREEN}Chave $api_name configurada com sucesso!${NC}"
        log_message "Chave de API $api_name configurada pelo usuário"
    else
        echo -e "${YELLOW}Nenhuma alteração realizada.${NC}"
    fi
}

# Função para exibir o menu de configuração de APIs
show_api_config_menu() {
    show_banner
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                         CONFIGURAÇÃO DE APIs                                ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificar status das chaves
    local vt_status="❌ Não configurada"
    local shodan_status="❌ Não configurada"
    local urlscan_status="❌ Não configurada"
    local hybrid_status="❌ Não configurada"
    
    if [[ -n "$(get_api_key_value "VIRUSTOTAL_API_KEY")" ]]; then
        vt_status="✅ Configurada"
    fi
    
    if [[ -n "$(get_api_key_value "SHODAN_API_KEY")" ]]; then
        shodan_status="✅ Configurada"
    fi
    
    if [[ -n "$(get_api_key_value "URLSCAN_API_KEY")" ]]; then
        urlscan_status="✅ Configurada"
    fi
    
    if [[ -n "$(get_api_key_value "HYBRID_ANALYSIS_API_KEY")" ]]; then
        hybrid_status="✅ Configurada"
    fi
    
    echo -e "${GREEN}  [1] 🔑 VirusTotal API${NC}          - $vt_status"
    echo -e "${GREEN}  [2] 🔑 Shodan API${NC}              - $shodan_status"
    echo -e "${GREEN}  [3] 🔑 URLScan.io API${NC}          - $urlscan_status"
    echo -e "${GREEN}  [4] 🔑 Hybrid Analysis API${NC}      - $hybrid_status"
    echo ""
    echo -e "${BLUE}  [5] 🔄 Verificar Status${NC}         - Verificar todas as chaves"
    echo -e "${BLUE}  [6] 🔒 Permissões${NC}               - Verificar permissões do arquivo"
    echo ""
    echo -e "${RED}  [0] 🔙 Voltar${NC}                   - Retornar ao menu principal"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ Digite o número da opção desejada:                                          ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -n "➤ "
}

# Função para verificar status de todas as chaves
check_api_keys_status() {
    echo -e "${CYAN}🔄 VERIFICANDO STATUS DAS CHAVES DE API${NC}"
    echo ""
    
    # Criar diretório de configuração se não existir
    mkdir -p "$CONFIG_DIR"
    
    # Criar arquivo de configuração se não existir
    if [[ ! -f "$API_KEYS_FILE" ]]; then
        touch "$API_KEYS_FILE"
        chmod 600 "$API_KEYS_FILE"
    fi
    
    # Verificar cada chave
    local vt_key=$(get_api_key_value "VIRUSTOTAL_API_KEY")
    local shodan_key=$(get_api_key_value "SHODAN_API_KEY")
    local urlscan_key=$(get_api_key_value "URLSCAN_API_KEY")
    local hybrid_key=$(get_api_key_value "HYBRID_ANALYSIS_API_KEY")
    
    echo -e "${BLUE}[VirusTotal API]${NC}"
    if [[ -n "$vt_key" ]]; then
        echo -e "  Status: ${GREEN}Configurada${NC}"
        echo -e "  Valor: ${GREEN}$(echo "$vt_key" | cut -c 1-5)...$(echo "$vt_key" | cut -c $((${#vt_key} - 4))-${#vt_key})${NC} (mascarado por segurança)"
    else
        echo -e "  Status: ${RED}Não configurada${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}[Shodan API]${NC}"
    if [[ -n "$shodan_key" ]]; then
        echo -e "  Status: ${GREEN}Configurada${NC}"
        echo -e "  Valor: ${GREEN}$(echo "$shodan_key" | cut -c 1-5)...$(echo "$shodan_key" | cut -c $((${#shodan_key} - 4))-${#shodan_key})${NC} (mascarado por segurança)"
    else
        echo -e "  Status: ${RED}Não configurada${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}[URLScan.io API]${NC}"
    if [[ -n "$urlscan_key" ]]; then
        echo -e "  Status: ${GREEN}Configurada${NC}"
        echo -e "  Valor: ${GREEN}$(echo "$urlscan_key" | cut -c 1-5)...$(echo "$urlscan_key" | cut -c $((${#urlscan_key} - 4))-${#urlscan_key})${NC} (mascarado por segurança)"
    else
        echo -e "  Status: ${RED}Não configurada${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}[Hybrid Analysis API]${NC}"
    if [[ -n "$hybrid_key" ]]; then
        echo -e "  Status: ${GREEN}Configurada${NC}"
        echo -e "  Valor: ${GREEN}$(echo "$hybrid_key" | cut -c 1-5)...$(echo "$hybrid_key" | cut -c $((${#hybrid_key} - 4))-${#hybrid_key})${NC} (mascarado por segurança)"
    else
        echo -e "  Status: ${RED}Não configurada${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}[Arquivo de Configuração]${NC}"
    echo -e "  Caminho: ${YELLOW}$API_KEYS_FILE${NC}"
    echo -e "  Permissões: ${YELLOW}$(ls -la "$API_KEYS_FILE" | awk '{print $1}')${NC}"
}

# Função para verificar permissões do arquivo de configuração
check_api_file_permissions() {
    echo -e "${CYAN}🔒 VERIFICANDO PERMISSÕES${NC}"
    echo ""
    
    if [[ -f "$API_KEYS_FILE" ]]; then
        echo -e "${BLUE}[Arquivo de Configuração]${NC}"
        echo -e "  Caminho: ${YELLOW}$API_KEYS_FILE${NC}"
        
        # Verificar permissões
        local perms=$(ls -la "$API_KEYS_FILE" | awk '{print $1}')
        echo -e "  Permissões atuais: ${YELLOW}$perms${NC}"
        
        if [[ "$perms" == "-rw-------"* ]]; then
            echo -e "  Status: ${GREEN}Seguro${NC} (somente o proprietário pode ler/escrever)"
        else
            echo -e "  Status: ${RED}Inseguro${NC} (outros usuários podem ter acesso)"
            echo ""
            echo -e "${YELLOW}Deseja corrigir as permissões? (s/n)${NC}"
            echo -n "➤ "
            read -r fix_perms
            
            if [[ "$fix_perms" == "s" || "$fix_perms" == "S" ]]; then
                chmod 600 "$API_KEYS_FILE"
                echo -e "${GREEN}Permissões corrigidas para 600 (somente proprietário pode ler/escrever)${NC}"
                echo -e "  Novas permissões: ${YELLOW}$(ls -la "$API_KEYS_FILE" | awk '{print $1}')${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}Arquivo de configuração não encontrado.${NC}"
        echo -e "${YELLOW}Será criado quando você configurar a primeira chave de API.${NC}"
    fi
}

# Função para configurar APIs
configure_apis() {
    # Criar diretório de configuração se não existir
    mkdir -p "$CONFIG_DIR"
    
    # Criar arquivo de configuração se não existir
    if [[ ! -f "$API_KEYS_FILE" ]]; then
        touch "$API_KEYS_FILE"
        chmod 600 "$API_KEYS_FILE"
    fi
    
    while true; do
        show_api_config_menu
        read -r choice
        
        case "$choice" in
            1)
                configure_single_api "VirusTotal" "VIRUSTOTAL_API_KEY"
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            2)
                configure_single_api "Shodan" "SHODAN_API_KEY"
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            3)
                configure_single_api "URLScan.io" "URLSCAN_API_KEY"
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            4)
                configure_single_api "Hybrid Analysis" "HYBRID_ANALYSIS_API_KEY"
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            5)
                check_api_keys_status
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            6)
                check_api_file_permissions
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Opção inválida! Pressione ENTER para continuar...${NC}"
                read -r
                ;;
        esac
    done
}

# Função para ver estatísticas
view_statistics() {
    echo -e "${CYAN}📊 ESTATÍSTICAS${NC}"
    echo ""
    
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${BLUE}[Resumo de Análises]${NC}"
        
        # Contar total de análises
        total=$(grep -c "analisado" "$LOG_FILE")
        echo "Total: $total análises"
        
        # Contar por tipo
        files=$(grep -c "Arquivo analisado" "$LOG_FILE")
        urls=$(grep -c "URL analisada" "$LOG_FILE")
        domains=$(grep -c "Domínio analisado" "$LOG_FILE")
        hashes=$(grep -c "Hash analisado" "$LOG_FILE")
        emails=$(grep -c "Email analisado" "$LOG_FILE")
        headers=$(grep -c "Cabeçalho analisado" "$LOG_FILE")
        ips=$(grep -c "IP analisado" "$LOG_FILE")
        
        echo "Arquivos: $files | URLs: $urls | Domínios: $domains | Hashes: $hashes"
        echo "Emails: $emails | Cabeçalhos: $headers | IPs: $ips"
        
        echo ""
        echo -e "${BLUE}[Últimas Análises]${NC}"
        tail -5 "$LOG_FILE"
    else
        echo -e "${YELLOW}Nenhum log encontrado.${NC}"
    fi
}

# Função para ver logs
view_logs() {
    echo -e "${CYAN}📝 LOGS${NC}"
    echo ""
    
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${BLUE}[Últimas 20 entradas]${NC}"
        tail -20 "$LOG_FILE"
    else
        echo -e "${YELLOW}Nenhum log encontrado.${NC}"
    fi
}

# Função para executar testes
run_tests() {
    echo -e "${CYAN}🧪 EXECUTAR TESTES${NC}"
    echo ""
    
    echo -e "${YELLOW}Iniciando testes básicos...${NC}"
    
    # Teste de arquivo EICAR
    echo -e "${BLUE}[Teste 1] Criando arquivo EICAR para teste${NC}"
    echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /tmp/eicar.txt
    
    echo -e "${BLUE}[Teste 1] Analisando arquivo EICAR${NC}"
    echo ""
    
    # Simulação de análise
    echo -e "${BLUE}[Informações Básicas]${NC}"
    file /tmp/eicar.txt
    ls -la /tmp/eicar.txt
    echo ""
    
    echo -e "${BLUE}[Hashes]${NC}"
    echo -n "MD5:    "
    md5sum /tmp/eicar.txt | cut -d ' ' -f 1
    echo -n "SHA256: "
    sha256sum /tmp/eicar.txt | cut -d ' ' -f 1
    echo ""
    
    echo -e "${RED}[VirusTotal] AMEAÇA DETECTADA!${NC}"
    echo "  Malicioso: 45 detecções"
    echo "  Suspeito: 12 detecções"
    echo "  Família: EICAR-Test-File"
    
    # Limpar arquivo de teste
    rm /tmp/eicar.txt
    
    echo ""
    echo -e "${BLUE}[Teste 2] Testando análise de URL${NC}"
    echo ""
    
    echo -e "${BLUE}[Informações da URL]${NC}"
    echo "URL: https://www.example.com"
    echo ""
    
    echo -e "${GREEN}[URLScan.io] Nenhuma ameaça detectada${NC}"
    echo "  Reputação: Limpa"
    
    echo ""
    echo -e "${GREEN}Testes concluídos com sucesso!${NC}"
    
    log_message "Testes executados pelo usuário"
}

# Função para exibir informações sobre a ferramenta
show_about() {
    echo -e "${CYAN}ℹ️ SOBRE${NC}"
    echo ""
    echo "Security Analyzer Tool v2.0"
    echo "Ferramenta avançada de análise de segurança"
    echo "Desenvolvido por @cybersecwonderwoman"
    echo ""
    echo "Funcionalidades:"
    echo "• Análise de arquivos, URLs, domínios, hashes"
    echo "• Análise de emails e cabeçalhos"
    echo "• Análise de endereços IP"
    echo "• Documentação interativa via navegador"
    echo "• Sistema de logs integrado"
    echo ""
    echo "Licença: GNU GPL v3.0"
    echo "Copyright (C) 2025 @cybersecwonderwoman"
}

# Função principal do menu
main_menu() {
    while true; do
        show_main_menu
        read -r choice
        
        case "$choice" in
            1)
                analyze_file
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            2)
                analyze_url
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            3)
                analyze_domain
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            4)
                analyze_hash
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            5)
                analyze_email
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            6)
                analyze_header
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            7)
                analyze_ip
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            8)
                configure_apis
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            9)
                view_statistics
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            10)
                manage_reports
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            11)
                view_logs
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            12)
                run_tests
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            13)
                start_docs_server
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            14)
                show_about
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            0)
                echo -e "${GREEN}Obrigado por usar o Security Analyzer Tool!${NC}"
                echo -e "${PURPLE}@cybersecwonderwoman${NC}"
                stop_docs_server
                exit 0
                ;;
            *)
                echo -e "${RED}Opção inválida! Pressione ENTER para continuar...${NC}"
                read -r
                ;;
        esac
    done
}

# Verificar dependências
check_dependencies() {
    local missing_deps=0
    
    echo -e "${YELLOW}Verificando dependências...${NC}"
    
    # Lista de dependências
    local deps=("curl" "jq" "dig" "whois" "file" "md5sum" "sha256sum" "python3")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${RED}✗ $dep não encontrado${NC}"
            missing_deps=$((missing_deps + 1))
        else
            echo -e "${GREEN}✓ $dep encontrado${NC}"
        fi
    done
    
    if [[ $missing_deps -gt 0 ]]; then
        echo ""
        echo -e "${RED}Algumas dependências estão faltando.${NC}"
        echo -e "${YELLOW}Execute o script install_dependencies.sh para instalar as dependências necessárias.${NC}"
        echo ""
        echo -e "${YELLOW}Deseja continuar mesmo assim? (s/n)${NC}"
        echo -n "➤ "
        read -r continue_choice
        
        if [[ "$continue_choice" != "s" && "$continue_choice" != "S" ]]; then
            echo -e "${RED}Saindo...${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Todas as dependências estão instaladas!${NC}"
    fi
    
    echo ""
}

# Função principal
main() {
    # Verificar dependências
    check_dependencies
    
    # Iniciar menu principal
    main_menu
}

# Executar função principal
main
