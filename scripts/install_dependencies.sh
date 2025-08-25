#!/bin/bash

# ========================================
# Security Analyzer Tool v3.0 - Instalador de Dependências
# Script avançado de instalação e configuração
# ========================================

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Banner de instalação
show_install_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                    SECURITY ANALYZER TOOL v3.0                              ║
║                      INSTALADOR DE DEPENDÊNCIAS                             ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
}

# Detectar sistema operacional
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    elif command -v lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        VERSION=$(lsb_release -sr)
    elif [[ -f /etc/redhat-release ]]; then
        OS="rhel"
        VERSION=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | head -1)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        VERSION=$(sw_vers -productVersion)
    else
        OS="unknown"
        VERSION="unknown"
    fi
    
    echo -e "${BLUE}Sistema detectado: $OS $VERSION${NC}"
    echo ""
}

# Verificar privilégios
check_privileges() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  Executando como root. Isso não é recomendado por segurança.${NC}"
        echo "Deseja continuar? (s/n)"
        read -r continue_as_root
        [[ "$continue_as_root" =~ ^[Ss]$ ]] || exit 1
    fi
}

# Verificar dependências existentes
check_existing_dependencies() {
    echo -e "${YELLOW}Verificando dependências existentes...${NC}"
    echo ""
    
    local deps=("curl" "jq" "dig" "whois" "file" "openssl" "python3" "git")
    local missing_deps=()
    local existing_deps=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            existing_deps+=("$dep")
            echo -e "${GREEN}✓ $dep${NC} - $(command -v "$dep")"
        else
            missing_deps+=("$dep")
            echo -e "${RED}✗ $dep${NC} - não encontrado"
        fi
    done
    
    echo ""
    echo "Dependências encontradas: ${#existing_deps[@]}/${#deps[@]}"
    
    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        echo -e "${GREEN}🎉 Todas as dependências já estão instaladas!${NC}"
        return 0
    else
        echo -e "${YELLOW}Dependências faltando: ${missing_deps[*]}${NC}"
        return 1
    fi
}

# Instalar dependências no Ubuntu/Debian
install_debian_ubuntu() {
    echo -e "${YELLOW}Instalando dependências para Ubuntu/Debian...${NC}"
    echo ""
    
    # Atualizar repositórios
    echo "Atualizando repositórios..."
    sudo apt-get update -qq
    
    # Instalar dependências básicas
    local packages=(
        "curl"
        "jq" 
        "dnsutils"
        "whois"
        "file"
        "openssl"
        "ca-certificates"
        "python3"
        "python3-pip"
        "git"
        "bc"
        "geoip-bin"
        "exiftool"
    )
    
    echo "Instalando pacotes..."
    for package in "${packages[@]}"; do
        echo -n "  Instalando $package... "
        if sudo apt-get install -qq -y "$package" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${YELLOW}⚠${NC}"
        fi
    done
    
    # Instalar ferramentas Python opcionais
    echo ""
    echo "Instalando ferramentas Python opcionais..."
    pip3 install --user requests beautifulsoup4 >/dev/null 2>&1 || true
}

# Instalar dependências no CentOS/RHEL/Fedora
install_redhat_fedora() {
    echo -e "${YELLOW}Instalando dependências para CentOS/RHEL/Fedora...${NC}"
    echo ""
    
    # Detectar gerenciador de pacotes
    local pkg_manager=""
    if command -v dnf >/dev/null 2>&1; then
        pkg_manager="dnf"
    elif command -v yum >/dev/null 2>&1; then
        pkg_manager="yum"
    else
        echo -e "${RED}❌ Gerenciador de pacotes não encontrado${NC}"
        return 1
    fi
    
    echo "Usando $pkg_manager como gerenciador de pacotes"
    
    # Instalar EPEL se necessário
    if [[ "$OS" == "rhel" || "$OS" == "centos" ]]; then
        echo "Instalando repositório EPEL..."
        sudo $pkg_manager install -y epel-release >/dev/null 2>&1 || true
    fi
    
    local packages=(
        "curl"
        "jq"
        "bind-utils"
        "whois"
        "file"
        "openssl"
        "ca-certificates"
        "python3"
        "python3-pip"
        "git"
        "bc"
        "GeoIP"
        "perl-Image-ExifTool"
    )
    
    echo "Instalando pacotes..."
    for package in "${packages[@]}"; do
        echo -n "  Instalando $package... "
        if sudo $pkg_manager install -y "$package" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${YELLOW}⚠${NC}"
        fi
    done
}

# Instalar dependências no Arch Linux
install_arch() {
    echo -e "${YELLOW}Instalando dependências para Arch Linux...${NC}"
    echo ""
    
    # Atualizar sistema
    echo "Atualizando sistema..."
    sudo pacman -Sy --noconfirm >/dev/null 2>&1
    
    local packages=(
        "curl"
        "jq"
        "bind-tools"
        "whois"
        "file"
        "openssl"
        "ca-certificates"
        "python"
        "python-pip"
        "git"
        "bc"
        "geoip"
        "perl-image-exiftool"
    )
    
    echo "Instalando pacotes..."
    for package in "${packages[@]}"; do
        echo -n "  Instalando $package... "
        if sudo pacman -S --noconfirm "$package" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${YELLOW}⚠${NC}"
        fi
    done
}

# Instalar dependências no macOS
install_macos() {
    echo -e "${YELLOW}Instalando dependências para macOS...${NC}"
    echo ""
    
    # Verificar se Homebrew está instalado
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew não encontrado. Instalando..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    local packages=(
        "curl"
        "jq"
        "bind"
        "whois"
        "file"
        "openssl"
        "python3"
        "git"
        "geoip"
        "exiftool"
    )
    
    echo "Instalando pacotes via Homebrew..."
    for package in "${packages[@]}"; do
        echo -n "  Instalando $package... "
        if brew install "$package" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${YELLOW}⚠${NC}"
        fi
    done
}

# Configurar ambiente
setup_environment() {
    echo -e "${YELLOW}Configurando ambiente...${NC}"
    echo ""
    
    # Criar diretórios necessários
    local config_dir="$HOME/.security_analyzer"
    echo "Criando diretórios de configuração..."
    
    mkdir -p "$config_dir"/{cache,reports,docs,temp}
    chmod 700 "$config_dir"
    
    echo -e "${GREEN}✓${NC} Diretórios criados em: $config_dir"
    
    # Criar arquivo de configuração inicial se não existir
    local config_file="$config_dir/user_config.conf"
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << EOF
# Security Analyzer Tool - Configuração do Usuário
# Criado em: $(date)

# Configurações personalizadas
ENABLE_COLORS=true
ENABLE_ANIMATIONS=true
DEFAULT_REPORT_FORMAT=html
AUTO_CLEANUP=true

# Configurações de rede
CONNECTION_TIMEOUT=10
API_RATE_LIMIT=4

# Configurações de relatórios
REPORTS_RETENTION_DAYS=30
LOG_RETENTION_DAYS=90
EOF
        echo -e "${GREEN}✓${NC} Arquivo de configuração criado"
    fi
    
    # Verificar permissões
    echo "Verificando permissões..."
    if [[ -w "$config_dir" ]]; then
        echo -e "${GREEN}✓${NC} Permissões adequadas"
    else
        echo -e "${RED}❌${NC} Problemas de permissão detectados"
        return 1
    fi
}

# Verificar instalação
verify_installation() {
    echo -e "${YELLOW}Verificando instalação...${NC}"
    echo ""
    
    local deps=("curl" "jq" "dig" "whois" "file" "openssl" "python3")
    local failed_deps=()
    
    for dep in "${deps[@]}"; do
        echo -n "Verificando $dep... "
        if command -v "$dep" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}❌${NC}"
            failed_deps+=("$dep")
        fi
    done
    
    echo ""
    
    if [[ ${#failed_deps[@]} -eq 0 ]]; then
        echo -e "${GREEN}🎉 Instalação concluída com sucesso!${NC}"
        echo ""
        echo -e "${CYAN}Próximos passos:${NC}"
        echo "1. Execute: cd $PROJECT_ROOT/src"
        echo "2. Execute: ./security_analyzer_complete.sh"
        echo "3. Configure suas APIs no menu de configuração"
        echo ""
        return 0
    else
        echo -e "${RED}❌ Instalação incompleta. Dependências faltando: ${failed_deps[*]}${NC}"
        echo ""
        echo -e "${YELLOW}Tente instalar manualmente:${NC}"
        for dep in "${failed_deps[@]}"; do
            echo "  - $dep"
        done
        return 1
    fi
}

# Função principal
main() {
    show_install_banner
    
    echo -e "${BLUE}Iniciando instalação do Security Analyzer Tool v3.0${NC}"
    echo ""
    
    # Verificar privilégios
    check_privileges
    
    # Detectar sistema operacional
    detect_os
    
    # Verificar dependências existentes
    if check_existing_dependencies; then
        echo ""
        echo "Deseja prosseguir com a configuração do ambiente? (s/n)"
        read -r setup_env
        
        if [[ "$setup_env" =~ ^[Ss]$ ]]; then
            setup_environment
            verify_installation
        fi
        return 0
    fi
    
    echo ""
    echo "Deseja instalar as dependências faltando? (s/n)"
    read -r install_deps
    
    if [[ ! "$install_deps" =~ ^[Ss]$ ]]; then
        echo "Instalação cancelada pelo usuário"
        exit 0
    fi
    
    echo ""
    
    # Instalar dependências baseado no OS
    case "$OS" in
        "ubuntu"|"debian")
            install_debian_ubuntu
            ;;
        "rhel"|"centos"|"fedora")
            install_redhat_fedora
            ;;
        "arch"|"manjaro")
            install_arch
            ;;
        "macos")
            install_macos
            ;;
        *)
            echo -e "${RED}❌ Sistema operacional não suportado: $OS${NC}"
            echo ""
            echo -e "${YELLOW}Instale manualmente as seguintes dependências:${NC}"
            echo "- curl, jq, dig, whois, file, openssl, python3, git"
            exit 1
            ;;
    esac
    
    echo ""
    
    # Configurar ambiente
    setup_environment
    
    # Verificar instalação final
    verify_installation
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
