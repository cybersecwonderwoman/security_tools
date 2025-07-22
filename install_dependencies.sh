#!/bin/bash

# ========================================
# Instalador de Dependências - Security Analyzer Tool
# ========================================

echo "=== Instalador de Dependências - Security Analyzer Tool ==="
echo ""

# Detectar distribuição Linux
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO=$ID
else
    echo "Não foi possível detectar a distribuição Linux"
    exit 1
fi

echo "Distribuição detectada: $DISTRO"
echo ""

# Função para instalar no Ubuntu/Debian
install_ubuntu_debian() {
    echo "Atualizando repositórios..."
    sudo apt-get update

    echo "Instalando dependências básicas..."
    sudo apt-get install -y \
        curl \
        jq \
        dnsutils \
        whois \
        file \
        coreutils \
        openssl \
        ca-certificates \
        wget \
        unzip

    echo "Instalando ferramentas adicionais de segurança..."
    sudo apt-get install -y \
        nmap \
        netcat \
        tcpdump \
        wireshark-common \
        hashdeep \
        ssdeep \
        yara \
        clamav \
        rkhunter \
        chkrootkit

    # Atualizar base do ClamAV
    echo "Atualizando base de dados do ClamAV..."
    sudo freshclam || echo "Aviso: Não foi possível atualizar o ClamAV"
}

# Função para instalar no CentOS/RHEL/Fedora
install_redhat() {
    echo "Instalando dependências básicas..."
    
    if command -v dnf &> /dev/null; then
        # Fedora/CentOS 8+
        sudo dnf install -y \
            curl \
            jq \
            bind-utils \
            whois \
            file \
            coreutils \
            openssl \
            ca-certificates \
            wget \
            unzip
            
        sudo dnf install -y \
            nmap \
            netcat \
            tcpdump \
            wireshark-cli \
            clamav \
            rkhunter
    else
        # CentOS 7/RHEL 7
        sudo yum install -y epel-release
        sudo yum install -y \
            curl \
            jq \
            bind-utils \
            whois \
            file \
            coreutils \
            openssl \
            ca-certificates \
            wget \
            unzip \
            nmap \
            netcat \
            tcpdump \
            clamav \
            rkhunter
    fi
}

# Função para instalar no Arch Linux
install_arch() {
    echo "Instalando dependências básicas..."
    sudo pacman -Sy --noconfirm \
        curl \
        jq \
        bind-tools \
        whois \
        file \
        coreutils \
        openssl \
        ca-certificates \
        wget \
        unzip \
        nmap \
        netcat \
        tcpdump \
        wireshark-cli \
        clamav \
        rkhunter
}

# Instalar dependências baseado na distribuição
case "$DISTRO" in
    ubuntu|debian)
        install_ubuntu_debian
        ;;
    centos|rhel|fedora)
        install_redhat
        ;;
    arch|manjaro)
        install_arch
        ;;
    *)
        echo "Distribuição não suportada automaticamente: $DISTRO"
        echo "Instale manualmente as seguintes dependências:"
        echo "- curl, jq, dig, whois, file, sha256sum, md5sum"
        echo "- nmap, netcat, tcpdump (opcionais)"
        exit 1
        ;;
esac

# Verificar instalação
echo ""
echo "Verificando instalação das dependências..."

DEPS=("curl" "jq" "dig" "whois" "file" "sha256sum" "md5sum")
MISSING=()

for dep in "${DEPS[@]}"; do
    if command -v "$dep" &> /dev/null; then
        echo "✓ $dep instalado"
    else
        echo "✗ $dep NÃO encontrado"
        MISSING+=("$dep")
    fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo ""
    echo "✓ Todas as dependências foram instaladas com sucesso!"
    echo ""
    echo "Para configurar as chaves de API, execute:"
    echo "  ./security_analyzer.sh --config"
    echo ""
    echo "Para testar a ferramenta:"
    echo "  ./security_analyzer.sh --help"
else
    echo ""
    echo "✗ Algumas dependências não foram instaladas: ${MISSING[*]}"
    echo "Instale-as manualmente antes de usar a ferramenta."
    exit 1
fi

# Criar link simbólico para facilitar o uso
if [[ ! -L /usr/local/bin/security-analyzer ]]; then
    echo "Criando link simbólico em /usr/local/bin..."
    sudo ln -sf "$(pwd)/security_analyzer.sh" /usr/local/bin/security-analyzer
    echo "Agora você pode usar: security-analyzer --help"
fi

echo ""
echo "Instalação concluída!"
