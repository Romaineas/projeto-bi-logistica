# Documentação Completa do Projeto BI

## 📚 Índice
1. [Visão Geral](#visão-geral)
2. [Estrutura do Banco de Dados](#estrutura-do-banco-de-dados)
3. [Descrição das Tabelas](#descrição-das-tabelas)
4. [Fluxo de Dados](#fluxo-de-dados)
5. [Medidas DAX](#medidas-dax)
6. [Como Executar](#como-executar)

---

## 🎯 Visão Geral

Projeto de **Business Intelligence** focado em análise de vendas, com dados estruturados em SQL Server e visualização em Power BI.

**Objetivo**: Fornecer insights sobre:
- Desempenho de vendas por cliente e produto
- Distribuição geográfica de vendas
- Análise temporal de tendências
- KPIs de negócio

---

## 🗄️ Estrutura do Banco de Dados

### Diagrama Entidade-Relacionamento (ER)

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   Clientes   │         │    Vendas    │         │  Produtos    │
├──────────────┤         ├──────────────┤         ├──────────────┤
│ ClienteID(PK)├────┬────│ VendaID(PK)  │    ┬────│ ProdutoID(PK)│
│ Nome         │    │    │ ClienteID(FK)│    │    │ Nome         │
│ Email        │    │    │ ProdutoID(FK)│────┤    │ Categoria    │
│ Telefone     │    │    │ DataVenda    │    │    │ Preço        │
│ Cidade       │    │    │ Quantidade   │    │    │ Estoque      │
│ Estado       │    │    │ PrecoUnit.   │    │    │ DataCad.     │
│ DataCadastro │    │    │ ValorTotal   │    │    │              │
└──────────────┘    │    └──────────────┘    │    └──────────────┘
                    └────────────────────────┘
```

---

## 📋 Descrição das Tabelas

### 1. **Clientes**
Tabela central para informações de clientes.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| ClienteID | INT (PK) | Identificador único do cliente |
| Nome | NVARCHAR(100) | Nome completo |
| Email | NVARCHAR(100) | Email para contato |
| Telefone | NVARCHAR(20) | Número de telefone |
| Cidade | NVARCHAR(50) | Cidade de localização |
| Estado | NVARCHAR(2) | UF (ex: SP, RJ) |
| DataCadastro | DATETIME | Data de registro |

---

### 2. **Produtos**
Tabela com catálogo de produtos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| ProdutoID | INT (PK) | Identificador único |
| Nome | NVARCHAR(100) | Nome do produto |
| Categoria | NVARCHAR(50) | Categoria (Eletrônicos, Periféricos, etc) |
| Preco | DECIMAL(10,2) | Preço unitário |
| Estoque | INT | Quantidade em estoque |
| DataCadastro | DATETIME | Data de inclusão |

---

### 3. **Vendas**
Tabela de transações de vendas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| VendaID | INT (PK) | Identificador único da venda |
| ClienteID | INT (FK) | Referência ao cliente |
| ProdutoID | INT (FK) | Referência ao produto |
| DataVenda | DATETIME | Data da transação |
| Quantidade | INT | Quantidade vendida |
| PrecoUnitario | DECIMAL(10,2) | Preço no momento da venda |
| ValorTotal | DECIMAL(10,2) | Valor total (Qtd × Preço) |

---

## 🔄 Fluxo de Dados

```
[Scripts SQL] → [SQL Server] → [Power BI] → [Dashboards]
     ↓              ↓              ↓
  01_criar_    BI_Database    Import Data    Visualizações
  tabelas.sql  ├─ Clientes    ├─ Medidas    ├─ Gráficos
               ├─ Produtos     ├─ KPIs       ├─ Tabelas
  02_popular_  ├─ Vendas       └─ Filtros    └─ Scorecards
  dados.sql
  
  03_queries_  Análises SQL
  analise.sql
```

---

## 📊 Medidas DAX

### Medidas Principais

#### **Total Vendas**
```dax
Total Vendas = SUM(Vendas[ValorTotal])
```
Soma de todos os valores de vendas.

#### **Ticket Médio**
```dax
Ticket Médio = [Total Vendas] / [Qtd Transações]
```
Valor médio por transação.

#### **Total de Clientes**
```dax
Total Clientes = DISTINCTCOUNT(Clientes[ClienteID])
```
Quantidade de clientes únicos.

#### **% Atingimento de Meta**
```dax
% Atingimento = DIVIDE([Total Vendas], [Meta Vendas], 0)
```
Percentual de meta atingida.

---

## 🚀 Como Executar

### Pré-requisitos
- SQL Server 2019 ou superior
- SQL Server Management Studio (SSMS)
- Power BI Desktop

### Passo 1: Criar Estrutura (SQL)
```sql
-- Executar em SSMS
EXEC sp_executesql N'Script 01'
```

### Passo 2: Popular Dados (SQL)
```sql
-- Executar em SSMS
EXEC sp_executesql N'Script 02'
```

### Passo 3: Validar com Queries (SQL)
```sql
-- Executar em SSMS
EXEC sp_executesql N'Script 03'
```

### Passo 4: Configurar Power BI
1. Abrir Power BI Desktop
2. **Get Data** → SQL Server
3. Server: `(local)` | Database: `BI_Database`
4. Selecionar Clientes, Produtos, Vendas
5. Adicionar medidas DAX do arquivo `04_medidas_dax.txt`
6. Criar visualizações

---

## 📈 Exemplos de Análises

### Dashboard de Vendas
- Total de vendas (KPI)
- Vendas por cliente (Gráfico de Barras)
- Vendas por categoria (Pizza)
- Distribuição por estado (Mapa)
- Tendência temporal (Linha)

### Dashboard de Produtos
- Estoque total
- Top 5 produtos mais vendidos
- Análise ABC
- Rotatividade de estoque

### Dashboard Executivo
- Meta vs. Realizado
- Crescimento MoM
- Ticket médio
- Clientes ativos

---

## 🔐 Segurança

- ✅ Chaves primárias e estrangeiras implementadas
- ✅ Validação de integridade referencial
- ✅ Timestamps para auditoria
- ⚠️ Implementar: Criptografia de dados sensíveis
- ⚠️ Implementar: Backup automático

---

## 📝 Manutenção

### Backup
```sql
BACKUP DATABASE BI_Database 
TO DISK = 'C:\Backup\BI_Database.bak'
```

### Limpeza de Dados Antigos
```sql
DELETE FROM Vendas 
WHERE YEAR(DataVenda) < YEAR(GETDATE())
```

---

## 👥 Autor & Suporte

**Responsável**: Romaine Santos  
**Email**: romaine.santos@outlook.com  
**Data de Criação**: 23/01/2026  
**Versão**: 1.0

---

## 📞 Próximos Passos

- [ ] Implementar backup automático
- [ ] Adicionar Data Warehouse
- [ ] Criar pipeline de ETL
- [ ] Implementar RLS (Row-Level Security)
- [ ] Documentar stored procedures
- [ ] Setup de alertas em KPIs críticos

---

*Última atualização: 23/01/2026*
