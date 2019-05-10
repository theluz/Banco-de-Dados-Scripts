USE EMPRESA
GO

CREATE TABLE ALUNO(
	IDALUNO INT PRIMARY KEY IDENTITY(1,1),
	NOME VARCHAR(30) NOT NULL,
	SEXO CHAR(1) NOT NULL,
	NASCIMENTO DATE NOT NULL,
	EMAIL VARCHAR(30) UNIQUE
)
GO

/*CONSTRAINTS */
ALTER TABLE ALUNO
ADD CONSTRAINT CK_SEXO CHECK(SEXO IN('M','F'))
GO

/* 1 X 1*/

CREATE TABLE ENDERECO(
	IDENDERECO INT PRIMARY KEY IDENTITY(100,10),
	BAIRRO VARCHAR(30),
	UF CHAR(2) NOT NULL,
	CHECK(UF IN('RJ','SP','MG')),
	ID_ALUNO INT UNIQUE
)
GO

/*CRIANDO A FK*/
ALTER TABLE ENDERECO
ADD CONSTRAINT FK_ENDERECO_ALUNO
FOREIGN KEY(ID_ALUNO) REFERENCES ALUNO(IDALUNO)
GO

/*COMANDOS DE DESCRI��O*/
--PROCEDURES J� CRIADAS E ARMAZENADAS NO SISTEMA
--SP: STORAGE PROCEDURES
SP_COLUMNS ALUNO
GO

SP_HELP ALUNO
GO

/*INSERINDO DADOS */
INSERT INTO ALUNO VALUES('ANDRE','M','1981/12/09','ANDRE@IG.COM')
INSERT INTO ALUNO VALUES('ANA','F','1978/03/09','ANA@IG.COM')
INSERT INTO ALUNO VALUES('RUI','M','1951/07/09','RUI@IG.COM')
INSERT INTO ALUNO VALUES('JOAO','M','2002/11/09','JOAO@IG.COM')
GO

/*ENDERECO*/
INSERT INTO ENDERECO VALUES('FLAMENGO','RJ',1)
INSERT INTO ENDERECO VALUES('MORUMBI','SP',2)
INSERT INTO ENDERECO VALUES('CENTRO','MG',4)
INSERT INTO ENDERECO VALUES('CENTRO','SP',3)
GO

SELECT *FROM ENDERECO
GO

/*CRIANDO A TABELA TELEFONES*/
CREATE TABLE TELEFONE(
	IDTELEFONE INT PRIMARY KEY IDENTITY,
	TIPO CHAR(3) NOT NULL,
	NUMERO VARCHAR(10) NOT NULL,
	ID_ALUNO INT,
	CHECK(TIPO IN('RES','COM','CEL'))
)
GO

INSERT INTO TELEFONE VALUES('CEL','7899889',1)
INSERT INTO TELEFONE VALUES('RES','4325444',1)
INSERT INTO TELEFONE VALUES('COM','4354354',2)
INSERT INTO TELEFONE VALUES('CEL','2344556',2)
GO

SELECT * FROM ALUNO
GO


/*PEGAR DATA ATUAL*/
SELECT GETDATE()
GO

/*CLAUSULA AMBIGUA - JOIN COM COLUNAS IGUAIS*/
--USANDO ISNULL
SELECT  A.NOME, 
		ISNULL(T.TIPO,'SEM') AS "TIPO",
		ISNULL(T.NUMERO,'NUMERO') AS "TELEFONE", 
		E.BAIRRO, 
		E.UF
FROM ALUNO A
LEFT JOIN TELEFONE T   --LEFT JOIN PARA TRAZER QUE N�O TEM TELEFONE VINCULADO
ON A.IDALUNO = T.ID_ALUNO
INNER JOIN ENDERECO E
ON A.IDALUNO = E.ID_ALUNO
GO

/*DATAS NO SQL SERVER*/
SELECT * FROM ALUNO
GO

SELECT NOME, NASCIMENTO
FROM ALUNO
GO

/*DATEDIFF - CALCULA DIFEREN�A ENTRE 2 DATAS
GETDATE() TRAZ DIA E HORA
*/


SELECT NOME, GETDATE() AS "DIA_HORA" FROM ALUNO
GO

SELECT  NOME, 
		(DATEDIFF(DAY,NASCIMENTO,GETDATE())/365) AS "IDADE"
FROM ALUNO
GO

SELECT  NOME, 
		(DATEDIFF(MONTH,NASCIMENTO,GETDATE())/12) AS "IDADE"
FROM ALUNO
GO

SELECT  NOME, 
		DATEDIFF(YEAR,NASCIMENTO,GETDATE()) AS "IDADE"
FROM ALUNO
GO

/*DATENAME - TRAZ O NOME(STRING) DA PARTE DA DATA EM QUEST�O*/
SELECT NOME, DATENAME(MONTH,NASCIMENTO)
FROM ALUNO
GO

SELECT NOME, DATENAME(YEAR,NASCIMENTO)
FROM ALUNO
GO

SELECT NOME, DATENAME(WEEKDAY,NASCIMENTO)
FROM ALUNO
GO

/*DATEPART - RETORNA INTEIRO*/
SELECT NOME, DATEPART(MONTH,NASCIMENTO), DATENAME(MONTH,NASCIMENTO)
FROM ALUNO
GO

/*DATEADD - RETORNA DATA SOMANDO OUTRA*/
SELECT DATEADD(DAY,365,GETDATE())
SELECT DATEADD(YEAR,10,GETDATE())
GO

/*FUN��ES DE CONVERS�O DE DADOS*/
--STR TO NUM: AUTO

SELECT CAST('1' AS INT) + CAST('1' AS INT)
GO

--FORMATANDO DATA PARA BR
SELECT NOME,
		CAST(DAY(NASCIMENTO) AS VARCHAR) + '/' +
		CAST(MONTH(NASCIMENTO) AS VARCHAR) + '/' +
		CAST(YEAR(NASCIMENTO) AS VARCHAR) AS "NASCIMENTO"
FROM ALUNO
GO


/*CHARINDEX - RETORNA UM INTEIRO*/
-- 1� PARAMENTRO: O QUE, 2� ONDE, 3� A PARTIR DE (N�O OBRIGAT�RIO)
SELECT NOME, CHARINDEX('A',NOME) AS "INDICE"
FROM ALUNO
GO

SELECT NOME, CHARINDEX('A',NOME,2) AS "INDICE"
FROM ALUNO
GO

/*BULK INSERT - IMPORTACAO DE ARQUIVOS*/

CREATE TABLE LANCAMENTO_CONTABIL(
	CONTA INT,
	VALOR INT,
	DEB_CRED CHAR(1)
)
GO

SELECT * FROM LANCAMENTO_CONTABIL
GO

BULK INSERT LANCAMENTO_CONTABIL
FROM 'C:\Users\DBLuz\Desktop\Programas Local\CONTAS.TXT'
WITH
(
	FIRSTROW = 2,
	DATAFILETYPE = 'CHAR',
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
)
--OBS '\t' = tab - delimitador de campos do arquivo (poderia ser ;)
-- '\n' = enter

select * from LANCAMENTO_CONTABIL

/*EXERCICIO
QUERY QUE TRAGA O NUMERO DA CONTA
SALDO - DEVEDOR OU CREDOR*/

SELECT CONTA, VALOR, 
CHARINDEX('D',DEB_CRED) AS "DEBITO",
CHARINDEX('C',DEB_CRED) AS "CREDITO"
FROM LANCAMENTO_CONTABIL
GO
--MANEIRA DE FAZER FLAG EM UMA COLUNA (VERDADEIRO OU FALSO)


SELECT CONTA, VALOR, 
CHARINDEX('D',DEB_CRED) AS "DEBITO",
CHARINDEX('C',DEB_CRED) AS "CREDITO",
CHARINDEX('C',DEB_CRED)*2 - 1 AS "MULTIPLICADOR" 
FROM LANCAMENTO_CONTABIL
GO
/*
C=1  1*2 =2 -1 =1
D=0  0*2 =0 -1 =-1
*/

SELECT CONTA,
SUM(VALOR * (CHARINDEX('C',DEB_CRED)*2-1)) AS "SALDO"
FROM LANCAMENTO_CONTABIL
GROUP BY CONTA
GO
/*OBS:SUM VAI SOMAR TODOS OS VALORES DA COLUNA ENT�O � NECESS�RIO
USAR O GROUP BY NA COLUNA CONTA*/



/*TRIGGERS*/

CREATE TABLE PRODUTOS(
	IDPRODUTO INT IDENTITY PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL,
	CATEGORIA VARCHAR(30) NOT NULL,
	PRECO NUMERIC(10,2) NOT NULL
)
GO

CREATE TABLE HISTORICO(
	IDOPERACAO INT PRIMARY KEY IDENTITY,
	PRODUTO VARCHAR(50) NOT NULL,
	CATEGORIA VARCHAR(30) NOT NULL,
	PRECOANTIGO NUMERIC(10,2) NOT NULL,
	PRECONOVO NUMERIC(10,2) NOT NULL,
	DATA DATETIME,
	USUARIO VARCHAR(30),
	MENSAGEM VARCHAR(100)
)

INSERT INTO PRODUTOS VALUES('LIVRO SQL SERVER','LIVROS',98.00)
INSERT INTO PRODUTOS VALUES('LIVRO ORACLE','LIVROS',50.00)
INSERT INTO PRODUTOS VALUES('LICENCA POWER CENTER','SOFTWARES',45000.00)
INSERT INTO PRODUTOS VALUES('NOTEBOOK I7','COMPUTADORES',3150.00)
INSERT INTO PRODUTOS VALUES('LIVRO BUSINESS INTELIGENCE','LIVROS',90.00)

SELECT * FROM PRODUTOS
SELECT * FROM HISTORICO

/*VERIFICANDO USUARIO DO BANCO*/
SELECT SUSER_NAME()
GO

/*TRIGGER DE DADOS - DML - DATA MANIPULATION LANGUAGE*/
CREATE TRIGGER TRG_ATUALIZA_PRECO
ON DBO.PRODUTOS
FOR UPDATE --COMO � UPDATE TEM QUE CONSULTAR INSERTED E DELEATED
AS
	DECLARE @IDPRODUTO INT
	DECLARE @PRODUTO VARCHAR(30)
	DECLARE @CATEGORIA VARCHAR(10)
	DECLARE @PRECO NUMERIC(10,2)
	DECLARE @PRECONOVO NUMERIC(10,2)
	DECLARE @DATA DATETIME
	DECLARE @USUARIO VARCHAR(30)
	DECLARE @ACAO VARCHAR(100)

	--PRIMEIRO BLOCO -VALORES DE TABELA
	SELECT @IDPRODUTO = IDPRODUTO FROM inserted
	SELECT @PRODUTO = NOME FROM inserted
	SELECT @CATEGORIA = CATEGORIA FROM inserted
	SELECT @PRECO = PRECO FROM deleted --PRECO ANTIGO
	SELECT @PRECONOVO = PRECO FROM inserted --PRECO NOVO
	
	--SEGUNDO BLOCO - VALORES DE FUNCOES E/OU LITERAIS
	SET @DATA = GETDATE()
	SET @USUARIO = SUSER_NAME()
	SET @ACAO = 'VALOR INSERIDO PELA TRIGGER TRG_ATUALIZA_PRECO'

	INSERT INTO HISTORICO
	(PRODUTO,CATEGORIA,PRECOANTIGO,PRECONOVO, DATA,USUARIO,MENSAGEM) 
	VALUES
	(@PRODUTO,@CATEGORIA,@PRECO,@PRECONOVO,@DATA,@USUARIO,@ACAO)
	
	PRINT 'TRIGGER EXECUTADA COM SUCESSO'
GO

/*EXECUTANDO UM UPDATE PARA ATIVAR A TRIGGER*/

UPDATE DBO.PRODUTOS SET PRECO = 100.00
WHERE IDPRODUTO = 1
GO

SELECT * FROM PRODUTOS
SELECT * FROM HISTORICO

UPDATE PRODUTOS SET NOME = 'LIVRO C#'
WHERE IDPRODUTO = 1
GO

--TRIGGER ATIVOU NA TROCA DE NOME TAMB�M
--CRIANDO TRIGGER PARA MONITORAR COLUNA

DROP TRIGGER TRG_ATUALIZA_PRECO
GO

CREATE TRIGGER TRG_ATUALIZA_PRECO
ON DBO.PRODUTOS
FOR UPDATE AS 
IF UPDATE(PRECO)
BEGIN --T-SQL
	DECLARE @IDPRODUTO INT
	DECLARE @PRODUTO VARCHAR(30)
	DECLARE @CATEGORIA VARCHAR(10)
	DECLARE @PRECO NUMERIC(10,2)
	DECLARE @PRECONOVO NUMERIC(10,2)
	DECLARE @DATA DATETIME
	DECLARE @USUARIO VARCHAR(30)
	DECLARE @ACAO VARCHAR(100)

	--PRIMEIRO BLOCO -VALORES DE TABELA
	SELECT @IDPRODUTO = IDPRODUTO FROM inserted
	SELECT @PRODUTO = NOME FROM inserted
	SELECT @CATEGORIA = CATEGORIA FROM inserted
	SELECT @PRECO = PRECO FROM deleted --PRECO ANTIGO
	SELECT @PRECONOVO = PRECO FROM inserted --PRECO NOVO
	
	--SEGUNDO BLOCO - VALORES DE FUNCOES E/OU LITERAIS
	SET @DATA = GETDATE()
	SET @USUARIO = SUSER_NAME()
	SET @ACAO = 'VALOR INSERIDO PELA TRIGGER TRG_ATUALIZA_PRECO'

	INSERT INTO HISTORICO
	(PRODUTO,CATEGORIA,PRECOANTIGO,PRECONOVO, DATA,USUARIO,MENSAGEM) 
	VALUES
	(@PRODUTO,@CATEGORIA,@PRECO,@PRECONOVO,@DATA,@USUARIO,@ACAO)
	
	PRINT 'TRIGGER EXECUTADA COM SUCESSO'
END
GO

UPDATE PRODUTOS SET PRECO = 300.00
WHERE IDPRODUTO = 2
GO

SELECT * FROM PRODUTOS
SELECT * FROM HISTORICO

UPDATE PRODUTOS SET NOME = 'LIVRO JAVA'
WHERE IDPRODUTO = 2
GO



/*SIMPLIFICANDO TRIGGERS
-VARIAVEIS COM SELECT */

SELECT 10 + 10
GO

CREATE TABLE RESULTADO(
	IDRESULTADO INT PRIMARY KEY IDENTITY,
	RESULTADO INT
)
GO

INSERT INTO RESULTADO VALUES((SELECT 10 + 10))
GO

SELECT * FROM RESULTADO


--ATRIBUINDO SELECTS � VARIAVEIS - BLOCO AN�NIMO
DECLARE
	@RESULTADO INT
	SET @RESULTADO = (SELECT 50 + 50)
	INSERT INTO RESULTADO VALUES(@RESULTADO)
	PRINT 'VALOR INSERIDO NA TABELA: ' + CAST(@RESULTADO AS VARCHAR) 
GO


/*TRIGGER UPDATE */
CREATE TABLE EMPREGADO(
	IDEMPREGADO INT PRIMARY KEY IDENTITY,
	NOME VARCHAR(30),
	SALARIO MONEY, --VEM COM .00
	IDGERENTE INT
)

ALTER TABLE EMPREGADO
ADD CONSTRAINT FK_GERENTE
FOREIGN KEY (IDGERENTE) REFERENCES EMPREGADO(IDEMPREGADO)
GO

--S� PRA LEMBRAR COMO CONFERE SE A FK FOI CRIADA
SP_HELP EMPREGADO

INSERT INTO EMPREGADO VALUES('CLARA',5000.00,NULL)
INSERT INTO EMPREGADO VALUES('CELIA',4000.00,1)
INSERT INTO EMPREGADO VALUES('JOAO',4000.00,1)
GO

CREATE TABLE HIST_SALARIO(
	IDEMPREGADO INT,
	ANTIGOSAL MONEY,
	NOVOSAL MONEY,
	DATA DATETIME
)
GO

--INSERTS COM VALORES DE SELECT
CREATE TRIGGER TRG_SALARIO
ON DBO.EMPREGADO
FOR UPDATE AS
IF UPDATE(SALARIO)
BEGIN
	INSERT INTO HIST_SALARIO
	(IDEMPREGADO,ANTIGOSAL,NOVOSAL,DATA)
	SELECT D.IDEMPREGADO, D.SALARIO, I.SALARIO, GETDATE()
	FROM DELETED D, INSERTED I
	WHERE D.IDEMPREGADO = I.IDEMPREGADO 

END
GO

UPDATE EMPREGADO
SET SALARIO = SALARIO * 1.1
GO

SELECT * FROM EMPREGADO
SELECT * FROM HIST_SALARIO


/*TRAZER TAMB�M O NOME*/
CREATE TABLE SALARIO_RANGE(
	MINSAL MONEY,
	MAXSAL MONEY,
)
GO

INSERT INTO SALARIO_RANGE VALUES(2000.00,6000.00)
GO

SELECT * FROM SALARIO_RANGE
GO

CREATE TRIGGER TRG_RANGE
ON DBO.EMPREGADO
FOR INSERT, UPDATE
AS 
	DECLARE
		@MINSAL MONEY, 
		@MAXSAL MONEY,
		@ATUALSAL MONEY

	SELECT @MINSAL = MINSAL, @MAXSAL = MAXSAL FROM SALARIO_RANGE
	
	SELECT @ATUALSAL = I.SALARIO
	FROM INSERTED I

	IF(@ATUALSAL < @MINSAL)
	BEGIN
		RAISERROR('SAL�RIO MENOR QUE O PISO',16,1)
		ROLLBACK TRANSACTION
	END

	IF(@ATUALSAL > @MAXSAL)
	BEGIN
		RAISERROR('SALARIO MAIOR QUE O TETO',16,1)
		ROLLBACK TRANSACTION
	END
GO

/*TESTANDO MAXSAL*/
UPDATE EMPREGADO SET SALARIO = 9000.00
WHERE IDEMPREGADO = 1
GO

/*TESTANDO MINSAL*/
UPDATE EMPREGADO SET SALARIO = 1000.00
WHERE IDEMPREGADO = 1
GO

/*VER TEXTO DE UMA TRIGGER*/
SP_HELPTEXT TRG_RANGE



/* SP - STORAGE PROCEDURES*/
CREATE TABLE PESSOA(
	IDPESSOA INT PRIMARY KEY IDENTITY,
	NOME VARCHAR(30) NOT NULL,
	SEXO CHAR(1) NOT NULL CHECK (SEXO IN('M','F')),
	NASCIMENTO DATE NOT NULL
)
GO

CREATE TABLE TELEFONE2(
	IDTELEFONE INT NOT NULL IDENTITY,
	TIPO CHAR(3) NOT NULL CHECK(TIPO IN('CEL','COM')),
	NUMERO CHAR(10) NOT NULL,
	ID_PESSOA INT
)
GO

ALTER TABLE TELEFONE2 ADD CONSTRAINT FK_TELEFONE_PESSOA
FOREIGN KEY(ID_PESSOA) REFERENCES PESSOA(IDPESSOA)
ON DELETE CASCADE
GO

SELECT * FROM PESSOA
GO

INSERT INTO PESSOA VALUES('ANTONIO','M','1981-02-12')
INSERT INTO PESSOA VALUES('DANIEL','M','1985-03-18')
INSERT INTO PESSOA VALUES('CLEIDE','F','1979-10-13')

INSERT INTO TELEFONE2 VALUES('CEL','9879008',1)
INSERT INTO TELEFONE2 VALUES('COM','8757909',1)
INSERT INTO TELEFONE2 VALUES('CEL','9875890',2)
INSERT INTO TELEFONE2 VALUES('CEL','9347689',2)
INSERT INTO TELEFONE2 VALUES('COM','2998689',3)
INSERT INTO TELEFONE2 VALUES('COM','2098978',2)
INSERT INTO TELEFONE2 VALUES('CEL','9008679',3)
GO


/*CRIANDO A PROCEDURE EST�TICA*/
CREATE PROC SOMA
AS
	SELECT 10+10 AS SOMA
GO

/*EXECUTANDO A PROCEDURE EST�TICA*/
SOMA
--OU
EXEC SOMA
GO


/*PROCEDURE DIN�MICAS - COM PAR�METROS*/
CREATE PROC CONTA @NUM1 INT, @NUM2 INT
AS
	SELECT @NUM1 + @NUM2
GO

/*EXECUTANDO A PROCEDURE DIN�MICA*/
EXEC CONTA 2,2
GO

/*APAGANDO PROCEDURE*/
DROP PROC CONTA
GO

/*PROCEDURES EM TABELAS*/
SELECT NOME, NUMERO
FROM PESSOA
INNER JOIN TELEFONE2
ON IDPESSOA = ID_PESSOA
WHERE TIPO = 'CEL'
GO

/*RETORNAR TELEFONES DE ACORDO COM O TIPO PASSADO*/
CREATE PROC TELEFONES @TIPO CHAR(3)
AS
	SELECT NOME, NUMERO
	FROM PESSOA
	INNER JOIN TELEFONE2
	ON IDPESSOA = ID_PESSOA
	WHERE TIPO = @TIPO
GO

EXEC TELEFONES 'COM'
GO

/*PARAMETROS DE OUTPUT*/
SELECT TIPO, COUNT(*) AS QUANTIDADE
FROM TELEFONE 
GROUP BY TIPO
GO

/*CRIANDO PROCEDURES COM PAR�METRO DE ENTRADA E SAIDA*/
CREATE PROC GETTIPO @TIPO CHAR(3), @CONTADOR INT OUTPUT
AS
	SELECT @CONTADOR = COUNT(*)
	FROM TELEFONE2
	WHERE TIPO = @TIPO
GO

/*EXECU��O - T-SQL*/
DECLARE @SAIDA INT
EXEC GETTIPO @TIPO = 'CEL', @CONTADOR = @SAIDA OUTPUT
SELECT @SAIDA
GO

/*OMITINDO PAR�METROS*/
DECLARE @SAIDA INT
EXEC GETTIPO 'CEL', @SAIDA OUTPUT
SELECT @SAIDA
GO



/*PROCEDURE DE CADASTRO*/
SELECT @@IDENTITY --TRAZ O �LTIMO IDENTITY INSERIDO NA SE��O ATUAL
GO

CREATE PROC CADASTRO @NOME VARCHAR(30), @SEXO CHAR(1), @NASCIMENTO DATE,
@TIPO CHAR(3), @NUMERO VARCHAR(10)
AS
	DECLARE @FK INT
	
	INSERT INTO PESSOA VALUES(@NOME,@SEXO,@NASCIMENTO) --GERAR UM ID
	
	SET @FK = (SELECT IDPESSOA FROM PESSOA WHERE IDPESSOA = @@IDENTITY)

	INSERT INTO TELEFONE2 VALUES(@TIPO,@NUMERO, @FK)
GO

DROP PROC CADASTRO

EXEC CADASTRO 'JORGE','M','1981-01-01','CEL','97273822'
GO

/*DICA: TRAZER TUDO DE DUAS TABELAS*/
SELECT PESSOA.*,TELEFONE2.*
FROM PESSOA
INNER JOIN TELEFONE2
ON IDPESSOA = ID_PESSOA
GO



/*T-SQL � UM BLOCO DE LINGUAGEM DE PROGRAMA��O
PROGRAMAS S�O UNIDADES QUE PODEM SER CHAMADAS DE BLOCOS AN�NIMOS.
ESTES N�O RECEBEM NOME, POIS N�O S�O SALVOS NO BANCO.
CRIAMOS BLOCOS ANONIMOS QUANDO IREMOS EXECUTA-LOS UMA SO VEZ OU TESTAR ALGO.*/

/*BLOCO DE EXECU��O*/
BEGIN
	PRINT 'PRIMEIRO BLOCO'
END
GO

/*BLOCOS DE ATRIBUI��O DE VARIAVEIS*/
DECLARE
	@CONTADOR INT
BEGIN
	SET @CONTADOR = 5
	PRINT @CONTADOR
END
GO

/*NO SQL SERVER CADA COLUNA, VARIAVEL LOCAL, EXPRESS�O E PAR�METRO
TEM UM TIPO*/

DECLARE
	@V_NUMERO NUMERIC(10,2) = 100.52,
	@V_DATA DATETIME = '20170207'
BEGIN
	PRINT 'VALOR NUMERICO: ' + CAST(@V_NUMERO AS VARCHAR)
	PRINT 'VALOR NUMERICO: ' +CONVERT(VARCHAR, @V_NUMERO)
	PRINT 'VALOR DE DATA: ' + CAST(@V_DATA AS VARCHAR)
	PRINT 'VALOR DE DATA: ' + CONVERT(VARCHAR, @V_DATA, 121)
	PRINT 'VALOR DE DATA: ' + CONVERT(VARCHAR, @V_DATA, 120)
	PRINT 'VALOR DE DATA: ' + CONVERT(VARCHAR, @V_DATA, 105)--PT-BR
END
GO


/*T-SQL: ATRIBUINDO RESULTADOS DE QUERIES A VARI�VEIS*/
CREATE TABLE CARROS(
	CARRO VARCHAR(20),
	FABRICANTE VARCHAR(30)
)
GO

INSERT INTO CARROS VALUES('KA','FORD')
INSERT INTO CARROS VALUES('FIESTA','FORD')
INSERT INTO CARROS VALUES('PRISMA','FORD')
INSERT INTO CARROS VALUES('CLIO','RENAULT')
INSERT INTO CARROS VALUES('SANDERO','RENAULT')
INSERT INTO CARROS VALUES('CHEVETE','CHEVROLET')
INSERT INTO CARROS VALUES('OMEGA','CHEVROLET')
INSERT INTO CARROS VALUES('PALIO','FIAT')
INSERT INTO CARROS VALUES('DOBLO','FIAT')
INSERT INTO CARROS VALUES('UNO','FIAT')
INSERT INTO CARROS VALUES('GOL','VOLKSWAGEN')
GO


DECLARE
	@V_CONT_FORD INT,
	@V_CONT_FIAT INT
BEGIN
	--METODO 1 = O SELECT PRECISA RETORNAR UMA SIMPLES COLUNA
	--E UM S� RESULTADO
	SET @V_CONT_FORD = (SELECT COUNT(*) FROM CARROS
	WHERE FABRICANTE = 'FORD')
	
	PRINT 'QUANTIDADE FORD: ' + CAST(@V_CONT_FORD AS VARCHAR)

	--METODO 2 = VARI�VEL NO MEIO DA QUERY
	SELECT @V_CONT_FIAT = COUNT(*) FROM CARROS
	WHERE FABRICANTE = 'FIAT'

	PRINT 'QUANTIDADE FIAT: ' + CONVERT(VARCHAR, @V_CONT_FIAT)

END
GO


/*BLOCOS IF E ELSE
BLOCO NOMEADO - PROCEDURE*/
DECLARE
	@NUMERO INT = 5

BEGIN
	IF @NUMERO = 5
		PRINT 'O VALOR � VERDADEIRO'
	ELSE
		PRINT 'O VALOR � FALSO'
END
GO

/*CASE - CADA CASE RESPERESENTA UMA COLUNA*/
DECLARE
	@CONTADOR INT

BEGIN
	SELECT
	CASE
		WHEN FABRICANTE = 'FIAT' THEN 'FAIXA 1'
		WHEN FABRICANTE = 'CHEVROLET' THEN 'FAIXA 2'
		ELSE 'OUTRAS FAIXAS'
	END AS "INFORMACOES",
	*
	FROM CARROS
END
GO

BEGIN
	SELECT
	CASE
		WHEN FABRICANTE = 'FIAT' THEN 'FAIXA 1'
		WHEN FABRICANTE = 'CHEVROLET' THEN 'FAIXA 2'
		ELSE 'OUTRAS FAIXAS'
	END AS "INFORMACOES", --PODE ENCADEAR MAIS DE UM CASE PARA OUTRA COLUNA

	CASE 
		WHEN CARRO = 'CHEVETE' THEN 'CHEVETEIRO'
	END AS "CHEVETTO",
	*
	FROM CARROS
END
GO


/*EXERCICIO: ADAPTAR A PROCEDURE DO N�MERO PARA O TIPO DIN�MICO
(EXECUTAR PASSANDO UM PAR�METRO)*/

CREATE PROC NUM @NUM1 INT
AS
BEGIN
	IF @NUM1 = 5
		PRINT 'O VALOR � VERDADEIRO'
	ELSE
		PRINT 'O VALOR � FALSO'
END
GO

EXEC NUM 5
GO












