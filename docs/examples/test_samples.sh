#!/bin/bash

# ========================================
# Exemplos de Teste - Security Analyzer Tool
# ========================================

echo "=== Exemplos de Teste - Security Analyzer Tool ==="
echo ""

# Caminho para o script principal
SCRIPT_PATH="$(dirname "$0")/../security_analyzer.sh"

echo "1. Testando análise de hash conhecido (EICAR test file)"
echo "Hash MD5 do arquivo de teste EICAR: 44d88612fea8a8f36de82e1278abb02f"
echo ""
$SCRIPT_PATH -h 44d88612fea8a8f36de82e1278abb02f
echo ""
echo "=================================================="
echo ""

echo "2. Testando análise de domínio suspeito"
echo "Domínio: malware.wicar.org (domínio de teste)"
echo ""
$SCRIPT_PATH -d malware.wicar.org
echo ""
echo "=================================================="
echo ""

echo "3. Testando análise de URL"
echo "URL: http://malware.wicar.org/data/eicar.com"
echo ""
$SCRIPT_PATH -u http://malware.wicar.org/data/eicar.com
echo ""
echo "=================================================="
echo ""

echo "4. Testando análise de email"
echo "Email: test@malware.wicar.org"
echo ""
$SCRIPT_PATH -e test@malware.wicar.org
echo ""
echo "=================================================="
echo ""

echo "5. Criando arquivo de teste para análise"
# Criar arquivo EICAR para teste (inofensivo)
EICAR_STRING='X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
echo "$EICAR_STRING" > /tmp/eicar_test.txt

echo "Arquivo de teste criado: /tmp/eicar_test.txt"
echo "Analisando arquivo..."
echo ""
$SCRIPT_PATH -f /tmp/eicar_test.txt
echo ""

# Limpar arquivo de teste
rm -f /tmp/eicar_test.txt
echo "Arquivo de teste removido."
echo ""
echo "=================================================="
echo ""

echo "Testes concluídos!"
echo "Verifique os logs em: ~/.security_analyzer/analysis.log"
