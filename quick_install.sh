#!/bin/bash

# Script de instalação rápida do Security Tools

echo "🛡️  Security Tools - Instalação Rápida"
echo ""

# Verificar se está no diretório correto
if [ ! -f "menu.sh" ] || [ ! -f "security_analyzer.sh" ]; then
    echo "❌ Erro: Execute este script no diretório do Security Tools"
    exit 1
fi

# Instalar dependências
echo "📦 Instalando dependências..."
if [ -f "install_dependencies.sh" ]; then
    chmod +x install_dependencies.sh
    ./install_dependencies.sh
else
    echo "⚠️  Script de dependências não encontrado, instalando manualmente..."
    
    # Detectar sistema operacional
    if command -v apt-get > /dev/null; then
        sudo apt-get update
        sudo apt-get install -y curl wget python3 whois dnsutils
    elif command -v yum > /dev/null; then
        sudo yum install -y curl wget python3 whois bind-utils
    elif command -v brew > /dev/null; then
        brew install curl wget python3 whois
    else
        echo "⚠️  Sistema não suportado automaticamente. Instale manualmente:"
        echo "   - curl, wget, python3, whois, dig"
    fi
fi

# Configurar permissões
echo "🔧 Configurando permissões..."
chmod +x *.sh
chmod +x examples/*.sh 2>/dev/null || true

# Criar diretórios necessários
echo "📁 Criando diretórios..."
mkdir -p ~/.security_analyzer/{reports,cache}

echo ""
echo "✅ Instalação concluída!"
echo ""
echo "🚀 Para iniciar, execute:"
echo "   ./start.sh"
echo ""
echo "📚 Para ver o menu interativo:"
echo "   ./menu.sh"
