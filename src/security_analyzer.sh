#!/bin/bash

# ========================================
# Security Analyzer Tool v3.0 - Script Principal
# Ferramenta Avançada de Análise de Segurança
# ========================================

# Configuração inicial
set -euo pipefail  # Modo strict
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carregar configurações e módulos
source "$SCRIPT_DIR/config.conf"
source "$SCRIPT_DIR/utils/security.sh"
source "$SCRIPT_DIR/utils/logger.sh"
source "$SCRIPT_DIR/modules/api_manager.sh"
source "$SCRIPT_DIR/modules/report_generator.sh"
source "$SCRIPT_DIR/analyzers/file_analyzer.sh"
source "$SCRIPT_DIR/analyzers/url_analyzer.sh"

# Cores para interface (se habilitadas)
if [[ "$ENABLE_COLORS" == "true" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' PURPLE='' CYAN='' NC=''
fi

# Inicialização do sistema
initialize_system() {
    log_info "Inicializando Security Analyzer Tool v$APP_VERSION" "MAIN"
    
    # Verificar privilégios
    check_privileges || {
        echo -e "${YELLOW}⚠️  Executando como root não é recomendado por segurança${NC}"
        echo "Deseja continuar? (s/n)"
        read -r continue_choice
        [[ "$continue_choice" =~ ^[Ss]$ ]] || exit 1
    }
    
    # Criar diretórios necessários
    create_secure_directory "$CONFIG_DIR"
    create_secure_directory "$CACHE_DIR"
    create_secure_directory "$REPORTS_DIR"
    create_secure_directory "$TEMP_DIR"
    
    # Inicializar módulos
    init_logging
    init_api_manager
    init_report_generator
    
    # Verificar dependências
    check_system_dependencies
    
    # Limpeza automática
    cleanup_old_reports >/dev/null 2>&1 &
    
    log_info "Sistema inicializado com sucesso" "MAIN"
}

# Verificar dependências do sistema
check_system_dependencies() {
    local missing_deps=()
    local deps=("curl" "jq" "dig" "whois" "file" "openssl" "python3")
    
    log_info "Verificando dependências do sistema..." "MAIN"
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
            log_warn "Dependência não encontrada: $dep" "MAIN"
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Dependências faltando: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}Execute o instalador: ./scripts/install_dependencies.sh${NC}"
        
        echo "Deseja continuar mesmo assim? (s/n)"
        read -r continue_choice
        [[ "$continue_choice" =~ ^[Ss]$ ]] || exit 1
    else
        log_info "Todas as dependências estão disponíveis" "MAIN"
    fi
}

# Exibir banner principal
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
║   ████████╗ ██████╗  ██████╗ ██╗     ██╗   ██╗██████╗  ██████╗              ║
║   ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██║   ██║╚════██╗██╔═══██╗             ║
║      ██║   ██║   ██║██║   ██║██║     ██║   ██║ █████╔╝██║   ██║             ║
║      ██║   ██║   ██║██║   ██║██║      ██╗ ██╔╝ ╚═══██╗██║   ██║             ║
║      ██║   ╚██████╔╝╚██████╔╝███████╗ ╚████╔╝ ██████╔╝╚██████╔╝             ║
║      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝  ╚═══╝  ╚═════╝  ╚═════╝              ║
║                                                                              ║
║                    🛡️  FERRAMENTA AVANÇADA DE SEGURANÇA  🛡️                  ║
║                              Versão $APP_VERSION                                ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${PURPLE}                           $APP_AUTHOR${NC}"
    echo ""
}

# Exibir menu principal
show_main_menu() {
    show_banner
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                              MENU PRINCIPAL                                 ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}  ANÁLISES PRINCIPAIS${NC}"
    echo -e "${GREEN}  [1] 📁 Analisar Arquivo${NC}          - Análise profunda de arquivos"
    echo -e "${GREEN}  [2] 🌐 Analisar URL${NC}             - Verificação completa de URLs"
    echo -e "${GREEN}  [3] 🏠 Analisar Domínio${NC}         - Investigação de domínios"
    echo -e "${GREEN}  [4] 🔢 Analisar Hash${NC}            - Consulta em bases de dados"
    echo -e "${GREEN}  [5] 📧 Analisar Email${NC}           - Verificação de endereços"
    echo -e "${GREEN}  [6] 🌐 Analisar IP${NC}             - Análise de endereços IP"
    echo ""
    echo -e "${BLUE}  CONFIGURAÇÃO E RELATÓRIOS${NC}"
    echo -e "${BLUE}  [7] ⚙️  Configurar APIs${NC}          - Gerenciar chaves de acesso"
    echo -e "${BLUE}  [8] 📊 Relatórios${NC}               - Visualizar relatórios"
    echo -e "${BLUE}  [9] 📈 Estatísticas${NC}             - Ver estatísticas de uso"
    echo -e "${BLUE}  [10] 📝 Logs${NC}                     - Visualizar logs do sistema"
    echo ""
    echo -e "${CYAN}  FERRAMENTAS${NC}"
    echo -e "${CYAN}  [11] 🧪 Executar Testes${NC}         - Testar funcionalidades"
    echo -e "${CYAN}  [12] 🔧 Manutenção${NC}              - Limpeza e otimização"
    echo -e "${CYAN}  [13] 📚 Ajuda${NC}                   - Documentação e suporte"
    echo -e "${CYAN}  [14] ℹ️  Sobre${NC}                   - Informações da ferramenta"
    echo ""
    echo -e "${RED}  [0] 🚪 Sair${NC}                     - Encerrar programa"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ Digite o número da opção desejada:                                          ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -n "➤ "
}
