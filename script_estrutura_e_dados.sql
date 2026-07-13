-- DROP DATABASE ecommerce;
CREATE DATABASE ecommerce;
USE ecommerce;

-- ========================================================
-- 1. ENTIDADES BASE (DIMENSÕES INDEPENDENTES)
-- ========================================================

CREATE TABLE cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(150) NOT NULL,
    Endereco VARCHAR(255) NOT NULL,
    Tipo_cliente ENUM('PF','PJ') NOT NULL
);

CREATE TABLE produto (
    idProduto INT AUTO_INCREMENT PRIMARY KEY,
    Pname VARCHAR(100) NOT NULL,
    classification_kids BOOLEAN DEFAULT FALSE,
    Categoria ENUM('Eletrônico','Vestimenta','Brinquedos','Alimentos','Móveis') NOT NULL,
    Avaliacao FLOAT DEFAULT 0,
    Size ENUM ('Padrão','Pequeno','Médio','Grande'),
    Valor DECIMAL(10,2) NOT NULL
);

CREATE TABLE fornecedor (
    idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
    Razao_Social VARCHAR(150) NOT NULL,
    CNPJ CHAR(14) NOT NULL UNIQUE,
    Contato VARCHAR(11) NOT NULL
);

CREATE TABLE estoque (
    idEstoque INT AUTO_INCREMENT PRIMARY KEY,
    Local VARCHAR(45) NOT NULL
);

CREATE TABLE terceiro_vendedor (
    idTerceiro_Vendedor INT AUTO_INCREMENT PRIMARY KEY,
    Razao_Social VARCHAR(150) NOT NULL,
    Local VARCHAR(45) NOT NULL,
    CNPJ CHAR(14) UNIQUE,
    CPF CHAR(11) UNIQUE
);

-- ========================================================
-- 2. ESPECIALIZAÇÕES DE CLIENTE (HERANÇA 1:1)
-- ========================================================

CREATE TABLE cliente_pf (
    cliente_idCliente INT PRIMARY KEY,
    CPF CHAR(11) NOT NULL UNIQUE,
    CONSTRAINT fk_clientepf_cliente FOREIGN KEY (cliente_idCliente) 
        REFERENCES cliente(idCliente) ON DELETE CASCADE
);

CREATE TABLE cliente_pj (
    cliente_idCliente INT PRIMARY KEY,
    CNPJ CHAR(14) NOT NULL UNIQUE,
    CONSTRAINT fk_clientepj_cliente FOREIGN KEY (cliente_idCliente) 
        REFERENCES cliente(idCliente) ON DELETE CASCADE
);

-- ========================================================
-- 3. ENTIDADES DEPENDENTES
-- ========================================================

CREATE TABLE pedido (
    idPedido INT AUTO_INCREMENT PRIMARY KEY,
    Status ENUM('Cancelado','Confirmado','Em processamento') DEFAULT 'Em processamento',
    Descricao VARCHAR(255),
    Cliente_idCliente INT NOT NULL,
    Frete DECIMAL(10,2) NOT NULL DEFAULT 10.00,
    Data DATETIME NOT NULL,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (cliente_idCliente) 
        REFERENCES cliente(idCliente)
);

-- Desafio de criação da tabela de pagamentos:
CREATE TABLE pagamento (
    idPagamento INT AUTO_INCREMENT PRIMARY KEY,
    Pedido_idPedido INT NOT NULL,
    Metodo ENUM ('Pix', 'Boleto','Cartão'),
    Status ENUM('Pendente','Aprovado','Negado','Cancelado','Estornado') DEFAULT 'Pendente',
    Data DATETIME,
    Valor DECIMAL(10,2),
    CONSTRAINT fk_pagamentos_pedido FOREIGN KEY (Pedido_idPedido) 
        REFERENCES pedido(idPedido) ON DELETE CASCADE
);

-- ========================================================
-- 4. LOGÍSTICA E TABELAS ASSOCIATIVAS (N:M)
-- ========================================================

CREATE TABLE entrega (
    idEntrega INT AUTO_INCREMENT PRIMARY KEY,
    Pedido_idPedido INT NOT NULL,
    Status ENUM('Aguardando Envio', 'Em Trânsito', 'Saiu para Entrega', 'Entregue', 'Falha na Entrega', 'Devolvido') DEFAULT 'Aguardando Envio',
    Codigo_de_rastreio VARCHAR(45) NOT NULL,
    Data_envio DATETIME,
    CONSTRAINT fk_entrega_pedido FOREIGN KEY (Pedido_idPedido) 
        REFERENCES pedido(idPedido) ON DELETE CASCADE
);

CREATE TABLE relacao_de_produto_pedido (
    Pedido_idPedido INT,
    Produto_idProduto INT,
    Quantidade INT NOT NULL DEFAULT 1,
    Preco_unitario DECIMAL(10,2) NOT NULL, 
    PRIMARY KEY (Pedido_idPedido, Produto_idProduto),
    CONSTRAINT fk_relacao_pedido FOREIGN KEY (Pedido_idPedido) REFERENCES pedido(idPedido),
    CONSTRAINT fk_relacao_produto FOREIGN KEY (Produto_idProduto) REFERENCES produto(idProduto)
);

CREATE TABLE disponibilizando_um_produto (
    Fornecedor_idFornecedor INT,
    Produto_idProduto INT,
    PRIMARY KEY (Fornecedor_idFornecedor, Produto_idProduto),
    CONSTRAINT fk_disp_fornecedor FOREIGN KEY (Fornecedor_idFornecedor) REFERENCES fornecedor(idFornecedor),
    CONSTRAINT fk_disp_produto FOREIGN KEY (Produto_idProduto) REFERENCES produto(idProduto)
);

CREATE TABLE produto_has_estoque (
    Produto_idProduto INT,
    Estoque_idEstoque INT,
    Quantidade INT NOT NULL DEFAULT 0,
    PRIMARY KEY (Produto_idProduto, Estoque_idEstoque),
    CONSTRAINT fk_est_produto FOREIGN KEY (Produto_idProduto) REFERENCES produto(idProduto),
    CONSTRAINT fk_est_estoque FOREIGN KEY (Estoque_idEstoque) REFERENCES estoque(idEstoque)
);

CREATE TABLE produtos_por_vendedor_terceiro (
    Terceiro_Vendedor_idTerceiro_Vendedor INT,
    Produto_idProduto INT,
    Quantidade INT NOT NULL DEFAULT 0,
    PRIMARY KEY (Terceiro_Vendedor_idTerceiro_Vendedor, Produto_idProduto),
    CONSTRAINT fk_vend_terceiro FOREIGN KEY (Terceiro_Vendedor_idTerceiro_Vendedor) REFERENCES terceiro_vendedor(idTerceiro_Vendedor),
    CONSTRAINT fk_vend_produto FOREIGN KEY (Produto_idProduto) REFERENCES produto(idProduto)
);


-- ========================================================
-- ========================================================
-- 5. POPULAÇÃO DOS DADOS (DML)
-- ========================================================
-- ========================================================

-- Dimensões Puras
INSERT INTO cliente (idCliente, Nome, Endereco, Tipo_cliente) VALUES 
(1, 'Ana Silva', 'Rua das Flores, 123 - SP', 'PF'),
(2, 'Carlos Souza', 'Av. Paulista, 1500 - SP', 'PF'),
(3, 'Tech Solutions Ltda', 'Av. Nações Unidas, 4500 - SP', 'PJ'),
(4, 'Global Atacadista', 'Rua Industrial, 88 - MG', 'PJ');

INSERT INTO produto (idProduto, Pname, classification_kids, Categoria, Avaliacao, Size, Valor) VALUES
(1, 'Smartphone Crypto X', false, 'Eletrônico', 4.7, 'Padrão', 2500.00),
(2, 'Camiseta Algodão Premium', false, 'Vestimenta', 4.2,'Grande', 89.90),
(3, 'Blocos de Montar Espaciais', true, 'Brinquedos', 4.9, 'Médio', 199.00),
(4, 'Cadeira Ergonómica Pro', false, 'Móveis', 4.5, 'Grande', 1200.00);

INSERT INTO fornecedor (idFornecedor, Razao_Social, CNPJ, Contato) VALUES
(1, 'Fábrica de Eletrónicos Zeus', '11222333000111', '11999998888'),
(2, 'Textil Brasil S.A.', '22333444000122', '11988887777'),
(3, 'Global Atacadista', '33444555000133', '31977776666');

INSERT INTO estoque (idEstoque, Local) VALUES 
(1, 'Centro de Distribuição São Paulo'),
(2, 'Filial Logística Minas Gerais');

INSERT INTO terceiro_vendedor (idTerceiro_Vendedor, Razao_Social, Local, CNPJ, CPF) VALUES
(1, 'Loja do Nerd Gamer', 'Rio de Janeiro', NULL, '12345678900'),
(2, 'Global Atacadista', 'Minas Gerais', '33444555000133', NULL);

-- Especializações (1:1)
INSERT INTO cliente_pf (cliente_idCliente, CPF) VALUES 
(1, '11122233344'), 
(2, '55566677788'); 

INSERT INTO cliente_pj (cliente_idCliente, CNPJ) VALUES 
(3, '44555666000177'), 
(4, '33444555000133'); 

-- Pedidos
INSERT INTO pedido (idPedido, Status, Descricao, Cliente_idCliente, Frete, Data) VALUES
(1, 'Confirmado', 'Compra de fim de ano', 1, 15.00, '2026-05-10 14:30:00'),        
(2, 'Em processamento', 'Upgrade de escritório', 3, 50.00, '2026-06-01 09:15:00'),
(3, 'Confirmado', 'Presente de aniversário', 2, 10.00, '2026-06-15 18:20:00'),   
(4, 'Cancelado', 'Pedido duplicado', 1, 0.00, '2026-06-16 11:00:00');             

-- Financeiro
INSERT INTO pagamento (Pedido_idPedido, Metodo, Status, Data, Valor) VALUES
(1, 'Pix', 'Aprovado', '2026-05-10 14:32:00', 515.00),
(1, 'Cartão', 'Aprovado', '2026-05-10 14:35:00', 2000.00),
(2, 'Boleto', 'Pendente', '2026-06-01 09:20:00', 1250.00),
(3, 'Cartão', 'Aprovado', '2026-06-15 18:22:00', 209.00);

-- Logística
INSERT INTO entrega (Pedido_idPedido, Status, Codigo_de_rastreio, Data_envio) VALUES
(1, 'Entregue', 'BR123456789X', '2025-05-11 10:00:00'),
(2, 'Aguardando Envio', 'BR0000000000', NULL),
(3, 'Em Trânsito', 'BR987654321Y', '2026-06-16 08:00:00');

-- Relacionamentos N:M
INSERT INTO relacao_de_produto_pedido (Pedido_idPedido, Produto_idProduto, Quantidade, Preco_unitario) VALUES
(1, 1, 1, 2500.00),
(2, 4, 1, 1200.00),
(3, 2, 1, 79.90), 
(3, 3, 1, 119.10);

INSERT INTO disponibilizando_um_produto (Fornecedor_idFornecedor, Produto_idProduto) VALUES
(1, 1), 
(2, 2), 
(3, 3);

INSERT INTO produto_has_estoque (Produto_idProduto, Estoque_idEstoque, Quantidade) VALUES
(1, 1, 50),  
(2, 1, 200), 
(3, 2, 100), 
(4, 2, 15);  

INSERT INTO produtos_por_vendedor_terceiro (Terceiro_Vendedor_idTerceiro_Vendedor, Produto_idProduto, Quantidade) VALUES
(1, 1, 5),   
(2, 3, 40);