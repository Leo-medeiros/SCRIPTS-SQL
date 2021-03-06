/*  PARA CRIPTOGRAFAR, CRIAR, UMA CHAVE MESTRA, UM CERTIFICADO E UMA CHAVE SIMETRICA, EXECUTAR UM POR UM*/

--CHAVE MESTRA
CREATE MASTER KEY ENCRYPTION
BY PASSWORD = 'K31_ssms_M4$t3R' 

-- CERTIFICADO
CREATE CERTIFICATE SQL_SECURITY
ENCRYPTION BY PASSWORD = 'pAA$$WOr6'
WITH SUBJECT = 'Meu Certificado'
GO

-- CHAVE SIMETRICA
CREATE SYMMETRIC KEY MyKey_security
WITH ALGORITHM = AES_192
ENCRYPTION BY CERTIFICATE SQL_SECURITY

---------------------------------------------------------
-- Criando o banco
CREATE DATABASE Acesso
GO
-- CRIA TABELA PARA CADASTRAR OS CLIENTES
CREATE TABLE [dbo].[CLIENTES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CLIENTE] [varchar](60) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- CRIA TABELA PARA CADASTRAR OS USUARIOS, COM DOMINIO DO SERVIDOR, USURARIO E A SENHA
CREATE TABLE [dbo].[usuarios](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dominio_servidor] [varchar](20) NULL,
	[usuario] [varchar](30) NULL,
	[senha] [varbinary](max) NULL,
	[id_cliente] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[usuarios]  WITH CHECK ADD  CONSTRAINT [fk_idCli] FOREIGN KEY([id_cliente])
REFERENCES [dbo].[CLIENTES] ([ID])
ON UPDATE CASCADE
GO

ALTER TABLE [dbo].[usuarios] CHECK CONSTRAINT [fk_idCli]
GO


-- SCRIPT PARA FAZER O INSERT NA TABELA USUARIOS
OPEN SYMMETRIC KEY MyKey_security 
DECRYPTION BY CERTIFICATE SQL_SECURITY WITH PASSWORD = 'pAA$$WOr6'

 DECLARE @GUID UNIQUEIDENTIFIER = (SELECT KEY_GUID('MyKey_security'))

 INSERT INTO usuarios VALUES ('gol_sbc\','tivit.amkurosaki',ENCRYPTBYKEY(@GUID,'Tivit@pts'),/* COLOCAR AQUI O ID DO CLIENTE*/14)
 GO



CLOSE SYMMETRIC KEY MyKey_security


-- SCRIPT PARA CRIA��O DA SP_LOGIN
 CREATE PROCEDURE [dbo].[SP_LOGIN] 
 @CLIENTE VARCHAR(60)
 AS

 BEGIN
  IF NOT EXISTS (SELECT CLIENTE FROM CLIENTES WHERE CLIENTE LIKE '%'+@CLIENTE+'%')
  
    PRINT 'Cliente n�o encontrado, ou sem usu�rio'
   
   ELSE

 OPEN SYMMETRIC KEY MyKey_security
 DECRYPTION BY CERTIFICATE SQL_SECURITY WITH PASSWORD = 'pAA$$WOr6'


SELECT concat(a.dominio_servidor, a.usuario) [login],
       senhadescriptografada = CAST (DECRYPTBYKEY(A.senha) AS varchar(50)), B.CLIENTE FROM USUARIOS A
INNER JOIN CLIENTES B ON A.ID_CLIENTE = B.ID
WHERE B.CLIENTE LIKE ('%'+@CLIENTE+'%')

CLOSE SYMMETRIC KEY MyKey_security
END
GO