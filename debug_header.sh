#!/bin/bash

# ========================================
# Script de Diagnóstico para Análise de Cabeçalho
# ========================================

echo "=== DIAGNÓSTICO DE ANÁLISE DE CABEÇALHO ==="
echo ""

# Verificar se foi passado um arquivo
if [[ -z "$1" ]]; then
    echo "Uso: $0 <arquivo_de_cabecalho.txt>"
    echo ""
    echo "Exemplo:"
    echo "  $0 /caminho/para/email_headers.txt"
    echo "  $0 ./examples/sample_email_header.txt"
    exit 1
fi

HEADER_FILE="$1"

echo "Arquivo especificado: $HEADER_FILE"
echo ""

# Teste 1: Verificar se o arquivo existe
echo "1. Verificando se o arquivo existe..."
if [[ -f "$HEADER_FILE" ]]; then
    echo "   ✓ Arquivo existe"
else
    echo "   ✗ Arquivo NÃO existe"
    echo "   Verifique o caminho: $HEADER_FILE"
    exit 1
fi

# Teste 2: Verificar permissões
echo "2. Verificando permissões..."
if [[ -r "$HEADER_FILE" ]]; then
    echo "   ✓ Arquivo é legível"
else
    echo "   ✗ Arquivo NÃO é legível"
    echo "   Execute: chmod +r \"$HEADER_FILE\""
    exit 1
fi

# Teste 3: Verificar se não está vazio
echo "3. Verificando conteúdo..."
if [[ -s "$HEADER_FILE" ]]; then
    echo "   ✓ Arquivo não está vazio"
    echo "   Tamanho: $(wc -c < "$HEADER_FILE") bytes"
    echo "   Linhas: $(wc -l < "$HEADER_FILE")"
else
    echo "   ✗ Arquivo está vazio"
    exit 1
fi

# Teste 4: Verificar formato do arquivo
echo "4. Verificando formato do cabeçalho..."
if grep -qi "^From:\|^To:\|^Subject:\|^Received:\|^Message-ID:" "$HEADER_FILE"; then
    echo "   ✓ Arquivo parece conter cabeçalhos de email válidos"
else
    echo "   ⚠ Arquivo pode não conter cabeçalhos de email válidos"
    echo "   Continuando com a análise..."
fi

# Teste 5: Mostrar primeiras linhas
echo ""
echo "5. Primeiras 10 linhas do arquivo:"
echo "----------------------------------------"
head -10 "$HEADER_FILE"
echo "----------------------------------------"

# Teste 6: Verificar cabeçalhos principais
echo ""
echo "6. Cabeçalhos principais encontrados:"
echo "   From: $(grep -c "^From:" "$HEADER_FILE") ocorrência(s)"
echo "   To: $(grep -c "^To:" "$HEADER_FILE") ocorrência(s)"
echo "   Subject: $(grep -c "^Subject:" "$HEADER_FILE") ocorrência(s)"
echo "   Received: $(grep -c "^Received:" "$HEADER_FILE") ocorrência(s)"
echo "   Message-ID: $(grep -c "^Message-ID:" "$HEADER_FILE") ocorrência(s)"

# Teste 7: Testar a ferramenta
echo ""
echo "7. Testando a ferramenta Security Analyzer..."
echo "----------------------------------------"

if [[ -f "./security_analyzer.sh" ]]; then
    echo "Executando: ./security_analyzer.sh --header \"$HEADER_FILE\""
    echo ""
    ./security_analyzer.sh --header "$HEADER_FILE"
else
    echo "   ✗ security_analyzer.sh não encontrado no diretório atual"
    echo "   Execute este script a partir do diretório /home/anny-ribeiro/amazonQ/app"
fi

echo ""
echo "=== DIAGNÓSTICO CONCLUÍDO ==="
