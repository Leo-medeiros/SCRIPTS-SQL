/*******************************************************************************************************************************
(C) 2016, Fabricio Lima Soluções em Banco de Dados

Site: http://www.fabriciolima.net/

Feedback: fabricioflima@gmail.com
*******************************************************************************************************************************/

/*******************************************************************************************************************************

--	Criação das tabelas que serão utilizadas para gerar o relatório do CheckList em HTML

--	INSTRUÇÕES DE USO: 

--	Apenas executar os scripts e conferir AS tabelas e procedures criadas na database desejada.

*******************************************************************************************************************************/

/*******************************************************************************************************************************
--	Database que será utilizada para armazenar os dados do CheckList. Se for necessário, altere o nome da mesma.
*******************************************************************************************************************************/
use Traces

GO
/*******************************************************************************************************************************
--	Criação das tabelas para armazenar os dados do CheckList
*******************************************************************************************************************************/
IF (OBJECT_ID('[dbo].[CheckList_Espaco_Disco]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Espaco_Disco]

CREATE TABLE [dbo].[CheckList_Espaco_Disco] (
	[DriveName]			VARCHAR(256) NULL,
	[TotalSize_GB]		BIGINT NULL,
	[FreeSpace_GB]		BIGINT NULL,
	[SpaceUsed_GB]		BIGINT NULL,
	[SpaceUsed_Percent] DECIMAL(9, 3) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Arquivos_MDF_LDF]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Arquivos_MDF_LDF]

CREATE TABLE [dbo].[CheckList_Arquivos_MDF_LDF] (
	[Server]			VARCHAR(50),
	[Nm_Database]		VARCHAR(100),
	[Logical_Name]		VARCHAR(100),
	[FileName]			VARCHAR(200),
	[Total_Reservado]	NUMERIC(15,2),
	[Total_Utilizado]	NUMERIC(15,2),
	[Espaco_Livre (MB)] NUMERIC(15,2), 
	[Espaco_Livre (%)]	NUMERIC(15,2), 
	[MaxSize]			INT,
	[Growth]			VARCHAR(25),
	[NextSize]			NUMERIC(15,2),
	[Fl_Situacao]		CHAR(1)
)

IF (OBJECT_ID('[dbo].[CheckList_Database_Growth]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Database_Growth]
	
CREATE TABLE [dbo].[CheckList_Database_Growth] (
	[Nm_Servidor]	VARCHAR(50) NULL,
	[Nm_Database]	VARCHAR(100) NULL,
	[Tamanho_Atual] NUMERIC(38, 2) NULL,
	[Cresc_1_dia]	NUMERIC(38, 2) NULL,
	[Cresc_15_dia]	NUMERIC(38, 2) NULL,
	[Cresc_30_dia]	NUMERIC(38, 2) NULL,
	[Cresc_60_dia]	NUMERIC(38, 2) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Database_Growth_Email]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Database_Growth_Email]
	
CREATE TABLE [dbo].[CheckList_Database_Growth_Email] (
	[Nm_Servidor]	VARCHAR(50) NULL,
	[Nm_Database]	VARCHAR(100) NULL,
	[Tamanho_Atual] NUMERIC(38, 2) NULL,
	[Cresc_1_dia]	NUMERIC(38, 2) NULL,
	[Cresc_15_dia]	NUMERIC(38, 2) NULL,
	[Cresc_30_dia]	NUMERIC(38, 2) NULL,
	[Cresc_60_dia]	NUMERIC(38, 2) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Table_Growth]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Table_Growth]
	
CREATE TABLE [dbo].[CheckList_Table_Growth] (
	[Nm_Servidor]	VARCHAR(50) NULL,
	[Nm_Database]	VARCHAR(100) NULL,
	[Nm_Tabela]		VARCHAR(100) NULL,
	[Tamanho_Atual] NUMERIC(38, 2) NULL,
	[Cresc_1_dia]	NUMERIC(38, 2) NULL,
	[Cresc_15_dia]	NUMERIC(38, 2) NULL,
	[Cresc_30_dia]	NUMERIC(38, 2) NULL,
	[Cresc_60_dia]	NUMERIC(38, 2) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Table_Growth_Email]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Table_Growth_Email]
	
CREATE TABLE [dbo].[CheckList_Table_Growth_Email] (
	[Nm_Servidor]	VARCHAR(50) NULL,
	[Nm_Database]	VARCHAR(100) NULL,
	[Nm_Tabela]		VARCHAR(100) NULL,
	[Tamanho_Atual] NUMERIC(38, 2) NULL,
	[Cresc_1_dia]	NUMERIC(38, 2) NULL,
	[Cresc_15_dia]	NUMERIC(38, 2) NULL,
	[Cresc_30_dia]	NUMERIC(38, 2) NULL,
	[Cresc_60_dia]	NUMERIC(38, 2) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Backups_Executados]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Backups_Executados]
	
CREATE TABLE [dbo].[CheckList_Backups_Executados] (
	[Database_Name]			VARCHAR(128) NULL,
	[Name]					VARCHAR(128) NULL,
	[Backup_Start_Date]		DATETIME NULL,
	[Tempo_Min]				INT NULL,
	[Position]				INT NULL,
	[Server_Name]			VARCHAR(128) NULL,
	[Recovery_Model]		VARCHAR(60) NULL,
	[Logical_Device_Name]	VARCHAR(128) NULL,
	[Device_Type]			TINYINT NULL,
	[Type]					CHAR(1) NULL,
	[Tamanho_MB]			NUMERIC(15, 2) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Jobs_Failed]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Jobs_Failed]
	
CREATE TABLE [dbo].[CheckList_Jobs_Failed] (
	[Server]		VARCHAR(50),
	[Job_Name]		VARCHAR(255),
	[Status]		VARCHAR(25),
	[Dt_Execucao]	VARCHAR(20),
	[Run_Duration]	VARCHAR(8),
	[SQL_Message]	VARCHAR(4490)
)

IF (OBJECT_ID('[dbo].[CheckList_Alteracao_Jobs]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Alteracao_Jobs]

CREATE TABLE [dbo].[CheckList_Alteracao_Jobs] (
	[Nm_Job]			VARCHAR(1000),
	[Fl_Habilitado]		TINYINT,
	[Dt_Criacao]		DATETIME,
	[Dt_Modificacao]	DATETIME,
	[Nr_Versao]			SMALLINT
)

IF (OBJECT_ID('[dbo].[CheckList_Job_Demorados]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Job_Demorados]

CREATE TABLE [dbo].[CheckList_Job_Demorados] (
	[Job_Name]		VARCHAR(255) NULL,
	[Status]		VARCHAR(19) NULL,
	[Dt_Execucao]	VARCHAR(30) NULL,
	[Run_Duration]	VARCHAR(8) NULL,
	[SQL_Message]	VARCHAR(3990) NULL
) 
	
IF (OBJECT_ID('[dbo].[CheckList_Traces_Queries]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Traces_Queries]
	
CREATE TABLE [dbo].[CheckList_Traces_Queries] (
	[PrefixoQuery]	VARCHAR(400),
	[QTD]			INT,
	[Total]			NUMERIC(15,2),
	[Media]			NUMERIC(15,2),
	[Menor]			NUMERIC(15,2),
	[Maior]			NUMERIC(15,2),
	[Writes]		INT,
	[CPU]			INT,
	[Ordem]			TINYINT
)

IF (OBJECT_ID('[dbo].[CheckList_Contadores]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Contadores]
	
CREATE TABLE [dbo].[CheckList_Contadores] (
	[Hora]			TINYINT,
	[Nm_Contador]	VARCHAR(60),
	[Media]			INT
)

IF (OBJECT_ID('[dbo].[CheckList_Fragmentacao_Indices]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Fragmentacao_Indices]
	
CREATE TABLE [dbo].[CheckList_Fragmentacao_Indices] (
	[Dt_Referencia]					DATETIME NULL,
	[Nm_Servidor]					VARCHAR(100) NULL,
	[Nm_Database]					VARCHAR(1000) NULL,
	[Nm_Tabela]						VARCHAR(1000) NULL,
	[Nm_Indice]						VARCHAR(1000) NULL,
	[Avg_Fragmentation_In_Percent]	NUMERIC(5, 2) NULL,
	[Page_Count]					INT NULL,
	[Fill_Factor]					TINYINT NULL,
	[Fl_Compressao]					TINYINT NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Waits_Stats]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Waits_Stats]
	
CREATE TABLE [dbo].[CheckList_Waits_Stats] (
	[WaitType]			VARCHAR(100),
	[Min_Log]			DATETIME,
	[Max_Log]			DATETIME,
	[DIf_Wait_S]		DECIMAL(14, 2),
	[DIf_Resource_S]	DECIMAL(14, 2),
	[DIf_Signal_S]		DECIMAL(14, 2),
	[DIf_WaitCount]		BIGINT,
	[DIf_Percentage]	DECIMAL(4, 2),
	[Last_Percentage]	DECIMAL(4, 2)
) 

IF (OBJECT_ID('[dbo].[CheckList_SQLServer_ErrorLog]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_SQLServer_ErrorLog]
	
CREATE TABLE [dbo].[CheckList_SQLServer_ErrorLog] (
	[Dt_Log]		DATETIME,
	[ProcessInfo]	VARCHAR(100),
	[Text]			VARCHAR(MAX)
)


GO
IF (OBJECT_ID('[dbo].[fncRetira_Caractere_Invalido_XML]') IS NOT NULL)
	DROP FUNCTION [dbo].[fncRetira_Caractere_Invalido_XML]
GO

/*
OBJETIVO: Procedure responsável por retirar os caracteres inválidos para o XML.

-- EXEMPLO EXECUÇÃO
SELECT dbo.fncRetira_Caractere_Invalido_XML('teste')
*/

CREATE FUNCTION [dbo].[fncRetira_Caractere_Invalido_XML] (
	@Text VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Result NVARCHAR(4000)

	SELECT @Result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
							(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
									(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
											(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
													(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( 
																													@Text
													 ,NCHAR(1),N'?'),NCHAR(2),N'?'),NCHAR(3),N'?'),NCHAR(4),N'?'),NCHAR(5),N'?'),NCHAR(6),N'?')
											 ,NCHAR(7),N'?'),NCHAR(8),N'?'),NCHAR(11),N'?'),NCHAR(12),N'?'),NCHAR(14),N'?'),NCHAR(15),N'?')
									 ,NCHAR(16),N'?'),NCHAR(17),N'?'),NCHAR(18),N'?'),NCHAR(19),N'?'),NCHAR(20),N'?'),NCHAR(21),N'?')
							 ,NCHAR(22),N'?'),NCHAR(23),N'?'),NCHAR(24),N'?'),NCHAR(25),N'?'),NCHAR(26),N'?'),NCHAR(27),N'?')
						 ,NCHAR(28),N'?'),NCHAR(29),N'?'),NCHAR(30),N'?'),NCHAR(31),N'?');

	RETURN @Result
END

GO

/*******************************************************************************************************************************
-- Criação das procedures para popular as tabelas criadas acima:
--	1) Espaço em Disco
--	2) Arquivos MDF e LDF
--	3) Crescimento Database
--	4) Crescimento Tabela
--	5) Backups Executados
--	6) JOBS que Falharam
--	7) JOBS Alterados
--	8) JOBS Demorados
--	9) Trace Queries Demoradas
--	10) Contadores
--	11) Fragmentação de Índices
--	12) Waits Stats
--	13) Error Log SQL
*******************************************************************************************************************************/

-- Libera permissões para pegar informações de acesso a disco com a proc sp_OACreate
EXEC sp_configure 'show advanced option',1

RECONFIGURE

EXEC sp_configure 'Ole Automation Procedures',1

RECONFIGURE
 
EXEC sp_configure 'show advanced option',0

RECONFIGURE

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Espaco_Disco]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Espaco_Disco]
GO

/*******************************************************************************************************************************
--	1) Espaço em Disco
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Espaco_Disco]
AS
BEGIN
	SET NOCOUNT ON 

	CREATE TABLE #dbspace (
		[Name]		SYSNAME,
		[Caminho]	VARCHAR(200),
		[Tamanho]	VARCHAR(10),
		[Drive]		VARCHAR(30)
	)

	CREATE TABLE [#espacodisco] (
		[Drive]				VARCHAR(10) ,
		[Tamanho (MB)]		INT,
		[Usado (MB)]		INT,
		[Livre (MB)]		INT,
		[Livre (%)]			INT,
		[Usado (%)]			INT,
		[Ocupado SQL (MB)]	INT, 
		[Data]				SMALLDATETIME
	)

	EXEC sp_MSforeachdb '	Use [?] 
							INSERT INTO #dbspace 
							SELECT	CONVERT(VARCHAR(25), DB_NAME())''Database'', CONVERT(VARCHAR(60), FileName),
									CONVERT(VARCHAR(8), Size/128) ''Size in MB'', CONVERT(VARCHAR(30), Name) 
							FROM [sysfiles]'

	DECLARE @hr INT, @fso INT, @size FLOAT, @TotalSpace INT, @MBFree INT, @Percentage INT, 
			@SQLDriveSize INT, @drive VARCHAR(1), @fso_Method VARCHAR(255), @mbtotal INT = 0	
	
	EXEC @hr = [master].[dbo].[sp_OACreate] 'Scripting.FilesystemObject', @fso OUTPUT

	IF (OBJECT_ID('tempdb..#space') IS NOT NULL) 
		DROP TABLE #space

	CREATE TABLE #space (
		[drive] CHAR(1), 
		[mbfree] INT
	)
	
	INSERT INTO #space EXEC [master].[dbo].[xp_fixeddrives]
	
	DECLARE CheckDrives Cursor For SELECT [drive], [mbfree] 
	FROM #space
	
	Open CheckDrives
	FETCH NEXT FROM CheckDrives INTO @drive, @MBFree
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		SET @fso_Method = 'Drives("' + @drive + ':").TotalSize'
		
		SELECT @SQLDriveSize = SUM(CONVERT(INT, Tamanho)) 
		FROM #dbspace 
		WHERE SUBSTRING(Caminho, 1, 1) = @drive
		
		EXEC @hr = sp_OAMethod @fso, @fso_Method, @size OUTPUT
		
		SET @mbtotal = @size / (1024 * 1024)
		
		INSERT INTO #espacodisco 
		VALUES(	@drive + ':', @mbtotal, @mbtotal-@MBFree, @MBFree, (100 * round(@MBFree, 2) / round(@mbtotal, 2)), 
				(100 - 100 * round(@MBFree,2) / round(@mbtotal, 2)), @SQLDriveSize, GETDATE())

		FETCH NEXT FROM CheckDrives INTO @drive, @MBFree
	END
	CLOSE CheckDrives
	DEALLOCATE CheckDrives

	TRUNCATE TABLE [dbo].[CheckList_Espaco_Disco]
	
	INSERT INTO [dbo].[CheckList_Espaco_Disco]( [DriveName], [TotalSize_GB], [FreeSpace_GB], [SpaceUsed_GB], [SpaceUsed_Percent] )
	SELECT [Drive], [Tamanho (MB)], [Livre (MB)], [Usado (MB)], [Usado (%)] 
	FROM #espacodisco

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Espaco_Disco]( [DriveName], [TotalSize_GB], [FreeSpace_GB], [SpaceUsed_GB], [SpaceUsed_Percent] )
		SELECT 'Sem registro de Espaço em Disco', NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Arquivos_MDF_LDF]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Arquivos_MDF_LDF]
GO

/*******************************************************************************************************************************
--	2) Arquivos MDF e LDF
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Arquivos_MDF_LDF]
AS
BEGIN
	SET NOCOUNT ON

	-- COLETA DE INFORMAÇÕES SOBRE ARQUIVOS MDF
	IF (OBJECT_ID('tempdb..##MDFs_Sizes') IS NOT NULL)
		DROP TABLE ##MDFs_Sizes

	CREATE TABLE ##MDFs_Sizes (
		[Server]			VARCHAR(50),
		[Nm_Database]		VARCHAR(100),
		[Total_Utilizado]	NUMERIC(15,2),
		[Espaco_Livre (MB)] NUMERIC(15,2), 
	)

	EXEC sp_MSforeachdb '
		Use [?]

			;WITH Cte
			AS(
				SELECT CAST(((SUM(size)*8.0)/1024.0) AS NUMERIC(15,2)) Total_Reservado
				, (CASE WHEN type = 0 
							THEN CAST((SELECT (SUM(ps.reserved_page_count)*8.0)/1024.0 
										FROM sys.dm_db_partition_stats ps WITH(NOLOCK)) AS NUMERIC(15,2))
					end) Total_Utilizado
				FROM sys.database_files WITH(NOLOCK)
				WHERE type = 0 --or type = 1
				GROUP BY type, name, physical_name, growth, is_percent_growth
			)
				INSERT INTO ##MDFs_Sizes
				SELECT @@servername
						, DB_NAME()
						, m.Total_Utilizado AS [Total_Utilizado (MB)]
						, (m.Total_Reservado - m.Total_Utilizado) AS [Espaco_Livre (MB)]
				FROM Cte m	
	'
	
	-- COLETA DE INFORMAÇÕES SOBRE ARQUIVOS LDF
	IF (OBJECT_ID('tempdb..#Logs_Sizes') IS NOT NULL)
		DROP TABLE #Logs_Sizes
	
	CREATE TABLE #Logs_Sizes (
		[Server]		VARCHAR(50),
		[Nm_Database]	VARCHAR(100) NOT NULL,
		[Log_Size(KB)]	BIGINT NOT NULL,
		[Log_Used(KB)]	BIGINT NOT NULL,
		[Log_Used(%)]	DECIMAL(22, 2) NULL
	) 

	INSERT INTO #Logs_Sizes( [Server], [Nm_Database], [Log_Size(KB)], [Log_Used(KB)], [Log_Used(%)] )
	SELECT @@SERVERNAME AS [Server],
			db.[name] AS [Database Name] ,
			ls.[cntr_value] AS [Log Size (KB)] ,
			lu.[cntr_value] AS [Log Used (KB)] ,
			CAST(CAST(lu.[cntr_value] AS FLOAT) /	CASE WHEN CAST(ls.[cntr_value] AS FLOAT) = 0  
															THEN 1  
															ELSE CAST(ls.[cntr_value] AS FLOAT) 
													END
			AS DECIMAL(18,2)) * 100 AS [Log Used %]
	FROM [sys].[databases] AS db WITH(NOLOCK)
		JOIN [sys].[dm_os_performance_counters] AS lu WITH(NOLOCK) ON db.[name] = lu.[instance_name]
		JOIN [sys].[dm_os_performance_counters] AS ls WITH(NOLOCK) ON db.[name] = ls.[instance_name]
	WHERE lu.[counter_name] LIKE 'Log File(s) Used Size (KB)%' AND ls.[counter_name] LIKE 'Log File(s) Size (KB)%' 
		
	-- ARMAZENA OS DADOS	
	TRUNCATE TABLE [dbo].[CheckList_Arquivos_MDF_LDF]
	
	INSERT INTO [dbo].[CheckList_Arquivos_MDF_LDF] (	[Server], [Nm_Database], [Logical_Name], [FileName], [Total_Reservado], [Total_Utilizado], 
														[Espaco_Livre (MB)], [Espaco_Livre (%)], [MaxSize], [Growth], [NextSize], [Fl_Situacao] )
	SELECT	@@SERVERNAME AS [Server]
			, DB_NAME(A.database_id) AS [Nm_Database]
			, [name] AS [Logical_Name]
			, A.[physical_name] AS [Filename]
			, CASE WHEN A.[name] = 'tempdev' THEN ([Espaco_Livre (MB)] + [Total_Utilizado]) ELSE ([Size] / 1024.0) * 8 END AS [Size(MB)]
			, CASE WHEN RIGHT(A.[physical_name],3) = 'mdf' THEN B.[Total_Utilizado] ELSE (C.[Log_Used(KB)]) / 1024.0 END AS [Used(MB)]
			, CASE WHEN RIGHT(A.[physical_name],3) = 'mdf' 
						THEN [Espaco_Livre (MB)]
						ELSE ([Log_Size(KB)] - [Log_Used(KB)]) / 1024.0
				END AS [Free_Space(MB)]
			, CASE	WHEN A.[name] = 'tempdev'
						THEN ([Espaco_Livre (MB)] / ([Espaco_Livre (MB)] + [Total_Utilizado])) * 100.00
					WHEN RIGHT(A.[physical_name],3) = 'mdf' 
						THEN (([Espaco_Livre (MB)] / (([Size] / 1024.0) * 8.0))) * 100.0
						ELSE (100.00 - C.[Log_Used(%)])
				END AS [Free_Space(%)]
			, CASE WHEN A.[Max_Size] = -1 THEN -1 ELSE (A.[Max_Size] / 1024) * 8 END AS [MaxSize(MB)]
			, CASE WHEN [is_percent_growth] = 1 
						THEN CAST(A.[Growth] AS VARCHAR) + ' %'
						ELSE CAST(CAST((A.[Growth] * 8 ) / 1024.00 AS NUMERIC(15, 2)) AS VARCHAR) + ' MB'
					END AS [Growth]
			, CASE WHEN [is_percent_growth] = 1
						THEN (([Size] / 1024) * 8) * ((A.[Growth] / 100.00) + 1)
						ELSE (([Size] / 1024) * 8) + CAST((A.[Growth] * 8 ) / 1024.00 AS NUMERIC(15,2)) 
					END AS [Proximo_Tamanho]
			, CASE WHEN A.[Max_Size] = -1 THEN '1'  -- OK
						WHEN( CASE WHEN [is_percent_growth] = 1
										THEN (([Size] / 1024) * 8) * ((A.[Growth] / 100.00) + 1)
										ELSE (([Size] / 1024) * 8) + CAST((A.[Growth] * 8 ) / 1024.00 AS NUMERIC(15, 2)) 
									END )  <  (A.[Max_Size] / 1024 * 8 ) *.95 THEN '1' ELSE '0'
					END AS [Fl_Situacao]
	FROM [sys].[master_files] A WITH(NOLOCK)	
		JOIN ##MDFs_Sizes B ON DB_NAME(A.[database_id]) = B.[Nm_Database]
		JOIN #Logs_Sizes C ON C.[Nm_Database] = DB_NAME(A.[database_id])
	WHERE A.[type_desc] <> 'FULLTEXT'
	
	IF ( @@ROWCOUNT = 0 )
	BEGIN
		INSERT INTO [dbo].[CheckList_Arquivos_MDF_LDF] (	[Server], [Nm_Database], [Logical_Name], [FileName], [Total_Reservado], [Total_Utilizado], 
															[Espaco_Livre (MB)], [Espaco_Livre (%)], [MaxSize], [Growth], [NextSize], [Fl_Situacao] )
		SELECT	NULL, 'Sem registro dos arquivos MDF e LDF', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Database_Growth]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Database_Growth]
GO

/*******************************************************************************************************************************
--	3) Crescimento Database
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Database_Growth]
AS
BEGIN
	SET NOCOUNT ON

	-- Declara e seta AS variaveis das datas - Tratamento para os casos que ainda não atingiram 60 dias no histórico
	DECLARE @Dt_Hoje DATE, @Dt_1Dia DATE, @Dt_15Dias DATE, @Dt_30Dias DATE, @Dt_60Dias DATE
	
	SELECT	@Dt_Hoje = CAST(GETDATE() AS DATE)
	
	SELECT	@Dt_1Dia =	 MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Referencia], @Dt_Hoje) <= 1  THEN A.[Dt_Referencia] END)),
			@Dt_15Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Referencia], @Dt_Hoje) <= 15 THEN A.[Dt_Referencia] END)),
			@Dt_30Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Referencia], @Dt_Hoje) <= 30 THEN A.[Dt_Referencia] END)),
			@Dt_60Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Referencia], @Dt_Hoje) <= 60 THEN A.[Dt_Referencia] END))
	FROM [dbo].[Historico_Tamanho_Tabela] A
		JOIN [dbo].[Servidor] B ON A.[Id_Servidor] = B.[Id_Servidor] 
		JOIN [dbo].[Tabela] C ON A.[Id_Tabela] = C.[Id_Tabela]
		JOIN [dbo].[BaseDados] D ON A.[Id_BaseDados] = D.[Id_BaseDados]
	WHERE DATEDIFF(DAY,A.[Dt_Referencia], CAST(GETDATE() AS DATE)) <= 60
	
	/*
	-- P/ TESTE
	SELECT @Dt_Hoje Dt_Hoje, @Dt_1Dia Dt_1Dia, @Dt_15Dias Dt_15Dias, @Dt_30Dias Dt_30Dias, @Dt_60Dias Dt_60Dias
	
	SELECT	CONVERT(VARCHAR, GETDATE() ,112) Hoje, CONVERT(VARCHAR, GETDATE()-1 ,112) [1Dia], CONVERT(VARCHAR, GETDATE()-15 ,112) [15Dias],
			CONVERT(VARCHAR, GETDATE()-30 ,112) [30Dias], CONVERT(VARCHAR, GETDATE()-60 ,112) [60Dias]
	*/

	-- Tamanho atual das DATABASES de todos os servidores e crescimento em 1, 15, 30 e 60 dias.
	IF (OBJECT_ID('tempdb..#CheckList_Database_Growth') IS NOT NULL)
		DROP TABLE #CheckList_Database_Growth
	
	CREATE TABLE #CheckList_Database_Growth (
		[Nm_Servidor]	VARCHAR(50) NOT NULL,
		[Nm_Database]	VARCHAR(100) NULL,
		[Tamanho_Atual] NUMERIC(38, 2) NULL,
		[Cresc_1_dia]	NUMERIC(38, 2) NULL,
		[Cresc_15_dia]	NUMERIC(38, 2) NULL,
		[Cresc_30_dia]	NUMERIC(38, 2) NULL,
		[Cresc_60_dia]	NUMERIC(38, 2) NULL
	)
		
	INSERT INTO #CheckList_Database_Growth
	SELECT	B.[Nm_Servidor], [Nm_Database], 
			SUM(CASE WHEN [Dt_Referencia] = @Dt_Hoje   THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Tamanho_Atual],
			SUM(CASE WHEN [Dt_Referencia] = @Dt_1Dia   THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Cresc_1_dia],
			SUM(CASE WHEN [Dt_Referencia] = @Dt_15Dias THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Cresc_15_dia],
			SUM(CASE WHEN [Dt_Referencia] = @Dt_30Dias THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Cresc_30_dia],
			SUM(CASE WHEN [Dt_Referencia] = @Dt_60Dias THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Cresc_60_dia]          
	FROM [dbo].[Historico_Tamanho_Tabela] A
		JOIN [dbo].[Servidor] B ON A.[Id_Servidor] = B.[Id_Servidor] 
		JOIN [dbo].[Tabela] C ON A.[Id_Tabela] = C.[Id_Tabela]
		JOIN [dbo].[BaseDados] D ON A.[Id_BaseDados] = D.[Id_BaseDados]
	WHERE	A.[Dt_Referencia] IN ( @Dt_Hoje, @Dt_1Dia, @Dt_15Dias, @Dt_30Dias, @Dt_60Dias ) -- Hoje, 1 dia, 15 dias, 30 dias, 60 dias
			AND B.[Nm_Servidor] = @@servername -- tratar caso quando o servidor muda de nome
	GROUP BY B.[Nm_Servidor], [Nm_Database]
			
	TRUNCATE TABLE [dbo].[CheckList_Database_Growth]
	TRUNCATE TABLE [dbo].[CheckList_Database_Growth_Email]
		
	INSERT INTO [dbo].[CheckList_Database_Growth] ( [Nm_Servidor], [Nm_Database], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia] )
	SELECT	[Nm_Servidor], [Nm_Database], [Tamanho_Atual], 
			[Tamanho_Atual] - (CASE WHEN [Cresc_1_dia]  = 0 THEN [Tamanho_Atual] ELSE [Cresc_1_dia]  END) [Cresc_1_dia],
			[Tamanho_Atual] - (CASE WHEN [Cresc_15_dia] = 0 THEN [Tamanho_Atual] ELSE [Cresc_15_dia] END) [Cresc_15_dia],
			[Tamanho_Atual] - (CASE WHEN [Cresc_30_dia] = 0 THEN [Tamanho_Atual] ELSE [Cresc_30_dia] END) [Cresc_30_dia],
			[Tamanho_Atual] - (CASE WHEN [Cresc_60_dia] = 0 THEN [Tamanho_Atual] ELSE [Cresc_60_dia] END) [Cresc_60_dia]	
	FROM #CheckList_Database_Growth

	IF (@@ROWCOUNT <> 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Database_Growth_Email] ( [Nm_Servidor], [Nm_Database], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia] )
		SELECT	TOP 10
				[Nm_Servidor], [Nm_Database], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia]
		FROM [dbo].[CheckList_Database_Growth]
		ORDER BY [Cresc_1_dia] DESC, [Cresc_15_dia] DESC, [Cresc_30_dia] DESC, [Cresc_60_dia] DESC
	
		INSERT INTO [dbo].[CheckList_Database_Growth_Email] ( [Nm_Servidor], [Nm_Database], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia] )
		SELECT NULL, 'TOTAL GERAL', SUM([Tamanho_Atual]), SUM([Cresc_1_dia]), SUM([Cresc_15_dia]), SUM([Cresc_30_dia]), SUM([Cresc_60_dia])
		FROM [dbo].[CheckList_Database_Growth]
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[CheckList_Database_Growth_Email] ( [Nm_Servidor], [Nm_Database], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia] )
		SELECT NULL, 'Sem registro de Crescimento de mais de 1 MB das Bases', NULL, NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Table_Growth]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Table_Growth]	
GO

/*******************************************************************************************************************************
--	4) Crescimento Tabela
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Table_Growth]
AS
BEGIN
	SET NOCOUNT ON

	-- Declara e seta AS variaveis das datas - Tratamento para os casos que ainda não atingiram 60 dias no histórico
	DECLARE @Dt_Hoje DATE, @Dt_1Dia DATE, @Dt_15Dias DATE, @Dt_30Dias DATE, @Dt_60Dias DATE
	
	SELECT	@Dt_Hoje = CAST(GETDATE() AS DATE)
	
	SELECT	@Dt_1Dia   = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Referencia], @Dt_Hoje) <= 1  THEN A.[Dt_Referencia] END)),
			@Dt_15Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Referencia], @Dt_Hoje) <= 15 THEN A.[Dt_Referencia] END)),
			@Dt_30Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Referencia], @Dt_Hoje) <= 30 THEN A.[Dt_Referencia] END)),
			@Dt_60Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Referencia], @Dt_Hoje) <= 60 THEN A.[Dt_Referencia] END))
	FROM [dbo].[Historico_Tamanho_Tabela] A
		JOIN [dbo].[Servidor] B ON A.[Id_Servidor] = B.[Id_Servidor] 
		JOIN [dbo].[Tabela] C ON A.[Id_Tabela] = C.[Id_Tabela]
		JOIN [dbo].[BaseDados] D ON A.[Id_BaseDados] = D.[Id_BaseDados]
	WHERE DATEDIFF(DAY,A.[Dt_Referencia], CAST(GETDATE() AS DATE)) <= 60
	
	/*
	-- P/ TESTE
	SELECT @Dt_Hoje Dt_Hoje, @Dt_1Dia Dt_1Dia, @Dt_15Dias Dt_15Dias, @Dt_30Dias Dt_30Dias, @Dt_60Dias Dt_60Dias
	
	SELECT	CONVERT(VARCHAR, GETDATE() ,112) Hoje, CONVERT(VARCHAR, GETDATE()-1 ,112) [1Dia], CONVERT(VARCHAR, GETDATE()-15 ,112) [15Dias],
			CONVERT(VARCHAR, GETDATE()-30 ,112) [30Dias], CONVERT(VARCHAR, GETDATE()-60 ,112) [60Dias]
	*/

	-- Tamanho atual das DATABASES de todos os servidores e crescimento em 1, 15, 30 e 60 dias.
	IF (OBJECT_ID('tempdb..#CheckList_Table_Growth') IS NOT NULL)
		DROP TABLE #CheckList_Table_Growth
	
	CREATE TABLE #CheckList_Table_Growth (
		[Nm_Servidor]	VARCHAR(50) NOT NULL,
		[Nm_Database]	VARCHAR(100) NULL,
		[Nm_Tabela]		VARCHAR(100) NULL,
		[Tamanho_Atual] NUMERIC(38, 2) NULL,
		[Cresc_1_dia]	NUMERIC(38, 2) NULL,
		[Cresc_15_dia]	NUMERIC(38, 2) NULL,
		[Cresc_30_dia]	NUMERIC(38, 2) NULL,
		[Cresc_60_dia]	NUMERIC(38, 2) NULL		
	)
		
	INSERT INTO #CheckList_Table_Growth
	SELECT	B.[Nm_Servidor], [Nm_Database], [Nm_Tabela], 
			SUM(CASE WHEN [Dt_Referencia] = @Dt_Hoje   THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Tamanho_Atual],
			SUM(CASE WHEN [Dt_Referencia] = @Dt_1Dia   THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Cresc_1_dia],
			SUM(CASE WHEN [Dt_Referencia] = @Dt_15Dias THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Cresc_15_dia],
			SUM(CASE WHEN [Dt_Referencia] = @Dt_30Dias THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Cresc_30_dia],
			SUM(CASE WHEN [Dt_Referencia] = @Dt_60Dias THEN A.[Nr_Tamanho_Total] ELSE 0 END) AS [Cresc_60_dia]           
	FROM [dbo].[Historico_Tamanho_Tabela] A
		JOIN [dbo].[Servidor] B ON A.[Id_Servidor] = B.[Id_Servidor] 
		JOIN [dbo].[Tabela] C ON A.[Id_Tabela] = C.[Id_Tabela]
		JOIN [dbo].[BaseDados] D ON A.[Id_BaseDados] = D.[Id_BaseDados]
	WHERE A.[Dt_Referencia] IN( @Dt_Hoje, @Dt_1Dia, @Dt_15Dias, @Dt_30Dias, @Dt_60Dias) -- Hoje, 1 dia, 15 dias, 30 dias, 60 dias
	GROUP BY B.[Nm_Servidor], [Nm_Database], [Nm_Tabela]
			
	TRUNCATE TABLE [dbo].[CheckList_Table_Growth]
	TRUNCATE TABLE [dbo].[CheckList_Table_Growth_Email]
			
	INSERT INTO [dbo].[CheckList_Table_Growth] ( [Nm_Servidor], [Nm_Database], [Nm_Tabela], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia] )
	SELECT	[Nm_Servidor], [Nm_Database], [Nm_Tabela], [Tamanho_Atual], 
			[Tamanho_Atual] - (CASE WHEN [Cresc_1_dia] = 0  THEN [Tamanho_Atual] ELSE [Cresc_1_dia]  END) [Cresc_1_dia],
			[Tamanho_Atual] - (CASE WHEN [Cresc_15_dia] = 0 THEN [Tamanho_Atual] ELSE [Cresc_15_dia] END) [Cresc_15_dia],
			[Tamanho_Atual] - (CASE WHEN [Cresc_30_dia] = 0 THEN [Tamanho_Atual] ELSE [Cresc_30_dia] END) [Cresc_30_dia],
			[Tamanho_Atual] - (CASE WHEN [Cresc_60_dia] = 0 THEN [Tamanho_Atual] ELSE [Cresc_60_dia] END) [Cresc_60_dia]
	FROM #CheckList_Table_Growth
	
	IF (@@ROWCOUNT <> 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Table_Growth_Email] ( [Nm_Servidor], [Nm_Database], [Nm_Tabela], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia] )
		SELECT	TOP 10
				[Nm_Servidor], [Nm_Database], [Nm_Tabela], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia]
		FROM [dbo].[CheckList_Table_Growth]
		ORDER BY [Cresc_1_dia] DESC, [Cresc_15_dia] DESC, [Cresc_30_dia] DESC, [Cresc_60_dia] DESC
	
		INSERT INTO [dbo].[CheckList_Table_Growth_Email] ( [Nm_Servidor], [Nm_Database], [Nm_Tabela], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia] )
		SELECT NULL, 'TOTAL GERAL', NULL, SUM([Tamanho_Atual]), SUM([Cresc_1_dia]), SUM([Cresc_15_dia]), SUM([Cresc_30_dia]), SUM([Cresc_60_dia])
		FROM [dbo].[CheckList_Table_Growth]
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[CheckList_Table_Growth_Email] ( [Nm_Servidor], [Nm_Database], [Nm_Tabela], [Tamanho_Atual], [Cresc_1_dia], [Cresc_15_dia], [Cresc_30_dia], [Cresc_60_dia] )
		SELECT NULL, 'Sem registro de Crescimento de mais de 1 MB das Tabelas', NULL, NULL, NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Backups_Executados]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Backups_Executados]	
GO	
	
/*******************************************************************************************************************************
--	5) Backups Executados
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Backups_Executados]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Dt_Referencia DATETIME
	SELECT @Dt_Referencia = GETDATE()

	TRUNCATE TABLE [dbo].[CheckList_Backups_Executados]
	
	INSERT INTO [dbo].[CheckList_Backups_Executados] (	[Database_Name], [Name], [Backup_Start_Date], [Tempo_Min], [Position], [Server_Name],
														[Recovery_Model], [Logical_Device_Name], [Device_Type], [Type], [Tamanho_MB] )
	SELECT	[database_name], [name], [backup_start_date], DATEdiff(mi, [backup_start_date], [backup_finish_date]) AS [Tempo_Min], 
			[position], [server_name], [recovery_model], isnull([logical_device_name], ' ') AS [logical_device_name],
			[device_type], [type], CAST([backup_size]/1024/1024 AS NUMERIC(15,2)) AS [Tamanho (MB)]
	FROM [msdb].[dbo].[backupset] B
		JOIN [msdb].[dbo].[backupmediafamily] BF ON B.[media_set_id] = BF.[media_set_id]
	WHERE [backup_start_date] >= DATEADD(hh, -24 ,@Dt_Referencia) AND [type] in ('D','I')
		  
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Backups_Executados] (	[Database_Name], [Name], [Backup_Start_Date], [Tempo_Min], [Position], [Server_Name],
															[Recovery_Model], [Logical_Device_Name], [Device_Type], [Type], [Tamanho_MB] )
		SELECT 'Sem registro de Backup FULL ou Diferencial nas últimas 24 horas.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Jobs_Failed]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Jobs_Failed]
GO

/*******************************************************************************************************************************
--	6) JOBS que Falharam
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Jobs_Failed]
AS
BEGIN
	SET NOCOUNT ON
	
	IF (OBJECT_ID('tempdb..Result_History_Jobs') IS NOT NULL)
		DROP TABLE #Result_History_Jobs

	CREATE TABLE #Result_History_Jobs (
		[Cod] INT IDENTITY(1,1),
		[Instance_Id] INT,
		[Job_Id] VARCHAR(255),
		[Job_Name] VARCHAR(255),
		[Step_Id] INT,
		[Step_Name] VARCHAR(255),
		[SQl_Message_Id] INT,
		[Sql_Severity] INT,
		[SQl_Message] VARCHAR(4490),
		[Run_Status] INT,
		[Run_Date] VARCHAR(20),
		[Run_Time] VARCHAR(20),
		[Run_Duration] INT,
		[Operator_Emailed] VARCHAR(100),
		[Operator_NetSent] VARCHAR(100),
		[Operator_Paged] VARCHAR(100),
		[Retries_Attempted] INT,
		[Nm_Server] VARCHAR(100)  
	)

	DECLARE @hoje VARCHAR(8), @ontem VARCHAR(8)	
	SELECT	@ontem = CONVERT(VARCHAR(8),(DATEADD (DAY, -1, GETDATE())), 112), 
			@hoje = CONVERT(VARCHAR(8), GETDATE() + 1, 112)

	INSERT INTO #Result_History_Jobs
	EXEC [msdb].[dbo].[sp_help_jobhistory] @mode = 'FULL', @start_run_date = @ontem

	TRUNCATE TABLE [dbo].[CheckList_Jobs_Failed]
	
	INSERT INTO [dbo].[CheckList_Jobs_Failed] ( [Server], [Job_Name], [Status], [Dt_Execucao], [Run_Duration], [SQL_Message] )
	SELECT	Nm_Server AS [Server], [Job_Name], 
			CASE	WHEN [Run_Status] = 0 THEN 'Failed'
					WHEN [Run_Status] = 1 THEN 'Succeeded'
					WHEN [Run_Status] = 2 THEN 'Retry (step only)'
					WHEN [Run_Status] = 3 THEN 'Cancelled'
					WHEN [Run_Status] = 4 THEN 'In-progress message'
					WHEN [Run_Status] = 5 THEN 'Unknown' 
			END [Status],
			CAST(	[Run_Date] + ' ' +
					RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-3), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-1), 2), 2) AS VARCHAR) AS [Dt_Execucao],
			RIGHT('00' + SUBSTRING(CAST([Run_Duration] AS VARCHAR),(LEN([Run_Duration])-5),2), 2) + ':' +
			RIGHT('00' + SUBSTRING(CAST([Run_Duration] AS VARCHAR),(LEN([Run_Duration])-3),2), 2) + ':' +
			RIGHT('00' + SUBSTRING(CAST([Run_Duration] AS VARCHAR),(LEN([Run_Duration])-1),2), 2) AS [Run_Duration],
			CAST([SQl_Message] AS VARCHAR(3990)) AS [SQl_Message]
	FROM #Result_History_Jobs 
	WHERE 
		  CAST([Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
			  RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-3), 2), 2) + ':' +
			  RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-1), 2), 2) AS DATETIME) >= @ontem + ' 08:00' 
		  AND  /*dia anterior no horário*/
			CAST([Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
			  RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-3), 2), 2) + ':' +
			  RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-1), 2), 2) AS DATETIME) < @hoje
		  AND [Step_Id] = 0
		  AND [Run_Status] <> 1
	 
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Jobs_Failed] ( [Server], [Job_Name], [Status], [Dt_Execucao], [Run_Duration], [SQL_Message] )
		SELECT NULL, 'Sem registro de Falha de JOB', NULL, NULL, NULL, NULL		
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Alteracao_Jobs]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Alteracao_Jobs]
GO

/*******************************************************************************************************************************
--	7) JOBS Alterados
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Alteracao_Jobs]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @hoje VARCHAR(8), @ontem VARCHAR(8)	
	SELECT	@ontem  = CONVERT(VARCHAR(8),(DATEADD (DAY, -1, GETDATE())), 112),
			@hoje = CONVERT(VARCHAR(8), GETDATE()+1, 112)

	TRUNCATE TABLE [dbo].[CheckList_Alteracao_Jobs]

	INSERT INTO [dbo].[CheckList_Alteracao_Jobs] ( [Nm_Job], [Fl_Habilitado], [Dt_Criacao], [Dt_Modificacao], [Nr_Versao] )
	SELECT	[name] AS [Nm_Job], CONVERT(SMALLINT, [enabled]) AS [Fl_Habilitado], CONVERT(SMALLDATETIME, [date_created]) AS [Dt_Criacao], 
			CONVERT(SMALLDATETIME, [date_modified]) AS [Dt_Modificacao], [version_number] AS [Nr_Versao]
	FROM [msdb].[dbo].[sysjobs]  sj     
	WHERE	( [date_created] >= @ontem AND [date_created] < @hoje) OR ([date_modified] >= @ontem AND [date_modified] < @hoje)	
	 
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Alteracao_Jobs] ( [Nm_Job], [Fl_Habilitado], [Dt_Criacao], [Dt_Modificacao], [Nr_Versao] )
		SELECT 'Sem registro de JOB Alterado', NULL, NULL, NULL, NULL
	END
END
	
GO
IF (OBJECT_ID('[dbo].[stpCheckList_Job_Demorados]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Job_Demorados]	
GO	

/*******************************************************************************************************************************
--	8) JOBS Demorados
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Job_Demorados]
AS
BEGIN
	SET NOCOUNT ON

	IF (OBJECT_ID('tempdb..#Result_History_Jobs') IS NOT NULL)
		DROP TABLE #Result_History_Jobs
		
	CREATE TABLE #Result_History_Jobs (
		[Cod]				INT	IDENTITY(1,1),
		[Instance_Id]		INT,
		[Job_Id]			VARCHAR(255),
		[Job_Name]			VARCHAR(255),
		[Step_Id]			INT,
		[Step_Name]			VARCHAR(255),
		[Sql_Message_Id]	INT,
		[Sql_Severity]		INT,
		[SQl_Message]		VARCHAR(4490),
		[Run_Status]		INT,
		[Run_Date]			VARCHAR(20),
		[Run_Time]			VARCHAR(20),
		[Run_Duration]		INT,
		[Operator_Emailed]	VARCHAR(100),
		[Operator_NetSent]	VARCHAR(100),
		[Operator_Paged]	VARCHAR(100),
		[Retries_Attempted] INT,
		[Nm_Server]			VARCHAR(100)  
	)
	
	DECLARE @ontem VARCHAR(8)
	SET @ontem  =  CONVERT(VARCHAR(8), (DATEADD(DAY, -1, GETDATE())), 112)

	INSERT INTO #Result_History_Jobs
	EXEC [msdb].[dbo].[sp_help_jobhistory] @mode = 'FULL', @start_run_date = @ontem

	TRUNCATE TABLE [dbo].[CheckList_Job_Demorados]
	
	INSERT INTO [dbo].[CheckList_Job_Demorados] ( [Job_Name], [Status], [Dt_Execucao], [Run_Duration], [SQL_Message] )
	SELECT	[Job_Name], 
			CASE	WHEN [Run_Status] = 0 THEN 'Failed'
					WHEN [Run_Status] = 1 THEN 'Succeeded'
					WHEN [Run_Status] = 2 THEN 'Retry (step only)'
					WHEN [Run_Status] = 3 THEN 'Canceled'
					WHEN [Run_Status] = 4 THEN 'In-progress message'
					WHEN [Run_Status] = 5 THEN 'Unknown' 
			END [Status],
			CAST([Run_Date] + ' ' +
				RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
				RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-3), 2), 2) + ':' +
				RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-1), 2), 2) AS VARCHAR) AS [Dt_Execucao],
			RIGHT('00' + SUBSTRING(CAST(Run_Duration AS VARCHAR),(LEN(Run_Duration)-5), 2), 2)+ ':' +
				RIGHT('00' + SUBSTRING(CAST(Run_Duration AS VARCHAR),(LEN(Run_Duration)-3), 2) ,2) + ':' +
				RIGHT('00' + SUBSTRING(CAST(Run_Duration AS VARCHAR),(LEN(Run_Duration)-1), 2) ,2) AS [Run_Duration],
			CAST([SQl_Message] AS VARCHAR(3990)) AS [SQL_Message]	
	FROM #Result_History_Jobs
	WHERE 
		  CAST([Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
		  RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-3), 2), 2) + ':' +
		  RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-1), 2), 2) AS DATETIME) >= GETDATE() -1 and
		  CAST([Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2)+ ':' +
		  RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-3), 2), 2) + ':' +
		  RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-1), 2), 2) AS DATETIME) < GETDATE() 
		  AND [Step_Id] = 0
		  AND [Run_Status] = 1
		  AND [Run_Duration] >= 100  -- JOBS que demoraram mais de 1 minuto

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Job_Demorados] ( [Job_Name], [Status], [Dt_Execucao], [Run_Duration], [SQL_Message] )
		SELECT 'Sem registro de JOBs Demorados', NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Traces_Queries]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Traces_Queries]	
GO

/*******************************************************************************************************************************
--	9) Trace Queries Demoradas
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Traces_Queries]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Dt_Referencia DATETIME
	SET @Dt_Referencia = CAST(GETDATE()-1 AS DATE)

	IF (OBJECT_ID('tempdb..#Temp_Result') IS NOT NULL) 
		DROP TABLE #Temp_Result

	SELECT	[TextData], [NTUserName], [HostName], [ApplicationName], [LoginName], [SPID], [Duration], [StartTime], 
			[EndTime], [ServerName], [Reads], [Writes], [CPU], [DataBaseName], [RowCounts], [SessionLoginName]
	INTO #Temp_Result
	FROM [dbo].[Traces] (nolock)
	WHERE [StartTime] >= DATEADD(hh, 8, @Dt_Referencia)
		  AND [StartTime] < DATEADD(hh, 23, @Dt_Referencia)
	
	IF (OBJECT_ID('tempdb..#Top10') IS NOT NULL) 
		DROP TABLE #Top10

	SELECT	TOP 10 LTRIM(CAST([TextData] AS CHAR(150))) AS [PrefixoQuery], COUNT(*) AS [QTD], SUM([Duration]) AS [Total], 
			AVG([Duration]) AS [Media], MIN([Duration]) AS [Menor], MAX([Duration]) AS [Maior],  
			SUM([Writes]) AS [Writes], SUM([CPU]) AS [CPU]
	INTO #Top10
	FROM #Temp_Result
	GROUP BY CAST([TextData] AS CHAR(150))
	
	TRUNCATE TABLE [dbo].[CheckList_Traces_Queries]
		
	INSERT INTO [dbo].[CheckList_Traces_Queries] ( [PrefixoQuery], [QTD], [Total], [Media], [Menor], [Maior], [Writes], [CPU], [Ordem] )
	SELECT [PrefixoQuery], [QTD], [Total], [Media], [Menor], [Maior], [Writes], [CPU], 1 AS [Ordem]
	FROM #Top10
	
	IF (@@ROWCOUNT <> 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Traces_Queries] ( [PrefixoQuery], [QTD], [Total], [Media], [Menor], [Maior], [Writes], [CPU], [Ordem] )
		SELECT	'OUTRAS' AS [PrefixoQuery], COUNT(*) AS [QTD], SUM([Duration]) AS [Total], 
				AVG([Duration]) AS [Media], MIN([Duration]) AS [Menor], MAX([Duration]) AS [Maior],  
				SUM([Writes]) AS [Writes], SUM([CPU]) AS [CPU], 2 AS [Ordem]
		FROM #Temp_Result A		
		WHERE CAST([TextData] AS CHAR(150)) NOT IN (SELECT [PrefixoQuery] FROM #Top10)

		INSERT INTO [dbo].[CheckList_Traces_Queries] ( [PrefixoQuery], [QTD], [Total], [Media], [Menor], [Maior], [Writes], [CPU], [Ordem] )
		SELECT	'TOTAL' AS [PrefixoQuery], SUM([QTD]), SUM([Total]), AVG([Media]), MIN([Menor]) AS [Menor], 
				MAX([Maior]) AS [Maior], SUM([Writes]) AS [Writes], SUM([CPU]) AS [CPU], 3 AS [Ordem]
		FROM [dbo].[CheckList_Traces_Queries]
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[CheckList_Traces_Queries] ( [PrefixoQuery], [QTD], [Total], [Media], [Menor], [Maior], [Writes], [CPU], [Ordem] )	
		SELECT 'Sem registro de Queries Demoradas', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1		
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Contadores]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Contadores]
GO

/*******************************************************************************************************************************
--	10) Contadores
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Contadores]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Contadores]

	DECLARE @Dt_Referencia DATETIME
	SET @Dt_Referencia = CAST(GETDATE()-1 AS DATE)
	
	INSERT INTO [dbo].[CheckList_Contadores]( [Hora], [Nm_Contador], [Media] )
	SELECT DATEPART(hh, [Dt_Log]) AS [Hora], [Nm_Contador], AVG([Valor]) AS [Media]
	FROM [dbo].[Registro_Contador] A
		JOIN [dbo].[Contador] B ON A.[Id_Contador] = B.[Id_Contador]
	WHERE [Dt_Log] >= DATEADD(hh, 8, @Dt_Referencia) AND [Dt_Log] < DATEADD(hh, 21, @Dt_Referencia)   
	GROUP BY DATEPART(hh, [Dt_Log]), [Nm_Contador]

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Contadores]( [Hora], [Nm_Contador], [Media] )
		SELECT NULL, 'Sem registro de Contador', NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Fragmentacao_Indices]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Fragmentacao_Indices]
GO

/*******************************************************************************************************************************
--	11) Fragmentação de Índices
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Fragmentacao_Indices]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Max_Dt_Referencia DATETIME

	SELECT @Max_Dt_Referencia = MAX(Dt_Referencia) FROM [dbo].[vwHistorico_Fragmentacao_Indice]

	TRUNCATE TABLE [dbo].[CheckList_Fragmentacao_Indices]
	
	INSERT INTO [dbo].[CheckList_Fragmentacao_Indices] (	[Dt_Referencia], [Nm_Servidor], [Nm_Database], [Nm_Tabela], [Nm_Indice], 
															[Avg_Fragmentation_In_Percent], [Page_Count], [Fill_Factor], [Fl_Compressao] )
	SELECT	[Dt_Referencia], [Nm_Servidor], [Nm_Database], [Nm_Tabela], [Nm_Indice], 
			[Avg_Fragmentation_In_Percent], [Page_Count], [Fill_Factor], [Fl_Compressao]
	FROM [dbo].[vwHistorico_Fragmentacao_Indice]
	WHERE	CAST([Dt_Referencia] AS DATE) = CAST(@Max_Dt_Referencia AS DATE)
			AND [Avg_Fragmentation_In_Percent] > 10
			AND [Page_Count] > 1000
	
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Fragmentacao_Indices] (	[Dt_Referencia], [Nm_Servidor], [Nm_Database], [Nm_Tabela], [Nm_Indice], 
																[Avg_Fragmentation_In_Percent], [Page_Count], [Fill_Factor], [Fl_Compressao] )
		SELECT NULL, NULL, 'Sem registro de Índice com mais de 10% de Fragmentação', NULL, NULL, NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Waits_Stats]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Waits_Stats]
GO

/*******************************************************************************************************************************
--	12) Waits Stats
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_Waits_Stats]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Dt_Referencia DATETIME, @Dt_Inicio DATETIME, @Dt_Fim DATETIME
	SET @Dt_Referencia = CAST(GETDATE()-1 AS DATE)
	
	SELECT @Dt_Inicio = DATEADD(hh, 8, @Dt_Referencia), @Dt_Fim = DATEADD(hh, 23, @Dt_Referencia)   

	TRUNCATE TABLE [dbo].[CheckList_Waits_Stats]

	INSERT INTO [dbo].[CheckList_Waits_Stats](	[WaitType], [Min_Log], [Max_Log], [DIf_Wait_S], [DIf_Resource_S], [DIf_Signal_S], 
												[DIf_WaitCount], [DIf_Percentage], [Last_Percentage] )
	EXEC [dbo].[stpHistorico_Waits_Stats] @Dt_Inicio, @Dt_Fim
	
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Waits_Stats](	[WaitType], [Min_Log], [Max_Log], [DIf_Wait_S], [DIf_Resource_S], [DIf_Signal_S], 
													[DIf_WaitCount], [DIf_Percentage], [Last_Percentage] )
		SELECT 'Sem registro de Waits Stats.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_SQLServer_ErrorLog]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_SQLServer_ErrorLog]
GO

/*******************************************************************************************************************************
--	13) Error Log SQL
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpCheckList_SQLServer_ErrorLog]
AS
BEGIN
	SET NOCOUNT ON

	IF (OBJECT_ID('tempdb..#TempLog') IS NOT NULL)
		DROP TABLE #TempLog
	
	CREATE TABLE #TempLog (
		[LogDate]		DATETIME,
		[ProcessInfo]	NVARCHAR(50),
		[Text]			NVARCHAR(MAX)
	)

	IF (OBJECT_ID('tempdb..#logF') IS NOT NULL)
		DROP TABLE #logF
	
	CREATE TABLE #logF (
		[ArchiveNumber] INT,
		[LogDate]		DATETIME,
		[LogSize]		INT 
	)

	-- Seleciona o número de arquivos.
	INSERT INTO #logF  
	EXEC sp_enumerrorlogs

	DELETE FROM #logF
	WHERE LogDate < GETDATE()-2

	DECLARE @TSQL NVARCHAR(2000), @lC INT

	SELECT @lC = MIN(ArchiveNumber) FROM #logF

	-- Loop para realizar a leitura de todo o log
	WHILE @lC IS NOT NULL
	BEGIN
		  INSERT INTO #TempLog
		  EXEC sp_readerrorlog @lC
		  SELECT @lC = MIN(ArchiveNumber) FROM #logF
		  WHERE ArchiveNumber > @lC
	END
	
	TRUNCATE TABLE [dbo].[CheckList_SQLServer_ErrorLog]
	
	INSERT INTO [dbo].[CheckList_SQLServer_ErrorLog]( [Dt_Log], [ProcessInfo], [Text] )
	SELECT [LogDate], [ProcessInfo], [Text]
	FROM #TempLog
	WHERE [LogDate] >= GETDATE()-1
		AND [ProcessInfo] <> 'Backup'
		AND [Text] NOT LIKE '%CHECKDB%'
		AND [Text] NOT LIKE '%Trace%'
		AND [Text] NOT LIKE '%IDR%'
		AND [Text] NOT LIKE 'AppDomain%'
		AND [Text] NOT LIKE 'Unsafe assembly%'
		AND [Text] NOT LIKE '%Error:%Severity:%State:%'
		AND [Text] NOT LIKE '%No user action is required.%'
		AND [Text] NOT LIKE '%no user action is required.%'

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_SQLServer_ErrorLog]( [Dt_Log], [ProcessInfo], [Text] )
		SELECT NULL, NULL, 'Sem registro de Erro no Log'
	END
END

GO

/*	-- MIRROR

GO

IF (OBJECT_ID('[dbo].[CheckList_Databases_Mirror]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Databases_Mirror]

CREATE TABLE [dbo].[CheckList_Databases_Mirror] (
	Database_Name		VARCHAR(100),
	Fl_Operation_Mode	VARCHAR(50),
	Role_Mirror			VARCHAR(50),
	Mirroring_State		VARCHAR(50),
	Witness_Status		VARCHAR(50),
	Horario				VARCHAR(30)
)

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Databases_Mirror]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Databases_Mirror]
GO

/*******************************************************************************************************************************
--	14) Situação Databases Mirror
*******************************************************************************************************************************/

CREATE PROCEDURE [dbo].[stpCheckList_Databases_Mirror]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Ultimo_Registro AS TABLE (
		Database_Name VARCHAR(100),
		Id_Historico_Log INT
	)

	-- Busca o último registro da database no Mirror
	INSERT INTO @Ultimo_Registro
	SELECT A.[Database_Name], max(A.[Id_Historico_Log]) AS [Id_Historico_Log]
	FROM [dbo].[Historico_Log_DBMirror] A WITH(NOLOCK) 
	WHERE [Local_Time] >= DATEADD(day,-1,GETDATE())					
	GROUP BY A.[Database_Name]

	TRUNCATE TABLE [dbo].[CheckList_Databases_Mirror]

	INSERT INTO [dbo].[CheckList_Databases_Mirror]
	SELECT	B.[Database_Name],
			CASE ISNULL(B.Fl_Operation_Mode, 0)
				WHEN 0 THEN 'Não configurado'
				WHEN 1 THEN 'HP Sem Failover'
				WHEN 2 THEN 'HS Sem Failover'
				WHEN 3 THEN 'HS Com Failover'
			END AS [Fl_Operation_Mode],	
			CASE B.[Role] WHEN 1 THEN 'Principal' WHEN 2 THEN 'Mirror' END AS [Role_Mirror],
			CASE B.[Mirroring_State] 
				WHEN 0 THEN 'Suspended'
				WHEN 1 THEN 'Disconnected'
				WHEN 2 THEN 'Synchronizing'
				WHEN 3 THEN 'Pending Failover'
				WHEN 4 THEN 'Synchronized' 
			END AS Mirroring_State,								
			CASE B.[Witness_Status] WHEN 0 THEN 'UnKnown' WHEN 1 THEN 'Connected' WHEN 2 THEN 'Disconnected' END AS [Witness_Status],
			CONVERT(VARCHAR, B.[Local_Time], 20) AS [Horario]
	FROM	(	
				SELECT C.* 
				FROM [dbo].[Historico_Log_DBMirror] C
				JOIN @Ultimo_Registro D ON C.[Id_Historico_Log] = D.[Id_Historico_Log]
			)	B
			
	IF ( @@ROWCOUNT = 0 )
	BEGIN
		INSERT INTO [dbo].[CheckList_Databases_Mirror]
		SELECT 'Sem registro de Database com Mirror.', NULL, NULL, NULL, NULL, NULL
	END
END

*/