#!/bin/bash

# ========================================
# Security Analyzer Tool v3.0 - Launcher
# Script de inicialização principal
# ========================================

set -euo pipefail

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
MAIN_SCRIPT="$SRC_DIR/security_analyzer_complete.sh"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner de inicialização
show_startup_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                    SECURITY ANALYZER TOOL v3.0                              ║
║                         INICIANDO SISTEMA...                                ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
}

# Verificar estrutura do projeto
check_project_structure() {
    echo -e "${YELLOW}Verificando estrutura do projeto...${NC}"
    
    local required_dirs=("src" "src/modules" "src/analyzers" "src/utils" "scripts")
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$SCRIPT_DIR/$dir" ]]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Estrutura de projeto incompleta${NC}"
        echo "Diretórios faltando: ${missing_dirs[*]}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Estrutura do projeto OK${NC}"
    return 0
}

# Verificar script principal
check_main_script() {
    echo -e "${YELLOW}Verificando script principal...${NC}"
    
    if [[ ! -f "$MAIN_SCRIPT" ]]; then
        echo -e "${RED}❌ Script principal não encontrado: $MAIN_SCRIPT${NC}"
        return 1
    fi
    
    if [[ ! -x "$MAIN_SCRIPT" ]]; then
        echo -e "${YELLOW}⚠️  Corrigindo permissões do script principal...${NC}"
        chmod +x "$MAIN_SCRIPT"
    fi
    
    # Verificar sintaxe
    if bash -n "$MAIN_SCRIPT" 2>/dev/null; then
        echo -e "${GREEN}✓ Script principal OK${NC}"
        return 0
    else
        echo -e "${RED}❌ Erro de sintaxe no script principal${NC}"
        return 1
    fi
}

# Verificar dependências básicas
check_basic_dependencies() {
    echo -e "${YELLOW}Verificando dependências básicas...${NC}"
    
    local deps=("bash" "curl" "python3")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Dependências básicas faltando: ${missing_deps[*]}${NC}"
        echo ""
        echo -e "${YELLOW}Execute o instalador:${NC}"
        echo "./scripts/install_dependencies.sh"
        return 1
    fi
    
    echo -e "${GREEN}✓ Dependências básicas OK${NC}"
    return 0
}

# Verificar configuração
check_configuration() {
    echo -e "${YELLOW}Verificando configuração...${NC}"
    
    local config_dir="$HOME/.security_analyzer"
    
    if [[ ! -d "$config_dir" ]]; then
        echo -e "${YELLOW}⚠️  Diretório de configuração não encontrado${NC}"
        echo "Criando estrutura de configuração..."
        
        mkdir -p "$config_dir"/{cache,reports,docs,temp}
        chmod 700 "$config_dir"
        
        echo -e "${GREEN}✓ Estrutura de configuração criada${NC}"
    else
        echo -e "${GREEN}✓ Configuração OK${NC}"
    fi
    
    return 0
}

# Mostrar informações do sistema
show_system_info() {
    echo ""
    echo -e "${CYAN}📊 INFORMAÇÕES DO SISTEMA${NC}"
    echo "========================="
    echo "Sistema: $(uname -s) $(uname -r)"
    echo "Arquitetura: $(uname -m)"
    echo "Usuário: $USER"
    echo "Diretório: $SCRIPT_DIR"
    echo "Shell: $SHELL"
    echo ""
}

# Verificar atualizações (simulado)
check_updates() {
    echo -e "${YELLOW}Verificando atualizações...${NC}"
    
    # Simular verificação de atualizações
    sleep 1
    
    echo -e "${GREEN}✓ Versão atual é a mais recente${NC}"
}

# Função principal
main() {
    show_startup_banner
    
    echo -e "${BLUE}🚀 Iniciando Security Analyzer Tool v3.0${NC}"
    echo ""
    
    # Verificações pré-execução
    local checks_passed=0
    local total_checks=5
    
    # 1. Verificar estrutura do projeto
    if check_project_structure; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # 2. Verificar script principal
    if check_main_script; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # 3. Verificar dependências básicas
    if check_basic_dependencies; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # 4. Verificar configuração
    if check_configuration; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # 5. Verificar atualizações
    if check_updates; then
        checks_passed=$((checks_passed + 1))
    fi
    
    echo ""
    echo "Verificações concluídas: $checks_passed/$total_checks"
    
    if [[ $checks_passed -eq $total_checks ]]; then
        echo -e "${GREEN}🎉 Todas as verificações passaram!${NC}"
        
        # Mostrar informações do sistema
        show_system_info
        
        echo -e "${CYAN}Iniciando aplicação em 3 segundos...${NC}"
        sleep 3
        
        # Executar script principal
        exec "$MAIN_SCRIPT"
        
    elif [[ $checks_passed -ge 3 ]]; then
        echo -e "${YELLOW}⚠️  Algumas verificações falharam, mas a aplicação pode funcionar${NC}"
        echo ""
        echo "Deseja continuar mesmo assim? (s/n)"
        read -r continue_anyway
        
        if [[ "$continue_anyway" =~ ^[Ss]$ ]]; then
            echo ""
            echo -e "${CYAN}Iniciando aplicação...${NC}"
            exec "$MAIN_SCRIPT"
        else
            echo "Inicialização cancelada"
            exit 1
        fi
        
    else
        echo -e "${RED}❌ Muitas verificações falharam. Não é possível iniciar a aplicação${NC}"
        echo ""
        echo -e "${YELLOW}Recomendações:${NC}"
        echo "1. Execute o instalador: ./scripts/install_dependencies.sh"
        echo "2. Verifique as permissões dos arquivos"
        echo "3. Certifique-se de que está no diretório correto"
        echo ""
        exit 1
    fi
}

# Tratamento de sinais
trap 'echo -e "\n${YELLOW}Inicialização interrompida${NC}"; exit 130' INT TERM

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
