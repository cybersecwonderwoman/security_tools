# 📊 Relatórios HTML - Security Analyzer Tool

## Visão Geral

A funcionalidade de Relatórios HTML permite gerar visualizações detalhadas, interativas e bem formatadas dos resultados de análise de segurança. Os relatórios são servidos localmente através de um servidor web simples, permitindo uma experiência de usuário aprimorada e facilitando o compartilhamento de resultados.

## Características

- 🎨 **Design Moderno e Clean**: Interface limpa e profissional para apresentação de resultados
- 📱 **Design Responsivo**: Visualização adequada em diferentes dispositivos e tamanhos de tela
- 🔄 **Servidor Web Integrado**: Acesso fácil via navegador em localhost
- 📂 **Gerenciamento de Relatórios**: Interface para listar, visualizar e excluir relatórios
- 📈 **Visualização Detalhada**: Apresentação clara de resultados com códigos de cores
- 📋 **Recomendações Automáticas**: Sugestões personalizadas baseadas nos resultados da análise

## Como Usar

### Geração de Relatórios

Os relatórios HTML são gerados automaticamente ao realizar qualquer análise no Security Analyzer Tool. Após a conclusão da análise, você será perguntado se deseja abrir o relatório no navegador.

### Acessando Relatórios

Existem duas maneiras de acessar os relatórios:

1. **Diretamente após a análise**: Responda "s" quando perguntado se deseja abrir o relatório
2. **Através do menu de Relatórios HTML**: Selecione a opção 10 no menu principal

### Menu de Gerenciamento de Relatórios

O menu de gerenciamento oferece as seguintes opções:

1. **📋 Listar Relatórios**: Visualiza todos os relatórios gerados
2. **🌐 Iniciar Servidor**: Inicia o servidor web para acessar relatórios
3. **🛑 Parar Servidor**: Encerra o servidor web
4. **🗑️ Excluir Relatório**: Remove um relatório específico
5. **🗑️ Excluir Todos**: Remove todos os relatórios

## Estrutura dos Relatórios

Cada relatório HTML inclui as seguintes seções:

### 1. Resumo da Análise
- Tipo de análise realizada
- Alvo analisado
- Data e hora da análise
- Status geral (Limpo, Suspeito, Malicioso)
- Nível de ameaça (Baixo, Médio, Alto)
- Número de fontes consultadas

### 2. Detalhes da Análise
- Resultados completos da análise
- Informações detalhadas sobre o alvo
- Alertas e avisos identificados

### 3. Resultados por Fonte
- Tabela com resultados de cada fonte de threat intelligence
- Status individual por fonte
- Detalhes específicos de cada fonte

### 4. Informações Técnicas
- Dados técnicos relevantes (hashes, registros DNS, etc.)
- Metadados do alvo analisado

### 5. Recomendações
- Lista de ações recomendadas baseadas nos resultados
- Sugestões de mitigação para ameaças detectadas
- Melhores práticas de segurança

## Requisitos Técnicos

- Python (2.7+ ou 3.x) para o servidor web
- Navegador web moderno
- Bash 4.0+

## Localização dos Arquivos

- **Relatórios**: `~/.security_analyzer/reports/`
- **Templates HTML**: `/caminho/para/security_tools/html_templates/`
- **Scripts de Relatório**: 
  - `html_report.sh`: Funções para geração de relatórios
  - `report_integration.sh`: Integração com o script principal

## Demonstração

Para testar a funcionalidade de relatórios HTML sem realizar análises reais, execute o script de demonstração:

```bash
./demo_report.sh
```

Este script simula diferentes tipos de análise e gera relatórios HTML de exemplo.

## Personalização

Os relatórios HTML utilizam CSS interno para estilização. Para personalizar a aparência:

1. Edite o arquivo `html_templates/report_template.html`
2. Modifique as variáveis CSS no início do arquivo:
   ```css
   :root {
       --primary-color: #2c3e50;
       --secondary-color: #3498db;
       /* outras variáveis de cor */
   }
   ```

## Solução de Problemas

### O servidor web não inicia
- Verifique se o Python está instalado: `python --version` ou `python3 --version`
- Verifique se a porta 8080 está disponível: `netstat -tuln | grep 8080`

### Relatório não abre no navegador
- Inicie o servidor manualmente: Opção 2 no menu de gerenciamento de relatórios
- Acesse manualmente: http://localhost:8080/nome-do-relatorio.html

### Erros de formatação no relatório
- Verifique se o template HTML está intacto
- Reinicie o servidor web

## Integração com o Security Analyzer Tool

Esta funcionalidade está totalmente integrada ao Security Analyzer Tool. Para aplicar a integração:

```bash
./integration_patch.sh
```

Este script modifica o `security_tool.sh` para incluir a geração de relatórios HTML em todas as funções de análise.
