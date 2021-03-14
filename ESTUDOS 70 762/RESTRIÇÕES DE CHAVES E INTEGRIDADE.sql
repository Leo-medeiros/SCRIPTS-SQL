/*
ESTUDO DE RESTRIÇÕES DE CHAVES E INTEGRIDADE

CONSTRAINT DEFAULT

*/

CREATE DATABASE ESTUDOS
GO


USE ESTUDOS
GO

IF OBJECT_ID('Produto') IS NOT NULL 
 DROP TABLE Produto
 GO
 CREATE TABLE Produto (
 CODIGO INT PRIMARY KEY IDENTITY,
 NOME VARCHAR(50),
 QUANTIDADE INT NOT NULL,
 DT_VENCIMENTO DATETIME
 )


 ALTER TABLE Produto
 ADD CONSTRAINT DFLTPRODUTO_DT_VENCIMENTO
 DEFAULT '2040-12-30 15:00:00' FOR DT_VENCIMENTO


insert into Produto values ('PRODUTO 1', 40,'2021-12-01 15:00:00')
GO 300

insert into Produto values ('PRODUTO 2', 10, DEFAULT)
GO 700


SELECT * FROM Produto
WHERE NOME = 'PRODUTO 2'

------------------------------------------------------------------------

/*
CONSTRAINT UNIQUE 

basicamente, essa restrição é, temos uma tabela q um cmapo já é o PK, mas que outro campo tmb precisaria ou poderia ser
uma PK, então, criamos um index unique neste campo, para deixar ele exclusivo.


*/
-- iremos criar uma tabela de venda q tenha o CODIGO do produto da tabela produtos e um campo NF (NOTA FISCAL) que será um campo com unique, pois nao podera ser duplicado

IF OBJECT_ID('Vendas') IS NOT NULL 
 DROP TABLE Vendas
 GO
 CREATE TABLE Vendas (
 ID INT PRIMARY KEY IDENTITY,
 CODPROD INT,
 DT_VENDA DATETIME,
 NF VARCHAR(11)
 
 )

 ALTER TABLE Vendas ADD CONSTRAINT FK_VENDAS_CODPROD FOREIGN KEY (CODPROD)
 REFERENCES Produto (CODIGO)

 ALTER TABLE Vendas ADD CONSTRAINT UQVendas_NF UNIQUE (NF)


 -- inserir um valor

 insert into Vendas values (20,'2020-03-20 14:00:00','15005576843')

 select * from Vendas

 /*
ID CODPROD	DT_VENDA					NF
1	20	   2020-03-20 14:00:00.000	15005576843


O insert foi efetuado, para evitarn que o campo nf fique com valores duplicados, a constraint ira gerar erro ao tentar inserir dados diferentes porém com o NF igual*/

 insert into Vendas values (02,'2020-05-02 08:00:00','15005576843')

 /*

 ERRO
 Msg 2627, Level 14, State 1, Line 83
Violation of UNIQUE KEY constraint 'UQVendas_NF'. Cannot insert duplicate key in object 'dbo.Vendas'. The duplicate key value is (15005576843).
*/

----------------------------------------------------------

/*

CONSTRAINT CHECK

limitar a entrada de dados

valida para insert e update

alguns exemplos de check que podemos utilizar 

LIMITANDO DADOS MAIS DO QUE UM TIPO DE DADOS


neste caso, vamos abordar o seguinte, imagine uma tabela de alunos de faculdade, onde, o numero maximo de alunos
que o curso de analise de sistemas pode ter por sala é de 80 alunos.

Neste caso, esse campo é um bom candidato para ter um check, pis, nao precisamos suar o valor int para essa coluna
pq int ocupa mais espaço, podemos usar um tinyint., onde o range é de 0 até 255, e limitar no check, que pode ter de 0 até 70 alunos
*/

 IF OBJECT_ID('Materias') IS NOT NULL 
 DROP TABLE Materias
 GO
 CREATE TABLE Materias (
 ID INT PRIMARY KEY IDENTITY,
 NOME VARCHAR(100)
 )

 INSERT INTO Materias VALUES ('Engenharia Quimica')
 ----
IF OBJECT_ID('Controle_Alunos') IS NOT NULL 
 DROP TABLE Controle_Alunos
 GO
 CREATE TABLE Controle_Alunos (
 ID_MATERIA INT PRIMARY KEY,
 ID_PROFESSOR INT DEFAULT 1,
 ALUNOS TINYINT,
 CONSTRAINT CHKControle_Alunos_ALUNOS 
 CHECK (ALUNOS>= 0 AND ALUNOS <71 ) )

 /*
 vamos para o teste*/

 INSERT INTO Controle_Alunos VALUES (1, DEFAULT,40)

GO

 INSERT INTO Controle_Alunos VALUES (2, DEFAULT,70)
 
 
 SELECT * FROM Controle_Alunos
 -- E SE EU DIGITAR UM VALOR acima de 70?
  INSERT INTO Controle_Alunos VALUES (3, DEFAULT,72)

  /*
  mesmo o campo ALUNOS com datatype TINYINT ACEITANDO ATÉ 255, com o check até 70, ao tentar fazer insert com valor > que 70
  gera esse erro:
  The INSERT statement conflicted with the CHECK constraint "CHKControle_Alunos_ALUNOS". The conflict occurred in database "ESTUDOS", table "dbo.Controle_Alunos", column 'ALUNOS'.
  */
  
  --E NO UPDATE FUNCIONA TAMBÉM?
  UPDATE Controle_Alunos SET ALUNOS = 71
  WHERE ID_MATERIA = 2


  /*
  outra forma de usar a constraitn CHECK
  APLICANDO UM FORMATO DE DADOS PARA UMA COLUNA
   PODEMOS DEFINIR NO TIPO DE DADO UM TAMANHO MAXIMO, OU DEFINIR OQ PODE SER VALIDADO NESTE CAMPO

   NO EXMPLO ABAIXO, CRIAMOS UMA TABERLA CHAMADA CARROS, E QUE TERA UM CAMPO PLACA
   NESSE CAMPO, QUERO GARANTIR, QUE SEJA INCLUIDO NA SEGUINTE ORDEM
   LETRA,LETRA,LETRA,NUMERO, NUMERO,NUMERO,NUMERO
   VAMOS RESTRINGIR ISSO NO CAMPO, PARA Q NAO HAJA ERROS NO MOMENTO DO INSERT OU UPDATE.
   */
   
   IF OBJECT_ID('Carros') IS NOT NULL 
 DROP TABLE Carros
 GO
 CREATE TABLE Carros 
 (
 COD INT PRIMARY KEY IDENTITY,
 MARCA VARCHAR(60),
 MODELO VARCHAR (60),
 ANO CHAR(4),
 PLACA CHAR(7)
 )


 ALTER TABLE Carros ADD CONSTRAINT CHKCarros_PLACA 
 CHECK (PLACA LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9]')

 
 INSERT INTO Carros VALUES ('FIAT','ARGO','2020','CLW8177')


 --caso caso um caracter a mais, gera erro no insert

  INSERT INTO Carros VALUES ('CHEVORLET','OPALA','1997','CLW81777')
 --caso caso um caracter a menos, gera erro no insert
   INSERT INTO Carros VALUES ('CHEVORLET','OPALA','1997','LW8177')

 select * from Carros
 

    INSERT INTO Carros VALUES ('CHEVORLET','ONIX','2018','BTF6170')

	/*
	OUTRA FORMA DE USAR O CHECK, ADICIONAR UMA COLUNA PARA O CLIENTE INFORMAR O QUE ACHOU DO VEICULO
	PORÉM, ESSE CAMPO, DEVE TER 10 CARACTERES OU MAIOR, EXEMPLO ABAIXO*/

	ALTER TABLE carros ADD  COMENTARIO VARCHAR(MAX)

	 ALTER TABLE Carros ADD CONSTRAINT CHKCarros_COMENTARIO
 CHECK (len(COMENTARIO) >= 10)


 -- COMENTARIO DENTRO DO RANGE
     INSERT INTO Carros VALUES ('FORD','FIEST','2012','DMQ4119','CARRO PERFEITO')

 -- COMENTARIO FORA DO RANGE
 INSERT INTO Carros VALUES ('AUDI','A3','2000','FFR1861','AAASA')

 /* ultima forma de se usar o CHECK
 COORDENE VÁRIOS VALORES JUNTOS

 Digamos que temos um caso que dois valores de colunas podem influenciar outro valor.

 Exemplo
VAMOS CRIAR A TABELA ALUNOS, E ELA TERA DOIS CAMPOS
 o campo FL_MATRICULA_HABILITADA E O CAMPO FL_MATRICULA_DESABILITADA, 
 vamos dizer que
 q se o aluno estiver habilitada o outro campo deve estar como desabilitado, e vice e versa

 vamos para o exemplo*/


 	   IF OBJECT_ID('Alunos') IS NOT NULL 
 DROP TABLE Alunos
 GO
 CREATE TABLE Alunos 
 (
 ID INT PRIMARY KEY IDENTITY,
 NOME VARCHAR(80),
 FL_MATRICULA_HABILITADA BIT NOT NULL,
 FL_MATRICULA_DESABILITADA BIT NOT NULL
 )

 ALTER TABLE ALUNOS ADD CONSTRAINT CHKALUNOS_FLAG
 CHECK (NOT (FL_MATRICULA_DESABILITADA = 1 AND FL_MATRICULA_HABILITADA= 1))

 -- VAMOS FAZER O INSERT, DO ALUNO JOAO QUE ESTA COM A MATRICULO OK

 INSERT INTO Alunos VALUES (
 'JOAO',
 1,
 0
 )

 SELECT * FROM Alunos

  -- VAMOS FAZER O INSERT, DA ALUNO MARIA QUE ESTA COM A MATRICULO DESATIVADA
   INSERT INTO Alunos VALUES (
 'Maria',
 0,
 1
 )

 -- agora o usuario errou na hora de cadastrar o proximo aluno, e deixo o habilitado e desabiltado = 1

    INSERT INTO Alunos VALUES (
 'Lucas',
 1,
 1
 )
 -- gera erro
     INSERT INTO Alunos VALUES (
 'Lucas',
 0,
 0
 )