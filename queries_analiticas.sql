-- ========================================================
-- EXECUÇÃO DAS QUERIES (DQL) - DESAFIO
-- ========================================================

-- Recuperações simples com SELECT Statement
-- Filtros com WHERE Statement
-- Crie expressões para gerar atributos derivados
-- Defina ordenações dos dados com ORDER BY
-- Condições de filtros aos grupos – HAVING Statement
-- Crie junções entre tabelas para fornecer uma perspectiva mais complexa dos dados

USE ecommerce;

SELECT * FROM pagamento;

SELECT Pedido_idPedido, Status, Metodo, Valor
	FROM pagamento
    WHERE Metodo = 'Cartão';

SELECT Pedido_idPedido, Status, Metodo, valor, ROUND(Valor*0.8, 2) AS '20% OFF'
	FROM pagamento;

SELECT * FROM relacao_de_produto_pedido
	ORDER BY Produto_idProduto DESC;
    
SELECT Pedido_idPedido `ID do Pedido`, Produto_idProduto `ID do Produto`, SUM(Quantidade) `Quantidade do Produto`, SUM(Quantidade * Preco_unitario) `Preço Total`
	FROM relacao_de_produto_pedido
	GROUP BY Pedido_idPedido, Produto_idProduto
		HAVING SUM(Quantidade * Preco_unitario) >= 1000;
        
SELECT 
    p.Pname AS Produto, 
    f.Razao_Social AS Fornecedor, 
    e.Local AS Local_do_Estoque
FROM produto p
INNER JOIN disponibilizando_um_produto DUP ON p.idProduto = DUP.Produto_idProduto
INNER JOIN fornecedor f ON DUP.Fornecedor_idFornecedor = f.idFornecedor
INNER JOIN produto_has_estoque PHE ON p.idProduto = PHE.Produto_idProduto
INNER JOIN estoque e ON PHE.Estoque_idEstoque = e.idEstoque;