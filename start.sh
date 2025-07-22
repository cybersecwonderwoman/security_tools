#!/bin/bash

# ========================================
# Script de Inicialização - Security Analyzer Tool
# ========================================

# Verificar se está no diretório correto
if [[ ! -f "./security_tool.sh" ]]; then
    echo "Erro: Execute este script a partir do diretório da aplicação"
    echo "cd /home/anny-ribeiro/Documentos/GitHub/security_tools && ./start.sh"
    exit 1
fi

# Executar o menu interativo
./security_tool.sh
