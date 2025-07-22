#!/bin/bash

# Script para corrigir o diretório de relatórios

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Corrigir a criação do diretório de relatórios
sed -i 's/REPORTS_DIR="$CONFIG_DIR\/reports"/REPORTS_DIR="$CONFIG_DIR\/reports"\nmkdir -p "$REPORTS_DIR"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Verificar se o diretório existe e criar se necessário
mkdir -p "$HOME/.security_analyzer/reports"
chmod 755 "$HOME/.security_analyzer/reports"

echo "Diretório de relatórios corrigido com sucesso!"
