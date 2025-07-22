#!/bin/bash

# Script de teste para verificar o case statement

choice="7"

case $choice in
    1) echo "Opção 1 selecionada" ;;
    2) echo "Opção 2 selecionada" ;;
    3) echo "Opção 3 selecionada" ;;
    4) echo "Opção 4 selecionada" ;;
    5) echo "Opção 5 selecionada" ;;
    6) echo "Opção 6 selecionada" ;;
    7) echo "Opção 7 selecionada - Análise de IP" ;;
    8) echo "Opção 8 selecionada" ;;
    9) echo "Opção 9 selecionada" ;;
    10) echo "Opção 10 selecionada" ;;
    11) echo "Opção 11 selecionada" ;;
    12) echo "Opção 12 selecionada" ;;
    13) echo "Opção 13 selecionada" ;;
    0) echo "Sair" ;;
    *) echo "Opção inválida: $choice" ;;
esac
