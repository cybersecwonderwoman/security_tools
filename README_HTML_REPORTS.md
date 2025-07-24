# 📊 Relatórios HTML para Security Analyzer Tool

## Implementação Concluída

Foram criados os seguintes componentes para adicionar a funcionalidade de relatórios HTML ao Security Analyzer Tool:

### 📁 Arquivos Criados

1. **html_templates/report_template.html**
   - Template HTML responsivo e moderno para os relatórios
   - Design clean com código de cores para diferentes níveis de ameaça
   - Layout otimizado para visualização de resultados de segurança

2. **html_report.sh**
   - Script principal para geração de relatórios HTML
   - Funções para converter saída de texto em HTML formatado
   - Servidor web integrado para visualização local dos relatórios

3. **report_integration.sh**
   - Integração com o script principal security_tool.sh
   - Funções para capturar a saída das análises e gerar relatórios
   - Menu de gerenciamento de relatórios

4. **integration_patch.sh**
   - Script para aplicar as modificações ao security_tool.sh
   - Adiciona a opção de relatórios HTML ao menu principal
   - Modifica as funções de análise para incluir geração de relatórios

5. **demo_report.sh**
   - Script de demonstração para testar a funcionalidade
   - Simula diferentes tipos de análise
   - Gera relatórios HTML de exemplo

6. **install_html_reports.sh**
   - Instalador automatizado da funcionalidade
   - Verifica dependências e cria diretórios necessários
   - Aplica o patch de integração

7. **HTML_REPORTS.md**
   - Documentação detalhada da funcionalidade
   - Instruções de uso e personalização
   - Solução de problemas

## 🚀 Como Instalar

Para instalar a funcionalidade de relatórios HTML:

```bash
# No diretório do Security Analyzer Tool
./install_html_reports.sh
```

O instalador verificará as dependências, criará os diretórios necessários e aplicará as modificações ao script principal.

## 📋 Como Usar

Após a instalação, você pode:

1. **Executar o Security Analyzer Tool**:
   ```bash
   ./security_tool.sh
   ```
   - Realize qualquer análise (arquivo, URL, domínio, etc.)
   - Ao final, você terá a opção de abrir o relatório HTML no navegador

2. **Gerenciar Relatórios**:
   - No menu principal, selecione a opção 10 (📈 Relatórios HTML)
   - Você poderá listar, visualizar e gerenciar todos os relatórios gerados

3. **Testar com Demonstração**:
   ```bash
   ./demo_report.sh
   ```
   - Este script gera relatórios de exemplo sem necessidade de alvos reais

## 🎨 Características dos Relatórios

- **Design Responsivo**: Visualização adequada em qualquer dispositivo
- **Código de Cores**: Verde para limpo, amarelo para suspeito, vermelho para malicioso
- **Seções Organizadas**: Resumo, detalhes, resultados por fonte, informações técnicas e recomendações
- **Recomendações Automáticas**: Sugestões personalizadas baseadas nos resultados
- **Servidor Local**: Acesso via http://localhost:8080/

## 📂 Localização dos Relatórios

Os relatórios HTML são salvos em:
```
~/.security_analyzer/reports/
```

Cada relatório tem um ID único no formato `SA-YYYYMMDD-XXXX.html`.

## 🔧 Requisitos

- Bash 4.0+
- Python (2.7+ ou 3.x) para o servidor web local
- Navegador web moderno

## 📝 Notas

- Os relatórios são gerados localmente e não são enviados para servidores externos
- O servidor web é executado apenas localmente (localhost)
- As chaves de API e informações sensíveis não são incluídas nos relatórios
