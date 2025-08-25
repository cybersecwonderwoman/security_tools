# 📋 Funcionalidade de Listagem de Relatórios

## ✅ Implementação Concluída

A funcionalidade de listagem de relatórios foi implementada com sucesso no Security Analyzer Tool, permitindo visualizar, gerenciar e acessar todos os relatórios HTML gerados.

## 🎯 Funcionalidades Implementadas

### 1. **Listagem Inteligente de Relatórios**
- ✅ Exibição em formato de tabela organizada
- ✅ Ordenação por data (mais recentes primeiro)
- ✅ Extração automática de metadados dos arquivos HTML
- ✅ Limitação de 20 relatórios por página para melhor visualização
- ✅ Contagem total de relatórios disponíveis

### 2. **Informações Exibidas**
- **ID do Relatório**: Identificador único (SA-YYYYMMDD-XXXX)
- **Data**: Formatada como DD/MM/YYYY
- **Tipo**: Arquivo, URL, Domínio, Hash, Email, IP
- **Status**: Limpo, Suspeito, Malicioso (com cores)
- **Alvo**: Nome do arquivo/URL/domínio analisado

### 3. **Opções Interativas**
- **[1-20]** - Abrir relatório específico no navegador
- **[a]** - Abrir os 5 relatórios mais recentes
- **[s]** - Iniciar servidor web (localhost:8080)
- **[d]** - Excluir relatório específico
- **[c]** - Limpar todos os relatórios
- **[0]** - Voltar ao menu anterior

### 4. **Recursos Avançados**
- 🎨 **Códigos de cores** para status (Verde=Limpo, Amarelo=Suspeito, Vermelho=Malicioso)
- 📊 **Estatísticas** em tempo real (total de relatórios)
- 🔍 **Truncamento inteligente** de nomes longos
- ⚡ **Abertura automática** no navegador
- 🛡️ **Confirmação** para operações destrutivas

## 📱 Como Usar

### Acesso via Menu Principal
```bash
./security_tool.sh
# Selecione opção 10: 📈 Relatórios HTML
# Selecione opção 1: 📋 Listar Relatórios
```

### Teste Direto
```bash
./test_list_reports.sh
```

## 🖥️ Exemplo de Saída

```
📋 RELATÓRIOS GERADOS

📊 Total de relatórios: 67

┌─────────────────────────────────────────────────────────────────────────────┐
│ ID do Relatório          │ Data       │ Tipo        │ Status      │ Alvo     │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1  SA-20250724-cc5a2d0e │ 24/07/2025 │ Arquivo     │ Limpo       │ example.exe │
│ 2  SA-20250724-648e4ad6 │ 24/07/2025 │ Domínio     │ Suspeito    │ malicious... │
│ 3  SA-20250724-5fcd8614 │ 24/07/2025 │ URL         │ Malicioso   │ https://... │
└─────────────────────────────────────────────────────────────────────────────┘

Opções:
  [1-20] Abrir relatório específico
  [a] Abrir todos os relatórios recentes (últimos 5)
  [s] Iniciar servidor web
  [d] Excluir relatório
  [c] Limpar todos os relatórios
  [0] Voltar
```

## 🔧 Funcionalidades Técnicas

### Extração de Metadados
A função extrai automaticamente informações dos arquivos HTML:
- Tipo de análise via `grep -o '<strong>Tipo de Análise:</strong> [^<]*'`
- Alvo via `grep -o '<strong>Alvo:</strong> [^<]*'`
- Status via busca no HTML do relatório

### Ordenação Inteligente
- Usa `find` com `printf '%T@ %p\n'` para obter timestamp
- Ordena com `sort -rn` (numérico reverso)
- Mais recentes aparecem primeiro

### Servidor Web Integrado
- Inicia automaticamente servidor Python
- Acesso via http://localhost:8080/
- Abertura automática no navegador padrão

## 📂 Estrutura de Arquivos

```
~/.security_analyzer/reports/
├── SA-20250724-cc5a2d0e.html
├── SA-20250724-648e4ad6.html
├── SA-20250724-5fcd8614.html
└── ...
```

## 🎉 Benefícios

1. **Gestão Centralizada**: Todos os relatórios em um local
2. **Acesso Rápido**: Abertura direta no navegador
3. **Visualização Clara**: Tabela organizada com informações relevantes
4. **Operações Seguras**: Confirmação para exclusões
5. **Performance**: Limitação de exibição para grandes volumes

A funcionalidade está totalmente operacional e integrada ao Security Analyzer Tool! 🚀
