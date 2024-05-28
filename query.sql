CREATE DATABASE ex9
GO
USE ex9
GO
CREATE TABLE editora (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
site			VARCHAR(40)		NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE autor (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
biografia		VARCHAR(100)	NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE estoque (
codigo			INT				NOT NULL,
nome			VARCHAR(100)	NOT NULL	UNIQUE,
quantidade		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL	CHECK(valor > 0.00),
codEditora		INT				NOT NULL,
codAutor		INT				NOT NULL
PRIMARY KEY (codigo)
FOREIGN KEY (codEditora) REFERENCES editora (codigo),
FOREIGN KEY (codAutor) REFERENCES autor (codigo)
)
GO
CREATE TABLE compra (
codigo			INT				NOT NULL,
codEstoque		INT				NOT NULL,
qtdComprada		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL,
dataCompra		DATE			NOT NULL
PRIMARY KEY (codigo, codEstoque, dataCompra)
FOREIGN KEY (codEstoque) REFERENCES estoque (codigo)
)
GO
INSERT INTO editora VALUES
(1,'Pearson','www.pearson.com.br'),
(2,'Civilização Brasileira',NULL),
(3,'Makron Books','www.mbooks.com.br'),
(4,'LTC','www.ltceditora.com.br'),
(5,'Atual','www.atualeditora.com.br'),
(6,'Moderna','www.moderna.com.br')
GO
INSERT INTO autor VALUES
(101,'Andrew Tannenbaun','Desenvolvedor do Minix'),
(102,'Fernando Henrique Cardoso','Ex-Presidente do Brasil'),
(103,'Diva Marilia Flemming','Professora adjunta da UFSC'),
(104,'David Halliday','Ph.D. da University of Pittsburgh'),
(105,'Alfredo Steinbruch','Professor de Matematica da UFRS e da PUCRS'),
(106,'Willian Roberto Cereja','Doutorado em Linguistica Aplicada e Estudos da Linguagem'),
(107,'William Stallings','Doutorado em Ciencias da Computacão pelo MIT'),
(108,'Carlos Morimoto','Criador do Kurumin Linux')
GO
INSERT INTO estoque VALUES
(10001,'Sistemas Operacionais Modernos ',4,108.00,1,101),
(10002,'A Arte da Política',2,55.00,2,102),
(10003,'Calculo A',12,79.00,3,103),
(10004,'Fundamentos de Fisica I',26,68.00,4,104),
(10005,'Geometria Analitica',1,95.00,3,105),
(10006,'Gramática Reflexiva',10,49.00,5,106),
(10007,'Fundamentos de Fisica III',1,78.00,4,104),
(10008,'Calculo B',3,95.00,3,103)
GO
INSERT INTO compra VALUES
(15051,10003,2,158.00,'04/07/2021'),
(15051,10008,1,95.00,'04/07/2021'),
(15051,10004,1,68.00,'04/07/2021'),
(15051,10007,1,78.00,'04/07/2021'),
(15052,10006,1,49.00,'05/07/2021'),
(15052,10002,3,165.00,'05/07/2021'),
(15053,10001,1,108.00,'05/07/2021'),
(15054,10003,1,79.00,'06/08/2021'),
(15054,10008,1,95.00,'06/08/2021')


--1) Consultar nome, valor unitário, nome da editora e nome do autor dos livros do estoque que foram vendidos. Não podem haver repetições.
SELECT DISTINCT e.nome AS Nome_Livro,
                e.valor AS Valor_Unitario,
                ed.nome AS Nome_Editora,
                a.nome AS Nome_Autor
FROM compra AS c
JOIN estoque AS e ON c.codEstoque = e.codigo
JOIN editora AS ed ON e.codEditora = ed.codigo
JOIN autor AS a ON e.codAutor = a.codigo;

--2) Consultar nome do livro, quantidade comprada e valor de compra da compra 15051
SELECT  e.nome AS Nome,
		c.qtdComprada AS Quantidade_Comprada,
		c.valor AS Valor_Da_Compra
FROM compra AS c
JOIN estoque AS e ON c.codEstoque = e.codigo
WHERE c.codigo = 15051

--3) Consultar Nome do livro e site da editora dos livros da Makron books (Caso o site tenha mais de 10 dígitos, remover o www.).
SELECT  e.nome AS Nome_Do_Livro,
		SUBSTRING(edi.site,5,10) AS Nome_Do_Site
FROM estoque AS e
JOIN editora AS edi ON e.codEditora = edi.codigo
WHERE edi.nome='Makron books' 

--4) Consultar nome do livro e Breve Biografia do David Halliday
SELECT  es.nome AS Nome,
		a.nome AS Autor,
		a.biografia AS Biografia
FROM estoque AS es
JOIN autor AS a ON a.codigo = es.codAutor
WHERE a.nome='David Halliday';

--5) Consultar código de compra e quantidade comprada do livro Sistemas Operacionais Modernos
SELECT  c.codigo AS Codigo_Da_Compra,
	    c.qtdComprada AS Quantidade_Comprada
FROM compra AS c
JOIN estoque AS es ON es.codigo=c.codEstoque
WHERE es.nome='Sistemas Operacionais Modernos';

--6) Consultar quais livros não foram vendidos
SELECT es.nome AS Nome_Livro,
       ed.nome AS Nome_Editora,
       a.nome AS Nome_Autor
FROM estoque AS es
JOIN editora AS ed ON es.codEditora = ed.codigo
JOIN autor AS a ON es.codAutor = a.codigo
LEFT JOIN compra AS c ON es.codigo = c.codEstoque
WHERE c.codigo IS NULL;

--7) Consultar quais livros foram vendidos e não estão cadastrados. Caso o nome dos livros terminem com espaço, fazer o trim apropriado.
SELECT RTRIM(e.nome) AS Nome_Do_Livro
FROM estoque AS e
LEFT JOIN compra AS c ON e.codigo=c.codEstoque
WHERE e.codigo IS NULL;

--8) Consultar Nome e site da editora que não tem Livros no estoque (Caso o site tenha mais de 10 dígitos, remover o www.)
SELECT  edi.nome AS Nome_Da_Editora,
		SUBSTRING(edi.site, 5, 30) AS Nome_Do_Site
FROM editora AS edi
LEFT JOIN estoque AS es ON es.codEditora=edi.codigo
WHERE es.codEditora IS NULL;

--9) Consultar Nome e biografia do autor que não tem Livros no estoque (Caso a biografia inicie com Doutorado, substituir por Ph.D.)
SELECT nome AS Nome_Autor,
       CASE 
           WHEN LEFT(biografia, 9) = 'Doutorado' THEN REPLACE(biografia, 'Doutorado', 'Ph.D')
           ELSE biografia
       END AS Biografia
FROM autor
WHERE codigo NOT IN (SELECT DISTINCT codAutor FROM estoque);

--10) Consultar o nome do Autor, e o maior valor de Livro no estoque. Ordenar por valor descendente
SELECT DISTINCT a.nome AS Nome_Autor,
		es.valor
FROM autor AS a
LEFT JOIN estoque AS es ON es.codAutor=a.codigo
ORDER BY es.valor DESC

--11) Consultar o código da compra, o total de livros comprados e a soma dos valores gastos. Ordenar por Código da Compra ascendente.
SELECT c.codigo AS Codigo_Compra,
				SUM(c.qtdComprada) AS Total_Livros_Comprados,
				SUM(c.valor) AS Soma_Valores
FROM compra AS c
GROUP BY c.codigo
ORDER BY c.codigo ASC;

--12) Consultar o nome da editora e a média de preços dos livros em estoque.Ordenar pela Média de Valores ascendente.
SELECT  edi.nome AS Nome_Da_Editora,
		AVG(es.valor) AS Media_Valor
FROM editora AS edi
LEFT JOIN estoque AS es ON es.codEditora=edi.codigo
GROUP BY edi.nome
ORDER BY AVG(es.valor) ASC;

--13) Consultar o nome do Livro, a quantidade em estoque o nome da editora, o site da editora (Caso o site tenha mais de 10 dígitos, remover o www.), criar uma coluna status onde:	
--	Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
--	Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
--	Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
--	A Ordenação deve ser por Quantidade ascendente
SELECT  es.nome AS Nome_Do_Livro,
		es.quantidade AS Quantidade_Em_Estoque,
		edi.nome AS Nome_Editora,
		CASE 
			WHEN es.quantidade < 5 THEN 'Produto em Ponto de Pedido'
			WHEN es.quantidade >= 5 AND es.quantidade <= 10 THEN 'Produto Acabando'
			ELSE 'Estoque Suficiente'
		END AS Status,
		CASE 
			WHEN LEN(edi.site) > 10 THEN REPLACE(edi.site, 'www.', '')
			ELSE edi.site
		END AS Site
FROM estoque AS es
LEFT JOIN editora AS edi ON es.codEditora = edi.codigo
ORDER BY es.quantidade ASC;

--14) Para montar um relatório, é necessário montar uma consulta com a seguinte saída: Código do Livro, Nome do Livro, Nome do Autor, Info Editora (Nome da Editora + Site) de todos os livros	
--	Só pode concatenar sites que não são nulos
SELECT  es.codigo AS Codigo_Livro,
		es.nome AS Nome_Do_Livro,
		a.nome AS Nome_Do_Autor,
		CONCAT(edi.nome, ' ', edi.site) AS Info_Editora
FROM estoque AS es
LEFT JOIN autor AS a ON a.codigo=es.codAutor
LEFT JOIN editora AS edi ON edi.codigo=es.codEditora

--15) Consultar Codigo da compra, quantos dias da compra até hoje e quantos meses da compra até hoje
SELECT  c.codigo AS Codigo_Compra,
		DATEDIFF(DAY, c.dataCompra, GETDATE()) AS Dia,
		DATEDIFF(MONTH, c.dataCompra, GETDATE()) AS Mes
FROM compra AS c

--16) Consultar o código da compra e a soma dos valores gastos das compras que somam mais de 200.00	
SELECT  c.codigo AS Codigo,
		SUM(c.valor) AS Soma
FROM compra AS c
GROUP BY c.codigo
HAVING SUM(c.valor)>200;
