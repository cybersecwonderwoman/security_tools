#!/bin/bash

# ========================================
# Script de Inicialização - Security Analyzer Tool
# ========================================

# Verificar se está no diretório correto
if [[ ! -f "./security_analyzer.sh" ]]; then
    echo "Erro: Execute este script a partir do diretório da aplicação"
    echo "cd /home/anny-ribeiro/amazonQ/app && ./start.sh"
    exit 1
fi

# Função para exibir banner de boas-vindas
show_welcome_banner() {
    clear
    echo -e "\033[0;36m"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║   ███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗            ║
║   ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝            ║
║   ███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝             ║
║   ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝              ║
║   ███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║               ║
║   ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝               ║
║                                                                              ║
║   ████████╗ ██████╗  ██████╗ ██╗                                            ║
║   ╚══██╔══╝██╔═══██╗██╔═══██╗██║                                            ║
║      ██║   ██║   ██║██║   ██║██║                                            ║
║      ██║   ██║   ██║██║   ██║██║                                            ║
║      ██║   ╚██████╔╝╚██████╔╝███████╗                                       ║
║      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝                                       ║
║                                                                              ║
║                    🛡️  FERRAMENTA AVANÇADA DE SEGURANÇA  🛡️                  ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "\033[0m"
    
    echo -e "\033[0;35m                           @cybersecwonderwoman\033[0m"
    echo ""
    echo -e "\033[1;33m╔══════════════════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;33m║                            MODO DE EXECUÇÃO                                 ║\033[0m"
    echo -e "\033[1;33m╚══════════════════════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
    
    echo -e "\033[0;32m  [1] 🎯 Menu Interativo\033[0m       - Interface amigável com menu"
    echo -e "\033[0;32m  [2] ⚡ Linha de Comando\033[0m      - Uso direto com parâmetros"
    echo -e "\033[0;32m  [3] 📚 Ajuda\033[0m                - Ver opções disponíveis"
    echo -e "\033[0;32m  [4] 🧪 Executar Testes\033[0m       - Testar funcionalidades"
    echo ""
    echo -e "\033[0;31m  [0] 🚪 Sair\033[0m"
    echo ""
    echo -e "\033[1;33m╔══════════════════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;33m║ Digite o número da opção desejada:                                          ║\033[0m"
    echo -e "\033[1;33m╚══════════════════════════════════════════════════════════════════════════════╝\033[0m"
    echo -n -e "\033[1;37m➤ \033[0m"
}

# Função para modo linha de comando
command_line_mode() {
    clear
    echo -e "\033[0;34m⚡ MODO LINHA DE COMANDO\033[0m"
    echo ""
    echo "Exemplos de uso:"
    echo ""
    echo -e "\033[0;32m# Analisar arquivo:\033[0m"
    echo "./security_analyzer.sh -f /path/to/file.exe"
    echo ""
    echo -e "\033[0;32m# Analisar URL:\033[0m"
    echo "./security_analyzer.sh -u https://suspicious-site.com"
    echo ""
    echo -e "\033[0;32m# Analisar domínio:\033[0m"
    echo "./security_analyzer.sh -d malicious-domain.com"
    echo ""
    echo -e "\033[0;32m# Analisar hash:\033[0m"
    echo "./security_analyzer.sh -h 5d41402abc4b2a76b9719d911017c592"
    echo ""
    echo -e "\033[0;32m# Ver todas as opções:\033[0m"
    echo "./security_analyzer.sh --help"
    echo ""
    echo "Digite seu comando (ou 'menu' para voltar ao menu, 'exit' para sair):"
    echo -n "➤ "
    
    while read -r command; do
        case "$command" in
            "menu")
                return 0
                ;;
            "exit")
                echo -e "\033[0;32mObrigado por usar o Security Analyzer Tool!\033[0m"
                echo -e "\033[0;35m@cybersecwonderwoman\033[0m"
                exit 0
                ;;
            "")
                echo -n "➤ "
                continue
                ;;
            *)
                echo ""
                eval "$command"
                echo ""
                echo "Digite outro comando (ou 'menu' para voltar, 'exit' para sair):"
                echo -n "➤ "
                ;;
        esac
    done
}

# Função principal
main() {
    # Se argumentos foram passados, executar diretamente
    if [[ $# -gt 0 ]]; then
        ./security_analyzer.sh "$@"
        exit $?
    fi
    
    # Caso contrário, mostrar menu de seleção
    while true; do
        show_welcome_banner
        read -r choice
        
        case $choice in
            1)
                ./menu.sh
                ;;
            2)
                command_line_mode
                ;;
            3)
                clear
                ./security_analyzer.sh --help
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            4)
                clear
                if [[ -f "./examples/test_samples.sh" ]]; then
                    ./examples/test_samples.sh
                else
                    echo "Arquivo de testes não encontrado."
                fi
                echo ""
                echo "Pressione ENTER para continuar..."
                read -r
                ;;
            0)
                echo -e "\033[0;32mObrigado por usar o Security Analyzer Tool!\033[0m"
                echo -e "\033[0;35m@cybersecwonderwoman\033[0m"
                exit 0
                ;;
            *)
                echo -e "\033[0;31mOpção inválida! Pressione ENTER para continuar...\033[0m"
                read -r
                ;;
        esac
    done
}

# Executar função principal
main "$@"
