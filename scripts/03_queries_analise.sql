-- ============================================================
-- Script 03: Queries de Análise
-- Descrição: Queries para análise de dados e relatórios
-- Data: 2026-01-23
-- ============================================================

USE BI_Database;
GO

-- Query 1: Total de vendas por cliente
SELECT 
    c.ClienteID,
    c.Nome AS Cliente,
    COUNT(v.VendaID) AS QuantidadeVendas,
    SUM(v.ValorTotal) AS ValorTotal,
    AVG(v.ValorTotal) AS TicketMédio
FROM Clientes c
LEFT JOIN Vendas v ON c.ClienteID = v.ClienteID
GROUP BY c.ClienteID, c.Nome
ORDER BY SUM(v.ValorTotal) DESC;
GO

-- Query 2: Vendas por produto
SELECT 
    p.ProdutoID,
    p.Nome AS Produto,
    p.Categoria,
    COUNT(v.VendaID) AS QuantidadeVendida,
    SUM(v.Quantidade) AS UnidadesVendidas,
    SUM(v.ValorTotal) AS ReceitaTotal,
    AVG(v.PrecoUnitario) AS PrecoMédio
FROM Produtos p
LEFT JOIN Vendas v ON p.ProdutoID = v.ProdutoID
GROUP BY p.ProdutoID, p.Nome, p.Categoria
ORDER BY SUM(v.ValorTotal) DESC;
GO

-- Query 3: Vendas por estado
SELECT 
    c.Estado,
    COUNT(v.VendaID) AS QuantidadeVendas,
    SUM(v.ValorTotal) AS ValorTotal,
    COUNT(DISTINCT c.ClienteID) AS QuantidadeClientes
FROM Clientes c
LEFT JOIN Vendas v ON c.ClienteID = v.ClienteID
GROUP BY c.Estado
ORDER BY SUM(v.ValorTotal) DESC;
GO

-- Query 4: Análise temporal de vendas
SELECT 
    CAST(v.DataVenda AS DATE) AS Data,
    COUNT(v.VendaID) AS QuantidadeVendas,
    SUM(v.ValorTotal) AS ValorDia,
    AVG(v.ValorTotal) AS TicketMédio
FROM Vendas v
GROUP BY CAST(v.DataVenda AS DATE)
ORDER BY CAST(v.DataVenda AS DATE) DESC;
GO

-- Query 5: Top 5 produtos mais vendidos
SELECT TOP 5
    p.Nome AS Produto,
    p.Categoria,
    COUNT(v.VendaID) AS Vendas,
    SUM(v.Quantidade) AS UnidadesVendidas,
    SUM(v.ValorTotal) AS ReceitaTotal
FROM Produtos p
JOIN Vendas v ON p.ProdutoID = v.ProdutoID
GROUP BY p.ProdutoID, p.Nome, p.Categoria
ORDER BY SUM(v.Quantidade) DESC;
GO

PRINT '✅ Queries preparadas para análise!';
