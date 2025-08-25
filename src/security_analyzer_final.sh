# ========================================
# Security Analyzer Tool v3.0 - Parte Final
# Loop principal e funções de suporte
# ========================================

# Executar testes do sistema
run_system_tests() {
    clear
    echo -e "${CYAN}🧪 EXECUTANDO TESTES DO SISTEMA${NC}"
    echo "==============================="
    echo ""
    
    local tests_passed=0
    local tests_total=0
    
    # Teste 1: Verificar dependências
    echo -n "Teste 1: Dependências do sistema... "
    tests_total=$((tests_total + 1))
    
    local missing_deps=()
    local deps=("curl" "jq" "dig" "whois" "file" "openssl" "python3")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}❌ FALHOU (faltando: ${missing_deps[*]})${NC}"
    fi
    
    # Teste 2: Verificar diretórios
    echo -n "Teste 2: Estrutura de diretórios... "
    tests_total=$((tests_total + 1))
    
    if [[ -d "$CONFIG_DIR" && -d "$CACHE_DIR" && -d "$REPORTS_DIR" ]]; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}❌ FALHOU${NC}"
    fi
    
    # Teste 3: Verificar permissões
    echo -n "Teste 3: Permissões de arquivos... "
    tests_total=$((tests_total + 1))
    
    if [[ -w "$CONFIG_DIR" && -w "$CACHE_DIR" && -w "$REPORTS_DIR" ]]; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}❌ FALHOU${NC}"
    fi
    
    # Teste 4: Verificar módulos
    echo -n "Teste 4: Carregamento de módulos... "
    tests_total=$((tests_total + 1))
    
    if declare -f generate_html_report >/dev/null 2>&1 && \
       declare -f analyze_file >/dev/null 2>&1 && \
       declare -f analyze_url >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}❌ FALHOU${NC}"
    fi
    
    # Teste 5: Teste de conectividade
    echo -n "Teste 5: Conectividade de rede... "
    tests_total=$((tests_total + 1))
    
    if curl -s --connect-timeout 5 "https://www.google.com" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${YELLOW}⚠️  AVISO (sem conectividade)${NC}"
    fi
    
    echo ""
    echo "Resultado dos testes: $tests_passed/$tests_total passaram"
    
    if [[ $tests_passed -eq $tests_total ]]; then
        echo -e "${GREEN}🎉 Todos os testes passaram! Sistema funcionando perfeitamente.${NC}"
    elif [[ $tests_passed -ge $((tests_total * 3 / 4)) ]]; then
        echo -e "${YELLOW}⚠️  A maioria dos testes passou. Sistema funcional com limitações.${NC}"
    else
        echo -e "${RED}❌ Muitos testes falharam. Sistema pode não funcionar corretamente.${NC}"
    fi
}

# Mostrar informações sobre a ferramenta
show_about() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                              SOBRE A FERRAMENTA                             ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
    echo -e "${BLUE}🛡️  Security Analyzer Tool${NC}"
    echo -e "${BLUE}Versão: $APP_VERSION${NC}"
    echo -e "${BLUE}Desenvolvido por: $APP_AUTHOR${NC}"
    echo ""
    echo -e "${YELLOW}📋 DESCRIÇÃO${NC}"
    echo "Ferramenta avançada de análise de segurança da informação que integra"
    echo "múltiplas fontes de threat intelligence para detectar arquivos maliciosos,"
    echo "URLs perigosas, domínios suspeitos e atividades de phishing."
    echo ""
    echo -e "${YELLOW}✨ PRINCIPAIS FUNCIONALIDADES${NC}"
    echo "• Análise profunda de arquivos com múltiplos algoritmos de hash"
    echo "• Verificação completa de URLs com análise de certificados SSL"
    echo "• Investigação de domínios com consultas DNS e WHOIS"
    echo "• Integração com APIs de threat intelligence (VirusTotal, URLScan, etc.)"
    echo "• Geração de relatórios HTML profissionais"
    echo "• Sistema de logging avançado e auditoria"
    echo "• Criptografia de chaves de API para segurança"
    echo ""
    echo -e "${YELLOW}🔧 TECNOLOGIAS UTILIZADAS${NC}"
    echo "• Bash Script para máxima compatibilidade"
    echo "• OpenSSL para criptografia"
    echo "• cURL para comunicação com APIs"
    echo "• jq para processamento JSON"
    echo "• Python3 para servidor web de relatórios"
    echo ""
    echo -e "${YELLOW}📊 ESTATÍSTICAS DESTA SESSÃO${NC}"
    local session_analyses=$(grep -c "ANALYSIS_COMPLETE" "$LOG_FILE" 2>/dev/null || echo "0")
    local session_reports=$(find "$REPORTS_DIR" -name "*.html" -type f -mmin -60 2>/dev/null | wc -l)
    echo "• Análises realizadas: $session_analyses"
    echo "• Relatórios gerados: $session_reports"
    echo ""
    echo -e "${YELLOW}⚠️  DISCLAIMER${NC}"
    echo "Esta ferramenta é destinada apenas para fins educacionais e de segurança"
    echo "legítima. O uso inadequado é de responsabilidade do usuário."
    echo ""
    echo -e "${YELLOW}📞 SUPORTE${NC}"
    echo "Para suporte e dúvidas, consulte os logs em:"
    echo "$LOG_FILE"
}

# Mostrar ajuda e documentação
show_help() {
    clear
    echo -e "${CYAN}📚 AJUDA E DOCUMENTAÇÃO${NC}"
    echo "======================="
    echo ""
    
    echo -e "${YELLOW}🚀 GUIA RÁPIDO${NC}"
    echo ""
    echo -e "${BLUE}1. Análise de Arquivo:${NC}"
    echo "   • Selecione opção 1 no menu principal"
    echo "   • Digite o caminho completo do arquivo"
    echo "   • Aguarde a análise completa"
    echo "   • Opcionalmente gere um relatório HTML"
    echo ""
    echo -e "${BLUE}2. Análise de URL:${NC}"
    echo "   • Selecione opção 2 no menu principal"
    echo "   • Digite a URL completa (incluindo http/https)"
    echo "   • A ferramenta verificará conectividade e segurança"
    echo "   • Relatório detalhado será exibido"
    echo ""
    echo -e "${BLUE}3. Configuração de APIs:${NC}"
    echo "   • Selecione opção 7 no menu principal"
    echo "   • Escolha a API desejada"
    echo "   • Digite sua chave de API (será criptografada)"
    echo "   • Teste a conexão para verificar funcionamento"
    echo ""
    echo -e "${YELLOW}🔑 OBTENDO CHAVES DE API${NC}"
    echo ""
    echo -e "${BLUE}VirusTotal:${NC}"
    echo "   1. Acesse: https://www.virustotal.com/"
    echo "   2. Crie uma conta gratuita"
    echo "   3. Vá em 'API Key' no seu perfil"
    echo "   4. Copie a chave de 64 caracteres"
    echo ""
    echo -e "${BLUE}URLScan.io:${NC}"
    echo "   1. Acesse: https://urlscan.io/"
    echo "   2. Registre-se gratuitamente"
    echo "   3. Vá em 'Settings' > 'API'"
    echo "   4. Gere uma nova chave de API"
    echo ""
    echo -e "${BLUE}Shodan:${NC}"
    echo "   1. Acesse: https://www.shodan.io/"
    echo "   2. Crie uma conta"
    echo "   3. Vá em 'My Account'"
    echo "   4. Copie sua API Key"
    echo ""
    echo -e "${YELLOW}📋 DICAS DE USO${NC}"
    echo ""
    echo "• Mantenha suas chaves de API seguras"
    echo "• Execute análises em arquivos suspeitos em ambiente isolado"
    echo "• Verifique os logs regularmente para auditoria"
    echo "• Use relatórios HTML para documentação"
    echo "• Mantenha a ferramenta atualizada"
    echo ""
    echo -e "${YELLOW}🔧 SOLUÇÃO DE PROBLEMAS${NC}"
    echo ""
    echo -e "${BLUE}Erro de dependências:${NC}"
    echo "   Execute: ./scripts/install_dependencies.sh"
    echo ""
    echo -e "${BLUE}Problemas de permissão:${NC}"
    echo "   Verifique se tem permissão de escrita em $CONFIG_DIR"
    echo ""
    echo -e "${BLUE}APIs não funcionando:${NC}"
    echo "   • Verifique sua conexão com a internet"
    echo "   • Confirme se as chaves de API estão corretas"
    echo "   • Teste cada API individualmente"
    echo ""
    echo -e "${BLUE}Relatórios não abrindo:${NC}"
    echo "   • Verifique se Python3 está instalado"
    echo "   • Confirme se a porta 8080 está livre"
    echo "   • Tente abrir o arquivo HTML manualmente"
}

# Loop principal da aplicação
main_loop() {
    while true; do
        show_main_menu
        
        # Ler escolha do usuário com timeout
        if read -t $MENU_TIMEOUT -r choice; then
            echo ""
            
            case "$choice" in
                1)
                    analyze_file_interactive
                    ;;
                2)
                    analyze_url_interactive
                    ;;
                3)
                    analyze_domain_interactive
                    ;;
                4)
                    analyze_hash_interactive
                    ;;
                5)
                    analyze_email_interactive
                    ;;
                6)
                    analyze_ip_interactive
                    ;;
                7)
                    configure_apis_menu
                    ;;
                8)
                    reports_menu
                    ;;
                9)
                    show_statistics
                    ;;
                10)
                    logs_menu
                    ;;
                11)
                    run_system_tests
                    ;;
                12)
                    maintenance_menu
                    ;;
                13)
                    show_help
                    ;;
                14)
                    show_about
                    ;;
                0)
                    echo -e "${GREEN}Obrigado por usar o Security Analyzer Tool!${NC}"
                    echo -e "${PURPLE}$APP_AUTHOR${NC}"
                    log_info "Aplicação encerrada pelo usuário" "MAIN"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}❌ Opção inválida! Tente novamente.${NC}"
                    sleep 2
                    continue
                    ;;
            esac
            
            # Pausa após cada operação (exceto sair)
            if [[ "$choice" != "0" ]]; then
                echo ""
                echo -e "${CYAN}Pressione ENTER para continuar...${NC}"
                read -r
            fi
            
        else
            # Timeout atingido
            echo ""
            echo -e "${YELLOW}⏰ Timeout atingido. Encerrando...${NC}"
            log_info "Aplicação encerrada por timeout" "MAIN"
            exit 0
        fi
    done
}

# Função principal de inicialização
main() {
    # Capturar sinais para limpeza adequada
    trap 'echo -e "\n${YELLOW}Encerrando aplicação...${NC}"; log_info "Aplicação interrompida por sinal" "MAIN"; exit 0' INT TERM
    
    # Inicializar sistema
    initialize_system
    
    # Executar loop principal
    main_loop
}

# Verificar se o script está sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
