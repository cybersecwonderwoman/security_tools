#!/bin/bash

# Script para verificar se todos os arquivos necessários para a análise de IP estão presentes e têm permissões de execução

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório da aplicação
APP_DIR="/home/anny-ribeiro/amazonQ/app"

# Lista de arquivos necessários
REQUIRED_FILES=(
    "menu.sh"
    "run_ip_analysis.sh"
    "ip_analyzer_tool.sh"
    "generate_report.sh"
)

echo "Verificando configuração da análise de IP..."
echo ""

# Verificar se os arquivos existem e têm permissões de execução
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$APP_DIR/$file" ]; then
        echo -e "${GREEN}✓ $file encontrado${NC}"
        
        if [ -x "$APP_DIR/$file" ]; then
            echo -e "  ${GREEN}✓ $file tem permissão de execução${NC}"
        else
            echo -e "  ${RED}✗ $file não tem permissão de execução${NC}"
            echo -e "  ${YELLOW}Corrigindo...${NC}"
            chmod +x "$APP_DIR/$file"
            echo -e "  ${GREEN}✓ Permissão de execução adicionada a $file${NC}"
        fi
    else
        echo -e "${RED}✗ $file não encontrado${NC}"
    fi
    echo ""
done

# Verificar se o diretório de relatórios existe
REPORTS_DIR="$HOME/.security_analyzer/reports"
if [ -d "$REPORTS_DIR" ]; then
    echo -e "${GREEN}✓ Diretório de relatórios encontrado: $REPORTS_DIR${NC}"
else
    echo -e "${RED}✗ Diretório de relatórios não encontrado${NC}"
    echo -e "${YELLOW}Criando diretório de relatórios...${NC}"
    mkdir -p "$REPORTS_DIR"
    echo -e "${GREEN}✓ Diretório de relatórios criado: $REPORTS_DIR${NC}"
fi

echo ""
echo "Verificação concluída!"
echo "A funcionalidade de análise de IP deve estar funcionando corretamente agora."
