 Projeto de Business Intelligence - Logística e Delivery

 Visão Geral do Projeto

Cliente: FastDelivery Logística

Objetivo: Criar um dashboard analítico para monitoramento em tempo real das operações de entrega, identificando gargalos operacionais e oportunidades de otimização.

Ferramenta: Power BI / Dashboard Web Interativo

Período de Análise: Últimos 12 meses
Atualização: Diária (incremental)

 FASE 1: LEVANTAMENTO DE REQUISITOS

1.1 Reunião com Stakeholders

Participantes:

Gerente de Operações
Coordenador de Logística
Analista Financeiro
Supervisor de Entregadores

Perguntas-Chave Realizadas:

Quais são os principais problemas operacionais hoje?
Quais métricas são mais importantes para tomada de decisão?
Com que frequência os dados precisam ser atualizados?
Quais são os horários de pico de entregas?
Existem metas específicas por região ou entregador?

Principais Necessidades Identificadas:

Monitorar taxa de entregas no prazo vs atrasadas
Identificar regiões com menor performance
Avaliar produtividade individual dos entregadores
Analisar correlação entre volume de pedidos e faturamento
Identificar padrões sazonais e dias de pico

1.2 Definição de KPIs

KPI Descrição

Meta

FórmulaTotal de Entregas

Quantidade total de entregas realizadas+10% ao mêsCOUNT(entregas)Taxa de Sucesso% de entregas concluídas com sucesso>95%(Entregues / Total) * 100Tempo Médio de EntregaTempo médio desde coleta até entrega<30 minAVG(tempo_entrega)FaturamentoReceita total geradaR$ 120K/mêsSUM(valor_entrega)Ticket MédioValor médio por entregaR$ 45Faturamento / Total EntregasTaxa de Cancelamento% de entregas canceladas<2%(Canceladas / Total) * 100

 FASE 2: MODELAGEM E PREPARAÇÃO DOS DADOS
2.1 Fontes de Dados Identificadas
Sistema Operacional (PostgreSQL):

Tabela: tb_entregas
Tabela: tb_entregadores
Tabela: tb_clientes
Tabela: tb_regioes

Sistema Financeiro (SQL Server):

Tabela: tb_pagamentos
Tabela: tb_taxas

Planilha Excel:

Metas mensais por região
Cadastro de zonas de entrega

2.2 Estrutura das Tabelas Principais

Tabela: tb_entregas
sql

CREATE TABLE tb_entregas (
    id_entrega INT PRIMARY KEY,
    id_entregador INT,
    id_cliente INT,
    id_regiao INT,
    data_pedido DATETIME,
    data_coleta DATETIME,
    data_entrega DATETIME,
    status VARCHAR(20), -- 'Entregue', 'Em Rota', 'Atrasada', 'Cancelada'
    valor_entrega DECIMAL(10,2),
    distancia_km DECIMAL(5,2),
    avaliacao INT, -- 1 a 5
    observacoes TEXT
);
Tabela: tb_entregadores
sqlCREATE TABLE tb_entregadores (
    id_entregador INT PRIMARY KEY,
    nome VARCHAR(100),
    cpf VARCHAR(14),
    data_admissao DATE,
    veiculo VARCHAR(20), -- 'Moto', 'Carro', 'Bicicleta'
    status VARCHAR(20), -- 'Ativo', 'Inativo', 'Férias'
    telefone VARCHAR(15)
);
Tabela: tb_regioes
sqlCREATE TABLE tb_regioes (
    id_regiao INT PRIMARY KEY,
    nome_regiao VARCHAR(50), -- 'Centro', 'Norte', 'Sul', 'Leste', 'Oeste'
    zona VARCHAR(20),
    cidade VARCHAR(50),
    estado CHAR(2)
);

2.3 Queries SQL para Extração

Query 1: Dados Consolidados de Entregas
sql

SELECT 
    e.id_entrega,
    e.data_pedido,
    e.data_entrega,
    e.status,
    e.valor_entrega,
    e.distancia_km,
    e.avaliacao,
    ent.nome AS nome_entregador,
    ent.veiculo,
    r.nome_regiao,
    r.zona,
    DATEDIFF(MINUTE, e.data_coleta, e.data_entrega) AS tempo_entrega_min,
    CASE 
        WHEN DATEDIFF(MINUTE, e.data_coleta, e.data_entrega) > 30 THEN 'Atrasada'
        ELSE 'No Prazo'
    END AS classificacao_tempo
FROM tb_entregas e
INNER JOIN tb_entregadores ent ON e.id_entregador = ent.id_entregador
INNER JOIN tb_regioes r ON e.id_regiao = r.id_regiao
WHERE e.data_pedido >= DATEADD(MONTH, -12, GETDATE())
    AND ent.status = 'Ativo';

Query 2: Performance por Entregador
sqlSELECT 
    ent.id_entregador,
    ent.nome,
    COUNT(e.id_entrega) AS total_entregas,
    AVG(e.avaliacao) AS nota_media,
    AVG(DATEDIFF(MINUTE, e.data_coleta, e.data_entrega)) AS tempo_medio_min,
    SUM(e.valor_entrega) AS faturamento_total,
    SUM(CASE WHEN e.status = 'Entregue' THEN 1 ELSE 0 END) AS entregas_sucesso,
    CAST(SUM(CASE WHEN e.status = 'Entregue' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS taxa_sucesso
FROM tb_entregas e
INNER JOIN tb_entregadores ent ON e.id_entregador = ent.id_entregador
WHERE e.data_pedido >= DATEADD(MONTH, -1, GETDATE())
GROUP BY ent.id_entregador, ent.nome
ORDER BY total_entregas DESC;

Query 3: Análise Temporal (Por Dia da Semana)

sql

SELECT 
    DATENAME(WEEKDAY, e.data_pedido) AS dia_semana,
    DATEPART(WEEKDAY, e.data_pedido) AS ordem_dia,
    COUNT(e.id_entrega) AS total_entregas,
    SUM(e.valor_entrega) AS faturamento,
    AVG(DATEDIFF(MINUTE, e.data_coleta, e.data_entrega)) AS tempo_medio_min
FROM tb_entregas e
WHERE e.data_pedido >= DATEADD(WEEK, -1, GETDATE())
    AND e.status IN ('Entregue', 'Atrasada')
GROUP BY DATENAME(WEEKDAY, e.data_pedido), DATEPART(WEEKDAY, e.data_pedido)
ORDER BY ordem_dia;

Query 4: Distribuição por Região
sql

SELECT 
    r.nome_regiao,
    COUNT(e.id_entrega) AS total_entregas,
    SUM(e.valor_entrega) AS faturamento,
    AVG(e.distancia_km) AS distancia_media,
    AVG(e.avaliacao) AS avaliacao_media
FROM tb_entregas e
INNER JOIN tb_regioes r ON e.id_regiao = r.id_regiao
WHERE e.data_pedido >= DATEADD(MONTH, -1, GETDATE())
GROUP BY r.nome_regiao
ORDER BY total_entregas DESC;

🔧 FASE 3: TRANSFORMAÇÃO DOS DADOS (ETL)
3.1 Importação no Power BI
Conexões Estabelecidas:

PostgreSQL → tb_entregas, tb_entregadores, tb_regioes
SQL Server → tb_pagamentos
Excel → metas_regionais.xlsx

3.2 Power Query - Transformações Aplicadas
Etapa 1: Limpeza de Dados
powerquery// Remover linhas com valores nulos em campos críticos
= Table.SelectRows(Fonte, each [id_entrega] <> null and [data_entrega] <> null)

// Padronizar formato de datas
= Table.TransformColumnTypes(#"Linhas Filtradas",{
    {"data_pedido", type datetime}, 
    {"data_entrega", type datetime}
})

// Remover espaços em branco dos nomes
= Table.TransformColumns(#"Tipo Alterado",{
    {"nome_entregador", Text.Trim}
})
Etapa 2: Criação de Colunas Calculadas
powerquery// Calcular tempo de entrega em minutos
= Table.AddColumn(#"Etapa Anterior", "tempo_entrega_min", 
    each Duration.TotalMinutes([data_entrega] - [data_coleta]))

// Classificar entregas (No Prazo / Atrasada)
= Table.AddColumn(#"Tempo Calculado", "classificacao_tempo", 
    each if [tempo_entrega_min] <= 30 then "No Prazo" else "Atrasada")

// Extrair dia da semana
= Table.AddColumn(#"Classificação Adicionada", "dia_semana", 
    each Date.DayOfWeekName([data_pedido]))

// Extrair hora do pedido
= Table.AddColumn(#"Dia Semana", "hora_pedido", 
    each Time.Hour([data_pedido]))

// Criar faixa de horário
= Table.AddColumn(#"Hora Extraída", "turno", 
    each if [hora_pedido] >= 6 and [hora_pedido] < 12 then "Manhã"
    else if [hora_pedido] >= 12 and [hora_pedido] < 18 then "Tarde"
    else if [hora_pedido] >= 18 and [hora_pedido] < 24 then "Noite"
    else "Madrugada")
Etapa 3: Tratamento de Outliers
powerquery// Identificar entregas com tempo anormal (>120 minutos)
= Table.AddColumn(#"Etapa Anterior", "outlier_tempo", 
    each if [tempo_entrega_min] > 120 then "Sim" else "Não")

// Filtrar apenas valores válidos para análises principais
= Table.SelectRows(#"Outlier Identificado", 
    each [tempo_entrega_min] <= 120 and [valor_entrega] > 0)
3.3 Modelagem Dimensional (Star Schema)
Tabelas Dimensão:

dim_calendario (data completa, ano, mês, dia, semana, trimestre)
dim_entregadores (id, nome, veículo, data_admissão)
dim_regioes (id, nome, zona, cidade, estado)
dim_status (id, status, grupo)

Tabela Fato:

fato_entregas (id_entrega, id_data, id_entregador, id_regiao, id_status, valor, tempo, distância, avaliação)

Relacionamentos:
fato_entregas[id_data] → dim_calendario[data] (Muitos para Um)
fato_entregas[id_entregador] → dim_entregadores[id_entregador] (Muitos para Um)
fato_entregas[id_regiao] → dim_regioes[id_regiao] (Muitos para Um)
fato_entregas[id_status] → dim_status[id_status] (Muitos para Um)

📐 FASE 4: CRIAÇÃO DE MEDIDAS DAX

4.1 Medidas Básicas

dax// Total de Entregas
Total_Entregas = COUNTROWS(fato_entregas)

// Faturamento Total
Faturamento = SUM(fato_entregas[valor_entrega])

// Ticket Médio
Ticket_Medio = DIVIDE([Faturamento], [Total_Entregas], 0)

// Tempo Médio de Entrega
Tempo_Medio = AVERAGE(fato_entregas[tempo_entrega_min])

// Distância Média
Distancia_Media = AVERAGE(fato_entregas[distancia_km])

4.2 Medidas de Performance

dax// Taxa de Sucesso
Taxa_Sucesso = 
DIVIDE(
    CALCULATE([Total_Entregas], fato_entregas[status] = "Entregue"),
    [Total_Entregas],
    0
) * 100

// Taxa de Atraso
Taxa_Atraso = 
DIVIDE(
    CALCULATE([Total_Entregas], fato_entregas[classificacao_tempo] = "Atrasada"),
    [Total_Entregas],
    0
) * 100

// Entregas no Prazo
Entregas_No_Prazo = 
CALCULATE([Total_Entregas], fato_entregas[classificacao_tempo] = "No Prazo")

// Avaliação Média
Avaliacao_Media = AVERAGE(fato_entregas[avaliacao])
4.3 Medidas de Comparação Temporal
dax// Entregas Mês Anterior
Entregas_Mes_Anterior = 
CALCULATE(
    [Total_Entregas],
    DATEADD(dim_calendario[data], -1, MONTH)
)

// Variação % MoM (Month over Month)
Var_MoM = 
DIVIDE(
    [Total_Entregas] - [Entregas_Mes_Anterior],
    [Entregas_Mes_Anterior],
    0
) * 100

// Faturamento Acumulado no Ano
Faturamento_YTD = 
CALCULATE(
    [Faturamento],
    DATESYTD(dim_calendario[data])
)

// Média Móvel 7 dias
Media_Movel_7d = 
CALCULATE(
    [Total_Entregas],
    DATESINPERIOD(dim_calendario[data], LASTDATE(dim_calendario[data]), -7, DAY)
) / 7
4.4 Medidas de Ranking
dax// Rank Entregador por Volume
Rank_Entregador = 
RANKX(
    ALL(dim_entregadores[nome]),
    [Total_Entregas],
    ,
    DESC,
    DENSE
)

// Top 5 Entregadores (filtro)

Top5_Entregadores = IF([Rank_Entregador] <= 5, 1, 0)

// Percentual da Região no Total
Perc_Regiao = 
DIVIDE(
    [Total_Entregas],
    CALCULATE([Total_Entregas], ALL(dim_regioes)),
    0
) * 100
4.5 Medidas Condicionais
dax// Classificação de Performance
Classificacao_Performance = 
VAR TaxaSucesso = [Taxa_Sucesso]
RETURN
    SWITCH(
        TRUE(),
        TaxaSucesso >= 98, "Excelente",
        TaxaSucesso >= 95, "Bom",
        TaxaSucesso >= 90, "Regular",
        "Crítico"
    )

// Alerta de Atraso
Alerta_Atraso = 
IF([Taxa_Atraso] > 10, "⚠️ ATENÇÃO", "✓ OK")

// Meta Atingida
Meta_Atingida = 
IF([Total_Entregas] >= [Meta_Entregas], "Sim", "Não")

 FASE 5: DESENVOLVIMENTO DO DASHBOARD

5.1 Estrutura do Dashboard

Página 1: Visão Executiva

Cards com KPIs principais
Gráfico de linha: Tendência de entregas e faturamento
Gráfico de pizza: Distribuição por região
Indicadores de meta vs realizado

Página 2: Análise Operacional

Gráfico de barras: Entregas por dia da semana
Heatmap: Entregas por hora e dia
Tabela: Status detalhado das entregas
Filtro de período dinâmico

Página 3: Performance de Entregadores

Ranking dos top 10 entregadores
Gráfico de dispersão: Tempo médio vs Volume
Cards individuais com foto e estatísticas
Filtro por veículo e região

Página 4: Análise Geográfica

Mapa com concentração de entregas
Tabela dinâmica por região
Comparativo de performance regional
Análise de distância média por zona

5.2 Paleta de Cores
Cor Primária (Azul): #3b82f6
Cor Secundária (Verde): #10b981
Cor Destaque (Laranja): #f59e0b
Cor Alerta (Vermelho): #ef4444
Cor Neutra (Roxo): #8b5cf6
Background: #f9fafb
Texto: #1f2937
5.3 Interatividade Implementada
Filtros Globais:

Seletor de período (Hoje, Semana, Mês, Ano, Customizado)
Filtro de região
Filtro de status
Filtro de entregador

Drill-Through:

Clicar em uma região → Ver detalhes das entregas
Clicar em entregador → Ver histórico completo
Clicar em data → Ver entregas do dia

Tooltips Personalizados:

Ao passar mouse em gráficos: detalhes adicionais
Cards com minigráficos de tendência


 FASE 6: INSIGHTS E ANÁLISES REALIZADAS
6.1 Principais Descobertas
Análise Temporal:

✅ Sexta e sábado representam 35% do volume semanal
✅ Pico de pedidos: 18h às 21h (horário de jantar)
⚠️ Domingos têm o maior tempo médio de entrega (31 min)
⚠️ Segundas têm a menor taxa de sucesso (92%)

Análise Regional:

✅ Região Centro: maior volume (850 entregas/mês)
⚠️ Região Oeste: menor taxa de sucesso (88%)
✅ Região Sul: melhor avaliação média (4.7)
⚠️ Região Norte: maior distância média (8.5 km)

Performance de Entregadores:

✅ Top 5 respondem por 28% das entregas totais
⚠️ 12% dos entregadores estão abaixo da meta
✅ Entregadores de moto têm melhor tempo médio
⚠️ Alta rotatividade: 15 novos entregadores em 3 meses

Análise Financeira:

✅ Ticket médio subiu 8% no último trimestre
✅ Faturamento crescendo 12% ao mês
⚠️ Taxa de cancelamento aumentou de 1.5% para 2.8%

6.2 Recomendações
Curto Prazo (1-2 meses):

Aumentar equipe aos finais de semana (+20% de entregadores)
Criar incentivo para entregas expressas no horário de pico
Treinar equipe da Região Oeste para melhorar taxa de sucesso
Implementar roteirização otimizada na Região Norte

Médio Prazo (3-6 meses):

Abrir novo hub na Região Oeste para reduzir distâncias
Programa de retenção de entregadores top performers
Sistema de previsão de demanda por ML
App de acompanhamento em tempo real para clientes

Longo Prazo (6-12 meses):

Expansão para cidades vizinhas
Diversificação da frota (inclusão de bicicletas elétricas)
Parcerias estratégicas com restaurantes/lojas
Sistema de fidelidade para clientes recorrentes


 FASE 7: ATUALIZAÇÃO E MANUTENÇÃO
7.1 Schedule de Atualização
Dados Operacionais:

Frequência: A cada 30 minutos (via API)
Horário: 24/7
Método: Incremental (apenas novos registros)

Dados Financeiros:

Frequência: Diária
Horário: 06:00 AM
Método: Full refresh

Dados de Metas:

Frequência: Mensal
Horário: 1º dia útil do mês
Método: Manual (Excel)

7.2 Monitoramento de Qualidade
Checklist Diário:

 Verificar conexões com fontes de dados
 Validar total de entregas do dia
 Conferir se há valores nulos em campos críticos
 Comparar faturamento com sistema financeiro
 Verificar se houve falhas na atualização

Alertas Configurados:

Taxa de sucesso abaixo de 90%
Tempo médio acima de 35 minutos
Taxa de cancelamento acima de 3%
Queda de 20% no volume vs dia anterior


 FASE 8: MÉTRICAS DE SUCESSO DO PROJETO
8.1 KPIs do Projeto de BI
Adoção:

✅ 100% dos gestores acessam o dashboard diariamente
✅ Média de 45 acessos por dia
✅ Tempo médio de sessão: 12 minutos

Impacto nos Negócios:

✅ Redução de 15% no tempo médio de entrega
✅ Aumento de 23% na taxa de sucesso
✅ Redução de 40% no tempo de análise manual
✅ Economia de 8h/semana da equipe de análise

Satisfação:

✅ NPS do dashboard: 85
✅ 9 de 10 usuários classificam como "essencial"


 TECNOLOGIAS E FERRAMENTAS UTILIZADAS
CategoriaFerramentaFinalidadeSQL Server 14Banco principal de operaçõesDatabaseSQL Server 2019Dados financeirosETLPower QueryTransformação de dadosModelagemPower BI DesktopCriação do modelo dimensionalVisualizaçãoPower BI ServicePublicação e compartilhamentoVersionamentoGit/GitHubControle de versão de queriesDocumentaçãoConfluenceWiki do projetoGestãoclickup Acompanhamento de tasks

 DOCUMENTAÇÃO ADICIONAL

Arquivos do Projeto

📁 projeto-bi-logistica/
├── 📁 dados/
│   ├── queries_extracao.sql
│   ├── metas_regionais.xlsx
│   └── dicionario_dados.pdf
├── 📁 power-bi/
│   ├── modelo_dados.pbix
│   ├── dashboard_executivo.pbix
│   └── temas_customizados.json
├── 📁 documentacao/
│   ├── manual_usuario.pdf
│   ├── especificacao_tecnica.docx
│   └── apresentacao_resultados.pptx
└── README.md

Próximos Passos

Fase 9 - Expansão (Q2 2026):

 Integração com API de geolocalização em tempo real
 Machine Learning para previsão de demanda
 Dashboard mobile responsivo
 Alertas automáticos via WhatsApp/SMS
 



 EQUIPE DO PROJETO

projeto colaborativo

Analista de BI: Romaine Santos 
Stakeholder Principal: Gerente de Operações
Prazo: 45 dias
Status: ✅ Concluído e em Produção

Documento criado em: Janeiro de 2026
Última atualização: 22/01/2026
