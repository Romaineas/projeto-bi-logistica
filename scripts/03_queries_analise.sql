-- ========================================
-- PROJETO BI LOGÍSTICA E DELIVERY
-- Queries de Análise para Power BI
-- ========================================

USE DB_Logistica_Delivery;
GO

-- ========================================
-- QUERY 1: DADOS CONSOLIDADOS PARA POWER BI
-- Use como fonte principal no Power BI
-- ========================================

SELECT 
    e.id_entrega,
    
    -- Datas
    e.data_pedido,
    e.data_coleta,
    e.data_entrega,
    CAST(e.data_pedido AS DATE) AS data_pedido_only,
    DATENAME(WEEKDAY, e.data_pedido) AS dia_semana,
    DATEPART(WEEKDAY, e.data_pedido) AS numero_dia_semana,
    DATEPART(HOUR, e.data_pedido) AS hora_pedido,
    DATEPART(MONTH, e.data_pedido) AS mes,
    DATEPART(YEAR, e.data_pedido) AS ano,
    
    -- Status e Classificações
    e.status,
    CASE 
        WHEN e.status = 'Entregue' THEN 'Concluída'
        WHEN e.status IN ('Em Rota', 'Coletado') THEN 'Em Andamento'
        WHEN e.status = 'Cancelada' THEN 'Cancelada'
        ELSE 'Outros'
    END AS grupo_status,
    
    -- Valores
    e.valor_entrega,
    e.distancia_km,
    
    -- Tempo
    DATEDIFF(MINUTE, e.data_coleta, e.data_entrega) AS tempo_entrega_min,
    CASE 
        WHEN DATEDIFF(MINUTE, e.data_coleta, e.data_entrega) <= 30 THEN 'No Prazo'
        WHEN DATEDIFF(MINUTE, e.data_coleta, e.data_entrega) > 30 THEN 'Atrasada'
        ELSE 'Sem Dados'
    END AS classificacao_tempo,
    
    -- Turno
    CASE 
        WHEN DATEPART(HOUR, e.data_pedido) >= 6 AND DATEPART(HOUR, e.data_pedido) < 12 THEN 'Manhã'
        WHEN DATEPART(HOUR, e.data_pedido) >= 12 AND DATEPART(HOUR, e.data_pedido) < 18 THEN 'Tarde'
        WHEN DATEPART(HOUR, e.data_pedido) >= 18 AND DATEPART(HOUR, e.data_pedido) < 24 THEN 'Noite'
        ELSE 'Madrugada'
    END AS turno,
    
    -- Avaliação
    e.avaliacao,
    CASE 
        WHEN e.avaliacao >= 5 THEN 'Excelente'
        WHEN e.avaliacao = 4 THEN 'Bom'
        WHEN e.avaliacao = 3 THEN 'Regular'
        WHEN e.avaliacao <= 2 THEN 'Ruim'
        ELSE 'Sem Avaliação'
    END AS classificacao_avaliacao,
    
    -- Entregador
    e.id_entregador,
    ent.nome AS nome_entregador,
    ent.veiculo,
    ent.status AS status_entregador,
    
    -- Cliente
    e.id_cliente,
    c.nome AS nome_cliente,
    c.tipo_cliente,
    
    -- Região
    e.id_regiao,
    r.nome_regiao,
    r.zona,
    r.cidade,
    r.estado,
    
    -- Flags
    CASE WHEN e.status = 'Entregue' THEN 1 ELSE 0 END AS flag_sucesso,
    CASE WHEN e.status = 'Cancelada' THEN 1 ELSE 0 END AS flag_cancelada,
    CASE WHEN DATEDIFF(MINUTE, e.data_coleta, e.data_entrega) > 30 THEN 1 ELSE 0 END AS flag_atrasada
    
FROM tb_entregas e
INNER JOIN tb_entregadores ent ON e.id_entregador = ent.id_entregador
INNER JOIN tb_clientes c ON e.id_cliente = c.id_cliente
INNER JOIN tb_regioes r ON e.id_regiao = r.id_regiao;

GO

-- ========================================
-- QUERY 2: KPIs PRINCIPAIS
-- Para cards de resumo
-- ========================================

SELECT 
    -- Totalizadores
    COUNT(*) AS total_entregas,
    COUNT(DISTINCT id_entregador) AS total_entregadores,
    COUNT(DISTINCT id_cliente) AS total_clientes,
    
    -- Sucessos
    SUM(CASE WHEN status = 'Entregue' THEN 1 ELSE 0 END) AS entregas_concluidas,
    SUM(CASE WHEN status = 'Cancelada' THEN 1 ELSE 0 END) AS entregas_canceladas,
    SUM(CASE WHEN status IN ('Em Rota', 'Coletado') THEN 1 ELSE 0 END) AS entregas_andamento,
    
    -- Taxas (%)
    CAST(SUM(CASE WHEN status = 'Entregue' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS taxa_sucesso,
    CAST(SUM(CASE WHEN status = 'Cancelada' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS taxa_cancelamento,
    
    -- Financeiro
    SUM(valor_entrega) AS faturamento_total,
    AVG(valor_entrega) AS ticket_medio,
    MAX(valor_entrega) AS maior_pedido,
    MIN(valor_entrega) AS menor_pedido,
    
    -- Operacional
    AVG(CASE WHEN data_entrega IS NOT NULL 
        THEN DATEDIFF(MINUTE, data_coleta, data_entrega) END) AS tempo_medio_entrega,
    AVG(distancia_km) AS distancia_media,
    
    -- Satisfação
    AVG(avaliacao) AS avaliacao_media
    
FROM tb_entregas;

GO

-- ========================================
-- QUERY 3: PERFORMANCE POR ENTREGADOR
-- Ranking de entregadores
-- ========================================

SELECT 
    ent.id_entregador,
    ent.nome,
    ent.veiculo,
    
    -- Volume
    COUNT(e.id_entrega) AS total_entregas,
    SUM(CASE WHEN e.status = 'Entregue' THEN 1 ELSE 0 END) AS entregas_sucesso,
    
    -- Taxa de sucesso
    CAST(SUM(CASE WHEN e.status = 'Entregue' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(e.id_entrega), 0) AS DECIMAL(5,2)) AS taxa_sucesso,
    
    -- Tempo
    AVG(CASE WHEN e.data_entrega IS NOT NULL 
        THEN DATEDIFF(MINUTE, e.data_coleta, e.data_entrega) END) AS tempo_medio_min,
    
    -- Financeiro
    SUM(e.valor_entrega) AS faturamento_gerado,
    AVG(e.valor_entrega) AS ticket_medio,
    
    -- Satisfação
    AVG(e.avaliacao) AS nota_media,
    
    -- Distância
    SUM(e.distancia_km) AS km_total,
    AVG(e.distancia_km) AS km_medio,
    
    -- Ranking
    RANK() OVER (ORDER BY COUNT(e.id_entrega) DESC) AS rank_volume,
    RANK() OVER (ORDER BY AVG(e.avaliacao) DESC) AS rank_avaliacao
    
FROM tb_entregadores ent
LEFT JOIN tb_entregas e ON ent.id_entregador = e.id_entregador
WHERE ent.status = 'Ativo'
GROUP BY ent.id_entregador, ent.nome, ent.veiculo
ORDER BY total_entregas DESC;

GO

-- ========================================
-- QUERY 4: ANÁLISE POR REGIÃO
-- Performance regional
-- ========================================

SELECT 
    r.id_regiao,
    r.nome_regiao,
    r.zona,
    
    -- Volume
    COUNT(e.id_entrega) AS total_entregas,
    SUM(CASE WHEN e.status = 'Entregue' THEN 1 ELSE 0 END) AS entregas_sucesso,
    
    -- Taxa de sucesso
    CAST(SUM(CASE WHEN e.status = 'Entregue' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(e.id_entrega), 0) AS DECIMAL(5,2)) AS taxa_sucesso,
    
    -- Financeiro
    SUM(e.valor_entrega) AS faturamento,
    AVG(e.valor_entrega) AS ticket_medio,
    
    -- Operacional
    AVG(DATEDIFF(MINUTE, e.data_coleta, e.data_entrega)) AS tempo_medio_min,
    AVG(e.distancia_km) AS distancia_media,
    
    -- Satisfação
    AVG(e.avaliacao) AS avaliacao_media
    
FROM tb_regioes r
LEFT JOIN tb_entregas e ON r.id_regiao = e.id_regiao
GROUP BY r.id_regiao, r.nome_regiao, r.zona
ORDER BY total_entregas DESC;

GO

-- ========================================
-- QUERY 5: ANÁLISE TEMPORAL - DIA DA SEMANA
-- Para gráfico de tendência semanal
-- ========================================

SELECT 
    DATENAME(WEEKDAY, data_pedido) AS dia_semana,
    DATEPART(WEEKDAY, data_pedido) AS ordem_dia,
    
    COUNT(*) AS total_entregas,
    SUM(valor_entrega) AS faturamento,
    AVG(valor_entrega) AS ticket_medio,
    AVG(DATEDIFF(MINUTE, data_coleta, data_entrega)) AS tempo_medio_min,
    AVG(avaliacao) AS avaliacao_media,
    
    SUM(CASE WHEN status = 'Entregue' THEN 1 ELSE 0 END) AS entregas_sucesso,
    CAST(SUM(CASE WHEN status = 'Entregue' THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(*) AS DECIMAL(5,2)) AS taxa_sucesso
    
FROM tb_entregas
GROUP BY DATENAME(WEEKDAY, data_pedido), DATEPART(WEEKDAY, data_pedido)
ORDER BY ordem_dia;

GO

-- ========================================
-- QUERY 6: ANÁLISE POR HORA DO DIA
-- Heatmap de horários
-- ========================================

SELECT 
    DATEPART(HOUR, data_pedido) AS hora,
    
    COUNT(*) AS total_entregas,
    SUM(valor_entrega) AS faturamento,
    AVG(DATEDIFF(MINUTE, data_coleta, data_entrega)) AS tempo_medio_min
    
FROM tb_entregas
WHERE DATEPART(HOUR, data_pedido) BETWEEN 6 AND 23
GROUP BY DATEPART(HOUR, data_pedido)
ORDER BY hora;

GO

-- ========================================
-- QUERY 7: COMPARATIVO META VS REALIZADO
-- ========================================

SELECT 
    r.nome_regiao,
    m.meta_entregas,
    COUNT(e.id_entrega) AS entregas_realizadas,
    COUNT(e.id_entrega) - m.meta_entregas AS variacao_absoluta,
    CAST((COUNT(e.id_entrega) - m.meta_entregas) * 100.0 / 
        NULLIF(m.meta_entregas, 0) AS DECIMAL(5,2)) AS variacao_percentual,
    
    m.meta_faturamento,
    SUM(e.valor_entrega) AS faturamento_realizado,
    
    m.meta_tempo_medio,
    AVG(DATEDIFF(MINUTE, e.data_coleta, e.data_entrega)) AS tempo_medio_realizado,
    
    m.meta_taxa_sucesso,
    CAST(SUM(CASE WHEN e.status = 'Entregue' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS taxa_sucesso_realizada,
    
    CASE 
        WHEN COUNT(e.id_entrega) >= m.meta_entregas THEN 'Meta Atingida'
        WHEN COUNT(e.id_entrega) >= m.meta_entregas * 0.9 THEN 'Próximo da Meta'
        ELSE 'Abaixo da Meta'
    END AS status_meta
    
FROM tb_regioes r
INNER JOIN tb_metas m ON r.id_regiao = m.id_regiao
LEFT JOIN tb_entregas e ON r.id_regiao = e.id_regiao
GROUP BY r.nome_regiao, m.meta_entregas, m.meta_faturamento, m.meta_tempo_medio, m.meta_taxa_sucesso
ORDER BY entregas_realizadas DESC;

GO

-- ========================================
-- QUERY 8: TOP CLIENTES
-- ========================================

SELECT TOP 10
    c.nome AS nome_cliente,
    c.tipo_cliente,
    r.nome_regiao,
    
    COUNT(e.id_entrega) AS total_pedidos,
    SUM(e.valor_entrega) AS valor_total_gasto,
    AVG(e.valor_entrega) AS ticket_medio,
    AVG(e.avaliacao) AS avaliacao_media,
    
    MAX(e.data_pedido) AS ultima_compra
    
FROM tb_clientes c
LEFT JOIN tb_entregas e ON c.id_cliente = e.id_cliente
INNER JOIN tb_regioes r ON c.id_regiao = r.id_regiao
GROUP BY c.nome, c.tipo_cliente, r.nome_regiao
ORDER BY valor_total_gasto DESC;

GO

-- ========================================
-- QUERY 9: RESUMO EXECUTIVO
-- Dashboard executivo
-- ========================================

SELECT 
    'RESUMO EXECUTIVO' AS secao,
    
    -- Volume
    (SELECT COUNT(*) FROM tb_entregas) AS total_entregas,
    (SELECT COUNT(*) FROM tb_entregas WHERE status = 'Entregue') AS entregas_concluidas,
    (SELECT COUNT(*) FROM tb_entregas WHERE status = 'Cancelada') AS entregas_canceladas,
    
    -- Performance
    (SELECT CAST(AVG(CAST(avaliacao AS FLOAT)) AS DECIMAL(3,1)) FROM tb_entregas WHERE avaliacao IS NOT NULL) AS nota_media,
    (SELECT AVG(DATEDIFF(MINUTE, data_coleta, data_entrega)) FROM tb_entregas WHERE data_entrega IS NOT NULL) AS tempo_medio_min,
    
    -- Financeiro
    (SELECT SUM(valor_entrega) FROM tb_entregas) AS faturamento_total,
    (SELECT AVG(valor_entrega) FROM tb_entregas) AS ticket_medio,
    
    -- Recursos
    (SELECT COUNT(*) FROM tb_entregadores WHERE status = 'Ativo') AS entregadores_ativos,
    (SELECT COUNT(DISTINCT id_cliente) FROM tb_entregas) AS clientes_atendidos,
    (SELECT COUNT(*) FROM tb_regioes WHERE ativa = 1) AS regioes_ativas;

GO

PRINT '========================================';
PRINT 'QUERIES DE ANÁLISE CRIADAS COM SUCESSO!';
PRINT '========================================';
PRINT 'Use estas queries como fonte de dados no Power BI';
PRINT '========================================';

