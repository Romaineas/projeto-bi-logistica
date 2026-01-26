
 -- ========================================
-- PROJETO BI LOGÍSTICA E DELIVERY
-- Script de Criação de Tabelas
-- ========================================

CREATE DATABASE DB_Logistica_Delivery;
GO

USE DB_Logistica_Delivery;
GO

-- ========================================
-- TABELA: tb_regioes
-- ========================================
CREATE TABLE tb_regioes (
    id_regiao INT PRIMARY KEY,
    nome_regiao VARCHAR(50) NOT NULL,
    zona VARCHAR(20),
    cidade VARCHAR(50) DEFAULT 'Ilhéus',
    estado CHAR(2) DEFAULT 'BA',
    ativa BIT DEFAULT 1,
    data_cadastro DATETIME DEFAULT GETDATE()
);

-- ========================================
-- TABELA: tb_entregadores
-- ========================================
CREATE TABLE tb_entregadores (
    id_entregador INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    data_nascimento DATE,
    data_admissao DATE NOT NULL,
    veiculo VARCHAR(20) CHECK (veiculo IN ('Moto', 'Carro', 'Bicicleta', 'Bike Elétrica')),
    status VARCHAR(20) CHECK (status IN ('Ativo', 'Inativo', 'Férias', 'Afastado')) DEFAULT 'Ativo',
    telefone VARCHAR(15),
    email VARCHAR(100),
    data_cadastro DATETIME DEFAULT GETDATE()
);

-- ========================================
-- TABELA: tb_clientes
-- ========================================
CREATE TABLE tb_clientes (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    endereco VARCHAR(200),
    id_regiao INT,
    tipo_cliente VARCHAR(20) CHECK (tipo_cliente IN ('Pessoa Física', 'Restaurante', 'Loja', 'Empresa')),
    ativo BIT DEFAULT 1,
    data_cadastro DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_regiao) REFERENCES tb_regioes(id_regiao)
);

-- ========================================
-- TABELA: tb_entregas (FATO)
-- ========================================
CREATE TABLE tb_entregas (
    id_entrega INT PRIMARY KEY IDENTITY(1,1),
    id_entregador INT NOT NULL,
    id_cliente INT NOT NULL,
    id_regiao INT NOT NULL,
    data_pedido DATETIME NOT NULL,
    data_coleta DATETIME,
    data_entrega DATETIME,
    status VARCHAR(20) CHECK (status IN ('Pendente', 'Coletado', 'Em Rota', 'Entregue', 'Atrasada', 'Cancelada')) DEFAULT 'Pendente',
    valor_entrega DECIMAL(10,2) NOT NULL CHECK (valor_entrega >= 0),
    distancia_km DECIMAL(5,2),
    avaliacao INT CHECK (avaliacao BETWEEN 1 AND 5),
    data_cadastro DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_entregador) REFERENCES tb_entregadores(id_entregador),
    FOREIGN KEY (id_cliente) REFERENCES tb_clientes(id_cliente),
    FOREIGN KEY (id_regiao) REFERENCES tb_regioes(id_regiao)
);

-- ========================================
-- TABELA: tb_metas
-- ========================================
CREATE TABLE tb_metas (
    id_meta INT PRIMARY KEY IDENTITY(1,1),
    mes_referencia DATE NOT NULL,
    id_regiao INT,
    meta_entregas INT,
    meta_faturamento DECIMAL(12,2),
    meta_tempo_medio INT,
    meta_taxa_sucesso DECIMAL(5,2),
    data_cadastro DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_regiao) REFERENCES tb_regioes(id_regiao)
);

PRINT 'Tabelas criadas com sucesso!';






