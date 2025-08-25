#!/bin/bash

source "$(dirname "$(readlink -f "$0")")/html_report.sh"

# Texto simples sem códigos ANSI para testar a formatação
test_text="📁 ANÁLISE DE ARQUIVO

[Informações Básicas]
Nome: example.exe
Tipo: PE32 executable

[Hashes]
MD5: d41d8cd98f00b204e9800998ecf8427e
SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

[VirusTotal] AMEAÇA DETECTADA!
Malicioso: 45 detecções
Suspeito: 12 detecções"

echo "Gerando relatório de teste sem códigos ANSI..."
report_file=$(generate_html_report "Arquivo" "example.exe" "$test_text")

echo "Relatório gerado: $report_file"
echo "Verificando o conteúdo..."

# Mostrar uma parte do arquivo para verificar
echo "--- Trecho do relatório ---"
grep -A 5 -B 5 "Informações Básicas" "$report_file" || echo "Não encontrado"

echo "Abrindo no navegador..."
open_report "$report_file"
