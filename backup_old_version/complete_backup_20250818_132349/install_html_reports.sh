#!/bin/bash

# ========================================
# Instalador da funcionalidade de Relatórios HTML
# para Security Analyzer Tool
# ========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                INSTALADOR DE RELATÓRIOS HTML                                ║
║                  Security Analyzer Tool                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar se estamos no diretório correto
if [[ ! -f "security_tool.sh" ]]; then
    echo -e "${RED}Erro: security_tool.sh não encontrado no diretório atual.${NC}"
    echo "Este script deve ser executado no diretório raiz do Security Analyzer Tool."
    exit 1
fi

echo -e "${BLUE}[1/5]${NC} Verificando dependências..."

# Verificar se o Python está instalado
if command -v python3 &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Python 3 encontrado"
    PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Python 2 encontrado"
    PYTHON_CMD="python"
else
    echo -e "  ${YELLOW}!${NC} Python não encontrado. O servidor web local requer Python."
    echo -e "  ${YELLOW}!${NC} Você ainda pode gerar relatórios, mas precisará abri-los manualmente."
fi

echo -e "${BLUE}[2/5]${NC} Criando diretórios necessários..."

# Criar diretório para templates HTML
mkdir -p html_templates
echo -e "  ${GREEN}✓${NC} Diretório html_templates criado"

# Criar diretório para relatórios
mkdir -p "$HOME/.security_analyzer/reports"
echo -e "  ${GREEN}✓${NC} Diretório de relatórios criado"

echo -e "${BLUE}[3/5]${NC} Verificando arquivos de script..."

# Verificar se os arquivos necessários existem
if [[ ! -f "html_report.sh" ]]; then
    echo -e "  ${RED}✗${NC} html_report.sh não encontrado"
    exit 1
fi

if [[ ! -f "report_integration.sh" ]]; then
    echo -e "  ${RED}✗${NC} report_integration.sh não encontrado"
    exit 1
fi

if [[ ! -f "integration_patch.sh" ]]; then
    echo -e "  ${RED}✗${NC} integration_patch.sh não encontrado"
    exit 1
fi

if [[ ! -f "html_templates/report_template.html" ]]; then
    echo -e "  ${RED}✗${NC} Template HTML não encontrado"
    exit 1
fi

echo -e "  ${GREEN}✓${NC} Todos os arquivos necessários encontrados"

echo -e "${BLUE}[4/5]${NC} Configurando permissões..."

# Dar permissões de execução aos scripts
chmod +x html_report.sh
chmod +x report_integration.sh
chmod +x integration_patch.sh
chmod +x demo_report.sh 2>/dev/null || true

echo -e "  ${GREEN}✓${NC} Permissões configuradas"

echo -e "${BLUE}[5/5]${NC} Aplicando patch de integração..."

# Executar o script de integração
./integration_patch.sh

echo
echo -e "${GREEN}✅ Instalação concluída com sucesso!${NC}"
echo
echo -e "Para testar a funcionalidade de relatórios HTML, você pode:"
echo -e "  1. Executar ${CYAN}./security_tool.sh${NC} e realizar uma análise"
echo -e "  2. Executar ${CYAN}./demo_report.sh${NC} para ver exemplos de relatórios"
echo
echo -e "Os relatórios serão salvos em: ${CYAN}$HOME/.security_analyzer/reports/${NC}"
echo

# Perguntar se deseja executar a demonstração
echo -n "Deseja executar a demonstração agora? (s/n): "
read -r run_demo

if [[ "$run_demo" == "s" || "$run_demo" == "S" ]]; then
    ./demo_report.sh
fi
