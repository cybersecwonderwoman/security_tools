#!/bin/bash

# Script para aplicar as modificações ao security_tool.sh

# Verificar se o script principal existe
if [[ ! -f "security_tool.sh" ]]; then
    echo "Erro: security_tool.sh não encontrado no diretório atual."
    exit 1
fi

# Criar diretório para templates HTML se não existir
mkdir -p html_templates

# Dar permissões de execução aos scripts
chmod +x html_report.sh
chmod +x report_integration.sh

# Adicionar a opção de relatórios HTML ao menu principal
sed -i '/\[9\] 📊 Ver Estatísticas/a \  [10] 📈 Relatórios HTML         - Gerenciar relatórios HTML' security_tool.sh
sed -i 's/\[10\] 📝 Ver Logs/\[11\] 📝 Ver Logs/g' security_tool.sh
sed -i 's/\[11\] 🧪 Executar Testes/\[12\] 🧪 Executar Testes/g' security_tool.sh
sed -i 's/\[12\] 📚 Ajuda/\[13\] 📚 Ajuda/g' security_tool.sh
sed -i 's/\[13\] ℹ️ Sobre/\[14\] ℹ️ Sobre/g' security_tool.sh
sed -i 's/\[0\] 🚪 Sair/\[0\] 🚪 Sair/g' security_tool.sh

# Adicionar a importação do script de integração de relatórios
sed -i '/# Configurações/a \# Importar script de integração de relatórios HTML\nsource "$(dirname "$(readlink -f "$0")")/report_integration.sh"' security_tool.sh

# Modificar as funções de análise para incluir a geração de relatórios HTML
# Primeiro, vamos criar cópias das funções originais com nomes diferentes
sed -i 's/analyze_file() {/analyze_file_internal() {/g' security_tool.sh
sed -i 's/analyze_url() {/analyze_url_internal() {/g' security_tool.sh
sed -i 's/analyze_domain() {/analyze_domain_internal() {/g' security_tool.sh
sed -i 's/analyze_hash() {/analyze_hash_internal() {/g' security_tool.sh
sed -i 's/analyze_email() {/analyze_email_internal() {/g' security_tool.sh
sed -i 's/analyze_header() {/analyze_header_internal() {/g' security_tool.sh

# Agora, vamos adicionar as novas funções que chamam as funções internas e geram relatórios
cat << 'EOF' >> security_tool.sh

# Função para análise de arquivo com relatório HTML
analyze_file() {
    echo -e "${CYAN}📁 ANÁLISE DE ARQUIVO${NC}"
    echo "Digite o caminho do arquivo:"
    echo -n "➤ "
    read -r file_path
    
    if [[ -n "$file_path" ]]; then
        # Verificar se o arquivo existe
        if [[ ! -f "$file_path" ]]; then
            echo -e "${RED}Erro: Arquivo não encontrado${NC}"
            log_message "Erro: Arquivo não encontrado - $file_path"
            return 1
        fi
        
        analyze_file_with_report "$file_path"
    else
        echo -e "${RED}Erro: Caminho do arquivo não pode estar vazio${NC}"
    fi
}

# Função para análise de URL com relatório HTML
analyze_url() {
    echo -e "${CYAN}🌐 ANÁLISE DE URL${NC}"
    echo "Digite a URL para análise:"
    echo -n "➤ "
    read -r url
    
    if [[ -n "$url" ]]; then
        analyze_url_with_report "$url"
    else
        echo -e "${RED}Erro: URL não pode estar vazia${NC}"
    fi
}

# Função para análise de domínio com relatório HTML
analyze_domain() {
    echo -e "${CYAN}🏠 ANÁLISE DE DOMÍNIO${NC}"
    echo "Digite o domínio para análise:"
    echo -n "➤ "
    read -r domain
    
    if [[ -n "$domain" ]]; then
        analyze_domain_with_report "$domain"
    else
        echo -e "${RED}Erro: Domínio não pode estar vazio${NC}"
    fi
}

# Função para análise de hash com relatório HTML
analyze_hash() {
    echo -e "${CYAN}🔢 ANÁLISE DE HASH${NC}"
    echo "Digite o hash para análise (MD5, SHA1 ou SHA256):"
    echo -n "➤ "
    read -r hash_value
    
    if [[ -n "$hash_value" ]]; then
        analyze_hash_with_report "$hash_value"
    else
        echo -e "${RED}Erro: Hash não pode estar vazio${NC}"
    fi
}

# Função para análise de email com relatório HTML
analyze_email() {
    echo -e "${CYAN}📧 ANÁLISE DE EMAIL${NC}"
    echo "Digite o endereço de email para análise:"
    echo -n "➤ "
    read -r email
    
    if [[ -n "$email" ]]; then
        analyze_email_with_report "$email"
    else
        echo -e "${RED}Erro: Email não pode estar vazio${NC}"
    fi
}

# Função para análise de cabeçalho de email com relatório HTML
analyze_header() {
    echo -e "${CYAN}📋 ANÁLISE DE CABEÇALHO DE EMAIL${NC}"
    echo "Digite o caminho do arquivo de cabeçalho:"
    echo -n "➤ "
    read -r header_file
    
    if [[ -n "$header_file" ]]; then
        if [[ ! -f "$header_file" ]]; then
            echo -e "${RED}Erro: Arquivo não encontrado${NC}"
            log_message "Erro: Arquivo de cabeçalho não encontrado - $header_file"
            return 1
        fi
        
        analyze_header_with_report "$header_file"
    else
        echo -e "${RED}Erro: Caminho do arquivo não pode estar vazio${NC}"
    fi
}
EOF

# Adicionar a função de gerenciamento de relatórios ao switch case do menu principal
sed -i '/9) # Ver Estatísticas/a \        10) # Relatórios HTML\n            manage_reports\n            ;;' security_tool.sh

# Ajustar os números das outras opções no switch case
sed -i 's/10) # Ver Logs/11) # Ver Logs/g' security_tool.sh
sed -i 's/11) # Executar Testes/12) # Executar Testes/g' security_tool.sh
sed -i 's/12) # Ajuda/13) # Ajuda/g' security_tool.sh
sed -i 's/13) # Sobre/14) # Sobre/g' security_tool.sh

echo "Integração concluída com sucesso!"
echo "Agora você pode gerar relatórios HTML bonitos e detalhados para suas análises de segurança."
echo "Para testar, execute ./security_tool.sh e escolha qualquer opção de análise."
