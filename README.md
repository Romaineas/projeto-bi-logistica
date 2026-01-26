# 📦 Projeto BI - Logística e Delivery

## 🎯 Sobre o Projeto

Dashboard completo de Business Intelligence para análise de operações de logística e delivery, desenvolvido para demonstrar capacidades analíticas avançadas em BI.

## 🛠️ Tecnologias

- SQL Server / PostgreSQL
- Power BI Desktop
- DAX (80+ medidas customizadas)
- Power Query (ETL)

## 📊 Principais Funcionalidades

- ✅ KPIs operacionais em tempo real
- ✅ Análise temporal (MoM, YoY, YTD)
- ✅ Ranking de entregadores
- ✅ Análise geográfica por região
- ✅ Comparativo meta vs realizado
- ✅ Dashboard interativo com filtros dinâmicos

## 📂 Estrutura do Projeto
```
projeto-bi-logistica/
├── .gitignore
├── README.md
├── scripts/
│   ├── 01_criar_tabelas.sql       # Criação de estrutura
│   ├── 02_popular_dados.sql       # População de dados
│   └── 03_queries_analise.sql     # Queries de análise
├── power-bi/
│   └── 04_medidas_dax.txt         # Medidas DAX
├── documentacao/
│   └── documentacao_completa.md   # Documentação técnica
└── imagens/
    └── (screenshots dos dashboards)
```

## 🚀 Como Usar

### 1. Configurar Banco de Dados
```sql
CREATE DATABASE DB_Logistica_Delivery;
USE DB_Logistica_Delivery;
```

Execute os scripts na ordem:
- `01_criar_tabelas.sql`
- `02_popular_dados.sql`

### 2. Conectar no Power BI

1. Abra o Power BI Desktop
2. Obter Dados → SQL Server
3. Importe as tabelas
4. Configure relacionamentos
5. Adicione as medidas DAX

## 📈 Métricas Principais

| Métrica | Valor | Variação |
|---------|-------|----------|
| Total Entregas | 40 | - |
| Faturamento | R$ 1.5K+ | - |
| Tempo Médio | ~30 min | ✅ Dentro da meta |
| Taxa Sucesso | >90% | ✅ Dentro da meta |

## 💡 Requisitos Atendidos

1. ✅ Monitorar taxa de entregas no prazo vs atrasadas
2. ✅ Identificar regiões com menor performance
3. ✅ Avaliar produtividade individual dos entregadores
4. ✅ Analisar correlação entre volume de pedidos e faturamento
5. ✅ Identificar padrões sazonais e dias de pico

## 👤 Autor

**Romaine Santos**
- GitHub: [@Romaineas](https://github.com/Romaineas)
- Email: romaine.santos@outlook.com

## 📄 Licença

Este projeto foi desenvolvido para fins de portfólio e demonstração.

---

⭐ **Se este projeto foi útil, considere dar uma estrela!**

