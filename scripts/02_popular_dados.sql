-- ============================================================
-- Script 02: Popular Dados
-- Descrição: Insere dados de exemplo nas tabelas
-- Data: 2026-01-23
-- ============================================================

USE BI_Database;
GO

-- Inserir dados em Clientes
INSERT INTO Clientes (Nome, Email, Telefone, Cidade, Estado)
VALUES
    ('João Silva', 'joao@email.com', '11999999999', 'São Paulo', 'SP'),
    ('Maria Santos', 'maria@email.com', '21988888888', 'Rio de Janeiro', 'RJ'),
    ('Pedro Oliveira', 'pedro@email.com', '85987777777', 'Fortaleza', 'CE'),
    ('Ana Costa', 'ana@email.com', '31986666666', 'Belo Horizonte', 'MG'),
    ('Carlos Ferreira', 'carlos@email.com', '47985555555', 'Joinville', 'SC');
GO

-- Inserir dados em Produtos
INSERT INTO Produtos (Nome, Categoria, Preco, Estoque)
VALUES
    ('Notebook Dell', 'Eletrônicos', 3500.00, 15),
    ('Mouse Logitech', 'Periféricos', 85.50, 50),
    ('Teclado Mecânico', 'Periféricos', 450.00, 25),
    ('Monitor LG 24"', 'Monitores', 950.00, 10),
    ('Webcam HD', 'Periféricos', 250.00, 30),
    ('Headset Gamer', 'Áudio', 320.00, 20),
    ('SSD 1TB', 'Armazenamento', 650.00, 35),
    ('RAM 16GB', 'Memória', 280.00, 40);
GO

-- Inserir dados em Vendas
INSERT INTO Vendas (ClienteID, ProdutoID, Quantidade, PrecoUnitario, ValorTotal)
VALUES
    (1, 1, 1, 3500.00, 3500.00),
    (1, 2, 2, 85.50, 171.00),
    (2, 3, 1, 450.00, 450.00),
    (2, 6, 1, 320.00, 320.00),
    (3, 4, 2, 950.00, 1900.00),
    (4, 7, 1, 650.00, 650.00),
    (5, 8, 2, 280.00, 560.00),
    (1, 5, 1, 250.00, 250.00);
GO

PRINT '✅ Dados inseridos com sucesso!';
