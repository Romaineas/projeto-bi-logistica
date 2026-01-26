-- ========================================
-- LIMPAR DADOS DAS TABELAS
-- (Mantém a estrutura, apaga só os dados)
-- ========================================

USE DB_Logistica_Delivery;
GO

-- Desabilitar checagem de Foreign Keys temporariamente
-- (para poder deletar na ordem que quiser)
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

-- Deletar dados de todas as tabelas
DELETE FROM tb_entregas;
DELETE FROM tb_metas;
DELETE FROM tb_clientes;
DELETE FROM tb_entregadores;
DELETE FROM tb_regioes;

-- Resetar os IDs auto-incremento (IDENTITY)
DBCC CHECKIDENT ('tb_entregas', RESEED, 0);
DBCC CHECKIDENT ('tb_metas', RESEED, 0);

-- Reabilitar checagem de Foreign Keys
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
GO

PRINT '========================================';
PRINT 'DADOS DELETADOS COM SUCESSO!';
PRINT '========================================';

-- Verificar se está tudo zerado
SELECT 'tb_regioes' AS Tabela, COUNT(*) AS Total FROM tb_regioes
UNION ALL
SELECT 'tb_entregadores', COUNT(*) FROM tb_entregadores
UNION ALL
SELECT 'tb_clientes', COUNT(*) FROM tb_clientes
UNION ALL
SELECT 'tb_metas', COUNT(*) FROM tb_metas
UNION ALL
SELECT 'tb_entregas', COUNT(*) FROM tb_entregas;

PRINT 'Todas as tabelas estão vazias!';








-- ========================================
-- PROJETO BI LOGÍSTICA E DELIVERY
-- Script de População de Dados
-- ========================================

USE DB_Logistica_Delivery;
GO

-- ========================================
-- INSERIR REGIÕES
-- ========================================
INSERT INTO tb_regioes (id_regiao, nome_regiao, zona, cidade, estado) VALUES
(1, 'Centro', 'Urbana', 'Ilhéus', 'BA'),
(2, 'Norte', 'Urbana', 'Ilhéus', 'BA'),
(3, 'Sul', 'Urbana', 'Ilhéus', 'BA'),
(4, 'Leste', 'Urbana', 'Ilhéus', 'BA'),
(5, 'Oeste', 'Suburbana', 'Ilhéus', 'BA');

PRINT 'Regiões inseridas com sucesso!';
GO

-- ========================================
-- INSERIR ENTREGADORES
-- ========================================
INSERT INTO tb_entregadores (id_entregador, nome, cpf, data_admissao, veiculo, telefone, email) VALUES
(1, 'João Silva', '123.456.789-01', '2023-01-10', 'Moto', '(73) 98765-4321', 'joao.silva@email.com'),
(2, 'Maria Santos', '234.567.890-12', '2023-02-01', 'Moto', '(73) 98765-4322', 'maria.santos@email.com'),
(3, 'Pedro Costa', '345.678.901-23', '2023-03-15', 'Moto', '(73) 98765-4323', 'pedro.costa@email.com'),
(4, 'Ana Oliveira', '456.789.012-34', '2023-01-20', 'Moto', '(73) 98765-4324', 'ana.oliveira@email.com'),
(5, 'Carlos Souza', '567.890.123-45', '2023-04-01', 'Carro', '(73) 98765-4325', 'carlos.souza@email.com');

PRINT 'Entregadores inseridos com sucesso!';
GO

-- ========================================
-- INSERIR CLIENTES
-- ========================================
INSERT INTO tb_clientes (id_cliente, nome, telefone, id_regiao, tipo_cliente) VALUES
(1, 'Restaurante Sabor da Bahia', '(73) 3634-1001', 1, 'Restaurante'),
(2, 'Pizzaria Bella Napoli', '(73) 3634-1002', 1, 'Restaurante'),
(3, 'Farmácia Saúde Total', '(73) 3634-1003', 2, 'Loja'),
(4, 'Maria da Silva', '(73) 99876-5432', 1, 'Pessoa Física'),
(5, 'José Santos', '(73) 99876-5433', 2, 'Pessoa Física');

PRINT 'Clientes inseridos com sucesso!';
GO

-- ========================================
-- INSERIR METAS
-- ========================================
SET DATEFORMAT ymd;

INSERT INTO tb_metas (mes_referencia, id_regiao, meta_entregas, meta_faturamento, meta_tempo_medio, meta_taxa_sucesso) VALUES
('2026-01-01', 1, 900, 45000.00, 25, 96.00),
('2026-01-01', 2, 650, 32500.00, 28, 95.00),
('2026-01-01', 3, 600, 30000.00, 27, 96.00),
('2026-01-01', 4, 500, 25000.00, 30, 94.00),
('2026-01-01', 5, 400, 20000.00, 32, 93.00);

PRINT 'Metas inseridas com sucesso!';
GO

-- ========================================
-- INSERIR ENTREGAS
-- ========================================
SET DATEFORMAT ymd;

-- Região Centro
INSERT INTO tb_entregas (id_entregador, id_cliente, id_regiao, data_pedido, data_coleta, data_entrega, status, valor_entrega, distancia_km, avaliacao) VALUES
(1, 1, 1, '2026-01-20 18:30:00', '2026-01-20 18:35:00', '2026-01-20 19:02:00', 'Entregue', 45.00, 3.5, 5),
(2, 2, 1, '2026-01-20 19:15:00', '2026-01-20 19:20:00', '2026-01-20 19:42:00', 'Entregue', 52.50, 4.2, 4),
(3, 1, 1, '2026-01-20 20:00:00', '2026-01-20 20:05:00', '2026-01-20 20:28:00', 'Entregue', 38.00, 2.8, 5),
(1, 4, 1, '2026-01-21 12:30:00', '2026-01-21 12:35:00', '2026-01-21 12:58:00', 'Entregue', 25.00, 5.1, 4),
(2, 2, 1, '2026-01-21 18:45:00', '2026-01-21 18:50:00', '2026-01-21 19:15:00', 'Entregue', 48.00, 3.9, 5),
(4, 1, 1, '2026-01-21 19:30:00', '2026-01-21 19:35:00', '2026-01-21 20:10:00', 'Entregue', 55.00, 6.2, 4),
(1, 4, 1, '2026-01-22 11:00:00', '2026-01-22 11:05:00', '2026-01-22 11:32:00', 'Entregue', 32.00, 4.5, 5),
(3, 2, 1, '2026-01-22 18:00:00', '2026-01-22 18:05:00', '2026-01-22 18:29:00', 'Entregue', 42.00, 3.2, 5),
(2, 1, 1, '2026-01-22 19:20:00', '2026-01-22 19:25:00', '2026-01-22 19:50:00', 'Entregue', 47.50, 4.8, 4),
(5, 4, 1, '2026-01-23 12:15:00', '2026-01-23 12:20:00', '2026-01-23 12:45:00', 'Entregue', 28.00, 3.7, 5);

-- Região Norte
INSERT INTO tb_entregas (id_entregador, id_cliente, id_regiao, data_pedido, data_coleta, data_entrega, status, valor_entrega, distancia_km, avaliacao) VALUES
(1, 3, 2, '2026-01-20 14:00:00', '2026-01-20 14:05:00', '2026-01-20 14:35:00', 'Entregue', 35.00, 5.5, 4),
(2, 5, 2, '2026-01-20 15:30:00', '2026-01-20 15:35:00', '2026-01-20 16:10:00', 'Entregue', 22.00, 6.8, 3),
(3, 3, 2, '2026-01-21 10:00:00', '2026-01-21 10:05:00', '2026-01-21 10:38:00', 'Entregue', 40.00, 7.2, 4),
(4, 5, 2, '2026-01-21 16:00:00', '2026-01-21 16:05:00', '2026-01-21 16:42:00', 'Entregue', 30.00, 6.0, 5),
(1, 3, 2, '2026-01-22 13:00:00', '2026-01-22 13:05:00', '2026-01-22 13:40:00', 'Entregue', 38.00, 5.9, 4),
(2, 5, 2, '2026-01-22 17:30:00', '2026-01-22 17:35:00', '2026-01-22 18:15:00', 'Entregue', 27.00, 7.5, 4),
(5, 3, 2, '2026-01-23 11:00:00', '2026-01-23 11:05:00', '2026-01-23 11:45:00', 'Entregue', 45.00, 8.2, 5),
(3, 5, 2, '2026-01-23 15:00:00', '2026-01-23 15:05:00', '2026-01-23 15:48:00', 'Atrasada', 33.00, 9.1, 3);

-- Região Sul
INSERT INTO tb_entregas (id_entregador, id_cliente, id_regiao, data_pedido, data_coleta, data_entrega, status, valor_entrega, distancia_km, avaliacao) VALUES
(1, 4, 3, '2026-01-20 12:00:00', '2026-01-20 12:05:00', '2026-01-20 12:28:00', 'Entregue', 29.00, 4.2, 5),
(2, 4, 3, '2026-01-20 18:00:00', '2026-01-20 18:05:00', '2026-01-20 18:30:00', 'Entregue', 36.00, 3.8, 5),
(3, 5, 3, '2026-01-21 11:30:00', '2026-01-21 11:35:00', '2026-01-21 12:00:00', 'Entregue', 24.00, 3.5, 4),
(4, 4, 3, '2026-01-21 19:00:00', '2026-01-21 19:05:00', '2026-01-21 19:28:00', 'Entregue', 41.00, 4.0, 5),
(1, 5, 3, '2026-01-22 12:30:00', '2026-01-22 12:35:00', '2026-01-22 12:58:00', 'Entregue', 31.00, 3.9, 4),
(5, 4, 3, '2026-01-22 18:30:00', '2026-01-22 18:35:00', '2026-01-22 19:05:00', 'Entregue', 44.00, 5.2, 5),
(2, 5, 3, '2026-01-23 13:00:00', '2026-01-23 13:05:00', '2026-01-23 13:35:00', 'Entregue', 26.00, 4.5, 5);

-- Região Leste
INSERT INTO tb_entregas (id_entregador, id_cliente, id_regiao, data_pedido, data_coleta, data_entrega, status, valor_entrega, distancia_km, avaliacao) VALUES
(1, 4, 4, '2026-01-20 16:00:00', '2026-01-20 16:05:00', '2026-01-20 16:40:00', 'Entregue', 34.00, 6.5, 4),
(3, 5, 4, '2026-01-21 14:00:00', '2026-01-21 14:05:00', '2026-01-21 14:48:00', 'Atrasada', 28.00, 8.0, 3),
(2, 4, 4, '2026-01-21 17:00:00', '2026-01-21 17:05:00', '2026-01-21 17:35:00', 'Entregue', 39.00, 5.8, 4),
(4, 5, 4, '2026-01-22 15:00:00', '2026-01-22 15:05:00', '2026-01-22 15:42:00', 'Entregue', 32.00, 6.2, 5),
(1, 4, 4, '2026-01-23 16:00:00', '2026-01-23 16:05:00', '2026-01-23 16:38:00', 'Entregue', 37.00, 5.9, 4);

-- Região Oeste
INSERT INTO tb_entregas (id_entregador, id_cliente, id_regiao, data_pedido, data_coleta, data_entrega, status, valor_entrega, distancia_km, avaliacao) VALUES
(1, 5, 5, '2026-01-20 11:00:00', '2026-01-20 11:05:00', '2026-01-20 11:50:00', 'Atrasada', 26.00, 9.5, 3),
(2, 4, 5, '2026-01-20 17:00:00', '2026-01-20 17:05:00', '2026-01-20 17:48:00', 'Atrasada', 30.00, 8.8, 3),
(3, 5, 5, '2026-01-21 13:00:00', '2026-01-21 13:05:00', '2026-01-21 13:40:00', 'Entregue', 35.00, 7.2, 4),
(5, 4, 5, '2026-01-22 14:00:00', '2026-01-22 14:05:00', '2026-01-22 14:45:00', 'Entregue', 42.00, 8.5, 4),
(1, 5, 5, '2026-01-23 12:00:00', '2026-01-23 12:05:00', NULL, 'Em Rota', 28.00, 7.8, NULL);

-- Entregas Canceladas
INSERT INTO tb_entregas (id_entregador, id_cliente, id_regiao, data_pedido, data_coleta, data_entrega, status, valor_entrega, distancia_km, avaliacao) VALUES
(2, 1, 1, '2026-01-20 20:30:00', '2026-01-20 20:35:00', NULL, 'Cancelada', 50.00, NULL, NULL),
(3, 2, 2, '2026-01-21 21:00:00', '2026-01-21 21:05:00', NULL, 'Cancelada', 45.00, NULL, NULL);

PRINT 'Entregas inseridas com sucesso!';
GO

-- ========================================
-- RESUMO FINAL
-- ========================================
PRINT '========================================';
PRINT 'POPULAÇÃO DE DADOS CONCLUÍDA!';
PRINT '========================================';

SELECT 'Regiões' AS Tabela, COUNT(*) AS Total FROM tb_regioes
UNION ALL
SELECT 'Entregadores', COUNT(*) FROM tb_entregadores
UNION ALL
SELECT 'Clientes', COUNT(*) FROM tb_clientes
UNION ALL
SELECT 'Metas', COUNT(*) FROM tb_metas
UNION ALL
SELECT 'Entregas', COUNT(*) FROM tb_entregas;

PRINT '========================================';



select * from tb_entregadores
select * from tb_clientes
select * from tb_metas
select * from tb_entregas
select * from tb_regioes




