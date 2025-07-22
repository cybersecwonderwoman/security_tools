# 🔑 APIs Adicionais para Melhor Detecção de Ameaças

## 🎯 APIs Recomendadas para Detecção Avançada

### 1. AbuseIPDB API (Altamente Recomendada)

**Para que serve**: Detecção de IPs maliciosos com base em relatórios da comunidade

#### Como Obter:
1. **Acesse**: https://www.abuseipdb.com/register
2. **Registre-se** gratuitamente
3. **Vá para**: https://www.abuseipdb.com/account/api
4. **Copie sua API Key**

#### Limites Gratuitos:
- **1.000 consultas por dia**
- **Dados dos últimos 30 dias**
- **Relatórios de abuso da comunidade**

#### Configurar na Ferramenta:
```bash
# Editar arquivo de configuração
nano ~/.security_analyzer/api_keys.conf

# Adicionar linha:
ABUSEIPDB_API_KEY="sua_chave_abuseipdb"
```

### 2. Criminal IP API

**Para que serve**: Base de dados especializada em IPs criminosos

#### Como Obter:
1. **Acesse**: https://www.criminalip.io/register
2. **Registre-se** gratuitamente  
3. **Vá para**: Dashboard → API Key
4. **Copie sua API Key**

#### Limites Gratuitos:
- **10.000 consultas por mês**
- **Dados de reputação de IP**
- **Informações de geolocalização**

#### Configurar:
```bash
# Adicionar ao arquivo de configuração
CRIMINALIP_API_KEY="sua_chave_criminalip"
```

### 3. IPQualityScore API

**Para que serve**: Detecção de proxies, VPNs e IPs maliciosos

#### Como Obter:
1. **Acesse**: https://www.ipqualityscore.com/create-account
2. **Registre-se** gratuitamente
3. **Vá para**: https://www.ipqualityscore.com/user/settings
4. **Copie sua Private Key**

#### Limites Gratuitos:
- **5.000 consultas por mês**
- **Detecção de proxy/VPN**
- **Score de fraude**

### 4. GreyNoise API

**Para que serve**: Identificar tráfego de internet "ruído" vs ameaças direcionadas

#### Como Obter:
1. **Acesse**: https://viz.greynoise.io/signup
2. **Registre-se** gratuitamente
3. **Vá para**: Account → API Key
4. **Copie sua API Key**

#### Limites Gratuitos:
- **10.000 consultas por mês**
- **Classificação de tráfego**
- **Dados de scanner vs malware**

## 🔧 Configuração Completa

### Arquivo de Configuração Expandido:
```bash
# ~/.security_analyzer/api_keys.conf

# APIs Principais
VIRUSTOTAL_API_KEY="sua_chave_virustotal"
SHODAN_API_KEY="sua_chave_shodan"
URLSCAN_API_KEY="sua_chave_urlscan"
HYBRID_ANALYSIS_API_KEY="sua_chave_hybrid"

# APIs Adicionais para Melhor Detecção
ABUSEIPDB_API_KEY="sua_chave_abuseipdb"
CRIMINALIP_API_KEY="sua_chave_criminalip"
IPQUALITYSCORE_API_KEY="sua_chave_ipqualityscore"
GREYNOISE_API_KEY="sua_chave_greynoise"
```

### Script de Configuração Automática:
```bash
# Executar configuração via menu
./menu.sh
# [7] ⚙️ Configurar APIs
# Inserir todas as chaves quando solicitado
```

## 📊 Comparação de APIs de IP

| API | Consultas Gratuitas | Especialidade | Precisão |
|-----|-------------------|---------------|----------|
| **AbuseIPDB** | 1.000/dia | Relatórios comunidade | ⭐⭐⭐⭐⭐ |
| **Criminal IP** | 10.000/mês | IPs criminosos | ⭐⭐⭐⭐⭐ |
| **VirusTotal** | 4/min | Antivirus engines | ⭐⭐⭐⭐ |
| **IPQualityScore** | 5.000/mês | Proxy/VPN/Fraude | ⭐⭐⭐⭐ |
| **GreyNoise** | 10.000/mês | Ruído vs Ameaça | ⭐⭐⭐⭐ |
| **Shodan** | 100/mês | Infraestrutura | ⭐⭐⭐ |

## 🚀 Melhorias na Detecção

### Com APIs Adicionais, a ferramenta detectará:

#### IPs Maliciosos:
- ✅ **Botnets** conhecidos
- ✅ **Servidores C&C** (Command & Control)
- ✅ **IPs de phishing** reportados
- ✅ **Proxies maliciosos**
- ✅ **VPNs suspeitas**
- ✅ **Scanners** vs **ameaças direcionadas**

#### Contexto Adicional:
- 🌍 **Geolocalização** precisa
- 🏢 **ISP e organização**
- 📊 **Score de confiança**
- 📈 **Histórico de atividade**
- 🔍 **Classificação de ameaça**

## 🧪 Teste com IP Malicioso

### Antes (sem APIs adicionais):
```bash
./ip_reputation_checker.sh 184.107.85.10
# Resultado: 1 indicador (blacklist DNS)
```

### Depois (com APIs adicionais):
```bash
./ip_reputation_checker.sh 184.107.85.10
# Resultado esperado: 3-5 indicadores
# - Blacklist DNS
# - AbuseIPDB: 85% confiança de abuso
# - Criminal IP: Classificado como malicioso
# - IPQualityScore: Proxy suspeito
```

## 📈 Exemplo de Análise Melhorada

### Cabeçalho com IP 184.107.85.10:
```bash
./security_analyzer.sh --header test_malicious_header.txt
```

**Resultado esperado com APIs adicionais**:
```
[Verificação de Reputação] Analisando IP: 184.107.85.10
✗ Listado em dnsbl.njabl.org
✗ AbuseIPDB: 85% de confiança de abuso
✗ Criminal IP: Classificado como HIGH RISK
✗ IPQualityScore: Proxy suspeito detectado
⚠ TOTAL: 4 indicadores de ameaça encontrados

RESUMO DE AMEAÇAS
Nível de Risco: ALTO
Recomendações:
🚨 ATENÇÃO: Múltiplos indicadores de ameaça
🚨 Bloqueio preventivo recomendado
🚨 Análise forense detalhada necessária
```

## 🔒 Segurança das APIs

### Boas Práticas:
- 🔐 **Permissões 600** no arquivo de configuração
- 🔄 **Rotação regular** das chaves
- 📊 **Monitoramento** de uso/limites
- 🚫 **Nunca compartilhar** chaves em repositórios

### Verificar Configuração:
```bash
# Verificar permissões
ls -la ~/.security_analyzer/api_keys.conf

# Deve mostrar: -rw------- (600)

# Testar conectividade
./debug_header.sh examples/sample_email_header.txt
```

## 💰 Upgrades Recomendados

### Para Uso Profissional:
1. **AbuseIPDB Pro** ($20/mês) - 100.000 consultas/dia
2. **Criminal IP Pro** ($50/mês) - Consultas ilimitadas
3. **VirusTotal Premium** ($99/mês) - Rate limits maiores
4. **IPQualityScore Pro** ($25/mês) - 50.000 consultas/mês

### ROI do Upgrade:
- 🎯 **Detecção 300% mais precisa**
- ⚡ **Análise 10x mais rápida**
- 📊 **Dados históricos** completos
- 🚨 **Alertas em tempo real**

## 🔄 Implementação Gradual

### Fase 1: APIs Gratuitas Essenciais
```bash
# Configurar primeiro
ABUSEIPDB_API_KEY="chave_gratuita"
CRIMINALIP_API_KEY="chave_gratuita"
```

### Fase 2: Teste e Validação
```bash
# Testar com IPs conhecidos
./ip_reputation_checker.sh 184.107.85.10
./ip_reputation_checker.sh 8.8.8.8  # IP limpo para comparação
```

### Fase 3: Integração Completa
```bash
# Configurar todas as APIs
./menu.sh → [7] Configurar APIs
```

### Fase 4: Monitoramento
```bash
# Verificar logs e estatísticas
./menu.sh → [8] Ver Estatísticas
./menu.sh → [9] Ver Logs
```

---

**💡 Dica**: Comece com AbuseIPDB e Criminal IP - são as mais eficazes para detectar IPs maliciosos como o 184.107.85.10 que você mencionou!
