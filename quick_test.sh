#!/bin/bash

# Teste rápido da formatação corrigida

source "$(dirname "$(readlink -f "$0")")/html_report.sh"

# Texto de teste com códigos ANSI
test_text="␛[0;36m📁 ANÁLISE DE ARQUIVO␛[0m

␛[0;34m[Informações Básicas]␛[0m
Nome: example.exe
Tipo: PE32 executable

␛[0;34m[Hashes]␛[0m
MD5: d41d8cd98f00b204e9800998ecf8427e
SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

␛[0;31m[VirusTotal] AMEAÇA DETECTADA!␛[0m
Malicioso: 45 detecções"

echo "Gerando relatório de teste..."
report_file=$(generate_html_report "Arquivo" "example.exe" "$test_text")

echo "Relatório gerado: $report_file"
echo "Verificando se os códigos ANSI foram removidos..."

# Verificar se ainda há códigos ANSI no arquivo
if grep -q "␛\|\\x1B\|\\033" "$report_file"; then
    echo "❌ ERRO: Ainda há códigos ANSI no relatório"
else
    echo "✅ SUCESSO: Códigos ANSI foram removidos corretamente"
fi

echo "Abrindo relatório no navegador..."
open_report "$report_file"
