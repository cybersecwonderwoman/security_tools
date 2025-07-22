#!/bin/bash

# Script de correção final dos problemas identificados

echo "🔧 Corrigindo problemas finais do Security Tools..."

# 1. Corrigir problema do menu - criar versão simplificada
echo "📝 Criando versão corrigida do menu..."

cat > menu_fixed.sh << 'EOF'
#!/bin/bash

# Menu principal do Security Tools - Versão corrigida

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configurações básicas
SCRIPT_DIR="$(dirname "$0")"

# Função para exibir o menu principal
show_main_menu() {
    clear
    echo -e "${CYAN}"
    cat << "BANNER"
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
BANNER
    echo -e "${NC}"
    echo -e "${PURPLE}                           @cybersecwonderwoman${NC}"
    echo ""
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
    echo -e "${BLUE}  [10] 📝 Ver Logs${NC}                 - Visualizar logs de análise"
    echo -e "${BLUE}  [11] 🧪 Executar Testes${NC}         - Testar funcionalidades"
    echo ""
    echo -e "${CYAN}  [12] 📚 Ajuda${NC}                   - Manual de uso"
    echo -e "${CYAN}  [13] ℹ️  Sobre${NC}                   - Informações da ferramenta"
    echo ""
    echo -e "${RED}  [0] 🚪 Sair${NC}                     - Encerrar programa"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ Digite o número da opção desejada:                                          ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -n "➤ "
}

# Função para análise de IP
menu_analyze_ip() {
    echo -e "${CYAN}🌐 ANÁLISE DE IP${NC}"
    echo "Digite o endereço IP para análise:"
    echo -n "➤ "
    read -r ip_address
    
    if [[ -n "$ip_address" ]]; then
        echo -e "${YELLOW}Iniciando análise do IP: $ip_address${NC}"
        echo ""
        
        # Executar análise usando o security_analyzer.sh
        if [[ -f "$SCRIPT_DIR/security_analyzer.sh" ]]; then
            "$SCRIPT_DIR/security_analyzer.sh" --ip "$ip_address"
        else
            echo -e "${RED}Erro: Script security_analyzer.sh não encontrado${NC}"
            echo "Por favor, certifique-se de que o script security_analyzer.sh está no mesmo diretório."
        fi
    else
        echo -e "${RED}Erro: IP não pode estar vazio${NC}"
    fi
    
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}

# Função principal do menu
main_menu() {
    while true; do
        show_main_menu
        read -r choice
        
        case "$choice" in
            1)
                echo -e "${CYAN}📁 ANÁLISE DE ARQUIVO${NC}"
                echo "Digite o caminho do arquivo:"
                echo -n "➤ "
                read -r file_path
                if [[ -n "$file_path" ]]; then
                    "$SCRIPT_DIR/security_analyzer.sh" --file "$file_path"
                fi
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            2)
                echo -e "${CYAN}🌐 ANÁLISE DE URL${NC}"
                echo "Digite a URL para análise:"
                echo -n "➤ "
                read -r url
                if [[ -n "$url" ]]; then
                    "$SCRIPT_DIR/security_analyzer.sh" --url "$url"
                fi
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            3)
                echo -e "${CYAN}🏠 ANÁLISE DE DOMÍNIO${NC}"
                echo "Digite o domínio para análise:"
                echo -n "➤ "
                read -r domain
                if [[ -n "$domain" ]]; then
                    "$SCRIPT_DIR/security_analyzer.sh" --domain "$domain"
                fi
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            4)
                echo -e "${CYAN}🔢 ANÁLISE DE HASH${NC}"
                echo "Digite o hash para análise:"
                echo -n "➤ "
                read -r hash
                if [[ -n "$hash" ]]; then
                    "$SCRIPT_DIR/security_analyzer.sh" --hash "$hash"
                fi
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            5)
                echo -e "${CYAN}📧 ANÁLISE DE EMAIL${NC}"
                echo "Digite o endereço de email:"
                echo -n "➤ "
                read -r email
                if [[ -n "$email" ]]; then
                    "$SCRIPT_DIR/security_analyzer.sh" --email "$email"
                fi
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            6)
                echo -e "${CYAN}📋 ANÁLISE DE CABEÇALHO${NC}"
                echo "Digite o caminho do arquivo de cabeçalho:"
                echo -n "➤ "
                read -r header_file
                if [[ -n "$header_file" ]]; then
                    "$SCRIPT_DIR/security_analyzer.sh" --header "$header_file"
                fi
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            7)
                menu_analyze_ip
                ;;
            8)
                echo -e "${CYAN}⚙️ CONFIGURAR APIs${NC}"
                "$SCRIPT_DIR/security_analyzer.sh" --configure
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            9)
                echo -e "${CYAN}📊 ESTATÍSTICAS${NC}"
                echo "Funcionalidade em desenvolvimento..."
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            10)
                echo -e "${CYAN}📝 LOGS${NC}"
                if [[ -f "$HOME/.security_analyzer/analysis.log" ]]; then
                    tail -20 "$HOME/.security_analyzer/analysis.log"
                else
                    echo "Nenhum log encontrado."
                fi
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            11)
                echo -e "${CYAN}🧪 EXECUTAR TESTES${NC}"
                if [[ -f "./examples/test_samples.sh" ]]; then
                    ./examples/test_samples.sh
                else
                    echo "Arquivo de testes não encontrado."
                fi
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            12)
                echo -e "${CYAN}📚 AJUDA${NC}"
                "$SCRIPT_DIR/security_analyzer.sh" --help
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            13)
                echo -e "${CYAN}ℹ️ SOBRE${NC}"
                echo "Security Analyzer Tool v2.0"
                echo "Ferramenta avançada de análise de segurança"
                echo "Desenvolvido por @cybersecwonderwoman"
                echo ""
                echo "Funcionalidades:"
                echo "• Análise de arquivos, URLs, domínios, hashes"
                echo "• Análise de emails e cabeçalhos"
                echo "• Análise de endereços IP"
                echo "• Geração de relatórios HTML"
                echo "• Sistema de logs integrado"
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            0)
                echo -e "${GREEN}Obrigado por usar o Security Analyzer Tool!${NC}"
                echo -e "${PURPLE}@cybersecwonderwoman${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opção inválida! Pressione ENTER para continuar...${NC}"
                read -r
                ;;
        esac
    done
}

# Verificar se está no diretório correto
if [[ ! -f "$SCRIPT_DIR/security_analyzer.sh" ]]; then
    echo -e "${RED}Erro: Execute este menu a partir do diretório da aplicação${NC}"
    echo "Certifique-se de que o arquivo security_analyzer.sh está no mesmo diretório."
    exit 1
fi

# Executar menu principal
main_menu
EOF

chmod +x menu_fixed.sh

# 2. Substituir o menu original
echo "🔄 Substituindo menu original..."
mv menu.sh menu.sh.backup
mv menu_fixed.sh menu.sh

echo ""
echo "✅ Correções aplicadas com sucesso!"
echo ""
echo "🧪 Testando funcionalidades:"

# Testar sintaxe
echo -n "  • Sintaxe do menu: "
if bash -n menu.sh; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERRO${NC}"
fi

echo -n "  • Sintaxe do security_analyzer: "
if bash -n security_analyzer.sh; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERRO${NC}"
fi

echo -n "  • Sintaxe do generate_report: "
if bash -n generate_report.sh; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERRO${NC}"
fi

echo ""
echo "🚀 Para testar:"
echo "  ./menu.sh - Menu interativo"
echo "  ./security_analyzer.sh --ip 8.8.8.8 - Teste direto"
