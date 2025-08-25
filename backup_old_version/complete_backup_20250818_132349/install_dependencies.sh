#!/bin/bash

# ========================================
# Script de Instalação de Dependências - Security Analyzer Tool
# ========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                INSTALAÇÃO DE DEPENDÊNCIAS                    ║${NC}"
echo -e "${BLUE}║              Security Analyzer Tool - v2.0                   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detectar sistema operacional
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

echo -e "${YELLOW}Sistema detectado: $OS $VER${NC}"
echo ""

# Função para instalar dependências no Debian/Ubuntu
install_debian() {
    echo -e "${YELLOW}Instalando dependências para Debian/Ubuntu...${NC}"
    echo ""
    
    sudo apt-get update
    sudo apt-get install -y curl jq dnsutils whois file coreutils openssl ca-certificates python3
    
    echo ""
    echo -e "${GREEN}Instalação concluída!${NC}"
}

# Função para instalar dependências no CentOS/RHEL/Fedora
install_redhat() {
    echo -e "${YELLOW}Instalando dependências para CentOS/RHEL/Fedora...${NC}"
    echo ""
    
    sudo dnf install -y curl jq bind-utils whois file coreutils openssl ca-certificates python3
    
    echo ""
    echo -e "${GREEN}Instalação concluída!${NC}"
}

# Função para instalar dependências no Arch Linux
install_arch() {
    echo -e "${YELLOW}Instalando dependências para Arch Linux...${NC}"
    echo ""
    
    sudo pacman -S --noconfirm curl jq bind-tools whois file coreutils openssl ca-certificates python
    
    echo ""
    echo -e "${GREEN}Instalação concluída!${NC}"
}

# Instalar dependências de acordo com o sistema operacional
case "$OS" in
    *Ubuntu*|*Debian*)
        install_debian
        ;;
    *CentOS*|*Red\ Hat*|*Fedora*)
        install_redhat
        ;;
    *Arch*)
        install_arch
        ;;
    *)
        echo -e "${RED}Sistema operacional não suportado: $OS${NC}"
        echo -e "${YELLOW}Por favor, instale manualmente as seguintes dependências:${NC}"
        echo "- curl"
        echo "- jq"
        echo "- dnsutils (ou equivalente para consultas DNS)"
        echo "- whois"
        echo "- file"
        echo "- coreutils"
        echo "- openssl"
        echo "- ca-certificates"
        echo "- python3"
        exit 1
        ;;
esac

# Criar diretórios necessários
echo -e "${YELLOW}Criando diretórios de configuração...${NC}"
mkdir -p "$HOME/.security_analyzer/cache"
mkdir -p "$HOME/.security_analyzer/docs"

# Verificar instalação
echo -e "${YELLOW}Verificando instalação...${NC}"
echo ""

# Lista de dependências
deps=("curl" "jq" "dig" "whois" "file" "md5sum" "sha256sum" "python3")
all_installed=true

for dep in "${deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo -e "${RED}✗ $dep não encontrado${NC}"
        all_installed=false
    else
        echo -e "${GREEN}✓ $dep encontrado${NC}"
    fi
done

echo ""
if $all_installed; then
    echo -e "${GREEN}Todas as dependências foram instaladas com sucesso!${NC}"
    echo -e "${YELLOW}Você pode executar o Security Analyzer Tool agora:${NC}"
    echo -e "${BLUE}./security_tool.sh${NC}"
else
    echo -e "${RED}Algumas dependências não puderam ser instaladas.${NC}"
    echo -e "${YELLOW}Por favor, instale-as manualmente e tente novamente.${NC}"
fi

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                INSTALAÇÃO CONCLUÍDA                          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
