-- ============================================================
-- Script 01: Criação de Tabelas
-- Descrição: Cria a estrutura de tabelas para o projeto BI
-- Data: 2026-01-23
-- ============================================================

-- Criar banco de dados
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BI_Database')
BEGIN
    CREATE DATABASE BI_Database;
END
GO

USE BI_Database;
GO

-- Tabela de Clientes
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Clientes')
BEGIN
    CREATE TABLE Clientes (
        ClienteID INT PRIMARY KEY IDENTITY(1,1),
        Nome NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100),
        Telefone NVARCHAR(20),
        Cidade NVARCHAR(50),
        Estado NVARCHAR(2),
        DataCadastro DATETIME DEFAULT GETDATE()
    );
END
GO

-- Tabela de Produtos
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Produtos')
BEGIN
    CREATE TABLE Produtos (
        ProdutoID INT PRIMARY KEY IDENTITY(1,1),
        Nome NVARCHAR(100) NOT NULL,
        Categoria NVARCHAR(50),
        Preco DECIMAL(10, 2),
        Estoque INT,
        DataCadastro DATETIME DEFAULT GETDATE()
    );
END
GO

-- Tabela de Vendas
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Vendas')
BEGIN
    CREATE TABLE Vendas (
        VendaID INT PRIMARY KEY IDENTITY(1,1),
        ClienteID INT NOT NULL,
        ProdutoID INT NOT NULL,
        DataVenda DATETIME DEFAULT GETDATE(),
        Quantidade INT,
        PrecoUnitario DECIMAL(10, 2),
        ValorTotal DECIMAL(10, 2),
        FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
        FOREIGN KEY (ProdutoID) REFERENCES Produtos(ProdutoID)
    );
END
GO

PRINT '✅ Tabelas criadas com sucesso!';

