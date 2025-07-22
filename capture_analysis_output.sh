#!/bin/bash

# Script para modificar as funções de análise para capturar a saída

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Adicionar função para capturar saída
cat >> "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" << 'EOF'

# Função para capturar saída da análise
capture_output() {
    local output_file=$(mktemp)
    exec 3>&1 4>&2
    exec > >(tee "$output_file") 2>&1
    
    # Executar o comando
    "$@"
    
    # Restaurar stdout e stderr
    exec 1>&3 2>&4
    
    # Ler o conteúdo do arquivo temporário
    analysis_output=$(cat "$output_file")
    
    # Remover arquivo temporário
    rm -f "$output_file"
}
EOF

# Modificar a função main para usar capture_output
sed -i '/^main() {/,/^}/ s/case "$1" in/# Preparar para capturar saída\n    local output_file=$(mktemp)\n    exec 3>&1 4>&2\n    exec > >(tee "$output_file") 2>&1\n    \n    case "$1" in/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função main para ler a saída capturada
sed -i '/^main() {/,/^}/ s/echo -e "\\n${GREEN}Análise concluída. Log salvo em: $LOG_FILE${NC}"/# Restaurar stdout e stderr\n    exec 1>&3 2>&4\n    \n    # Ler o conteúdo do arquivo temporário\n    analysis_output=$(cat "$output_file")\n    \n    # Remover arquivo temporário\n    rm -f "$output_file"\n    \n    echo -e "\\n${GREEN}Análise concluída. Log salvo em: $LOG_FILE${NC}"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Captura de saída configurada com sucesso!"
