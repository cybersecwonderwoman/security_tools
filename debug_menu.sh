#!/bin/bash

# Debug do menu

echo "Digite uma opção:"
read -r choice

echo "Você digitou: '$choice'"
echo "Tamanho da string: ${#choice}"

case $choice in
    7) echo "Opção 7 funcionou!" ;;
    *) echo "Opção '$choice' não reconhecida" ;;
esac
