/*******************************************************************************************************************************
(C) 2016, Fabricio Lima Soluções em Banco de Dados

Site: http://www.fabriciolima.net/

Feedback: contato@fabriciolima.net
*******************************************************************************************************************************/


/*******************************************************************************************************************************
--	Instruções de utilização do script.
*******************************************************************************************************************************/
--	Basta apertar F5 para executar o Script.

--	Aqui estamos criando as rotinas abaixo:
--	1)	Contadores no SQL Server
--	2)	Tamanho de Tabelas
--	3)	Fragmentação de Índices
--	4)	WaitsStats
--  5)	Utilização Arquivo


--------------------------------------------------------------------------------------------------------------------------------
-- Criação das tabelas dos Contadores.
--------------------------------------------------------------------------------------------------------------------------------
use Traces

if OBJECT_ID('Contador') is not null
	drop table Contador

if OBJECT_ID('Registro_Contador') is not null
	drop table Registro_Contador

CREATE TABLE [dbo].[Contador] (
	Id_Contador INT identity, 
	Nm_Contador VARCHAR(50) 
)

INSERT INTO Contador (Nm_Contador)
SELECT 'BatchRequests'
INSERT INTO Contador (Nm_Contador)
SELECT 'User_Connection'
INSERT INTO Contador (Nm_Contador)
SELECT 'CPU'
INSERT INTO Contador (Nm_Contador)
SELECT 'Page Life Expectancy'

-- SELECT * FROM Contador

CREATE TABLE [dbo].[Registro_Contador] (
	[Id_Registro_Contador] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Log] [datetime] NULL,
	[Id_Contador] [int] NULL,
	[Valor] [int] NULL
) ON [PRIMARY]


--------------------------------------------------------------------------------------------------------------------------------
-- Criação da procedure que realiza a carga dos Contadores.
--------------------------------------------------------------------------------------------------------------------------------
if OBJECT_ID('stpCarga_ContadoresSQL') is not null
	drop procedure stpCarga_ContadoresSQL

GO

CREATE PROCEDURE [dbo].[stpCarga_ContadoresSQL]
AS
BEGIN
	DECLARE @BatchRequests INT,@User_Connection INT, @CPU INT, @PLE int

	DECLARE @RequestsPerSecondSample1	BIGINT
	DECLARE @RequestsPerSecondSample2	BIGINT

	SELECT @RequestsPerSecondSample1 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'
	WAITFOR DELAY '00:00:05'
	SELECT @RequestsPerSecondSample2 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'
	SELECT @BatchRequests = (@RequestsPerSecondSample2 - @RequestsPerSecondSample1)/5

	select @User_Connection = cntr_Value
	from sys.dm_os_performance_counters
	where counter_name = 'User Connections'
								
	SELECT  TOP(1) @CPU  = (SQLProcessUtilization + (100 - SystemIdle - SQLProcessUtilization ) )
	FROM ( 
			  SELECT	record.value('(./Record/@id)[1]', 'int') AS record_id, 
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle], 
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization], 
						[timestamp] 
			  FROM ( 
						SELECT [timestamp], CONVERT(xml, record) AS [record] 
						FROM sys.dm_os_ring_buffers 
						WHERE	ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
								AND record LIKE '%<SystemHealth>%'
					) AS x
		  ) AS y
		  
	SELECT @PLE = cntr_value 
	FROM sys.dm_os_performance_counters
	WHERE	counter_name = 'Page life expectancy'
			AND object_name like '%Buffer Manager%'

	insert INTO Registro_Contador(Dt_Log, Id_Contador, Valor)
	Select GETDATE(), 1, @BatchRequests
	insert INTO Registro_Contador(Dt_Log, Id_Contador, Valor)
	Select GETDATE(), 2, @User_Connection
	insert INTO Registro_Contador(Dt_Log, Id_Contador, Valor)
	Select GETDATE(), 3, @CPU
	insert INTO Registro_Contador(Dt_Log, Id_Contador, Valor)
	Select GETDATE(), 4, @PLE
END

GO


--------------------------------------------------------------------------------------------------------------------------------
-- Criação das tabelas para Histórico de Tamanho.
--------------------------------------------------------------------------------------------------------------------------------
use Traces

if object_id('Historico_Tamanho_Tabela') is not null
	drop table Historico_Tamanho_Tabela

if object_id('BaseDados') is not null
	drop table BaseDados

if object_id('Tabela') is not null
	drop table Tabela

if object_id('Servidor') is not null
	drop table Servidor

CREATE TABLE [dbo].[Historico_Tamanho_Tabela] (
	[Id_Historico_Tamanho] [int] IDENTITY(1,1) NOT NULL,
	[Id_Servidor] [smallint] NULL,
	[Id_BaseDados] [smallint] NULL,
	[Id_Tabela] [int] NULL,
	[Nm_Drive] [char](1) NULL,
	[Nr_Tamanho_Total] [numeric](9, 2) NULL,
	[Nr_Tamanho_Dados] [numeric](9, 2) NULL,
	[Nr_Tamanho_Indice] [numeric](9, 2) NULL,
	[Qt_Linhas] [bigint] NULL,
	[Dt_Referencia] [date] NULL,
	CONSTRAINT [PK_Historico_Tamanho_Tabela] PRIMARY KEY CLUSTERED (
		[Id_Historico_Tamanho] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [dbo].[BaseDados] (
	[Id_BaseDados] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Database] [varchar](500) NULL,
	CONSTRAINT [PK_BaseDados] PRIMARY KEY CLUSTERED (Id_BaseDados)
) ON [PRIMARY]

CREATE TABLE [dbo].[Tabela] (
	[Id_Tabela] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Tabela] [varchar](1000) NULL,
	CONSTRAINT [PK_Tabela] PRIMARY KEY CLUSTERED (
		[Id_Tabela] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [dbo].[Servidor] (
	[Id_Servidor] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Servidor] [varchar](100) NOT NULL,
	CONSTRAINT [PK_Servidor] PRIMARY KEY CLUSTERED (
		[Id_Servidor] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criação da View que retorna o Historico de Tamanho.
--------------------------------------------------------------------------------------------------------------------------------
if object_id('vwTamanho_Tabela') is not null
	drop view vwTamanho_Tabela
GO

CREATE VIEW [dbo].[vwTamanho_Tabela]
AS

select	A.Dt_Referencia, B.Nm_Servidor, C.Nm_Database,D.Nm_Tabela ,A.Nm_Drive, 
		A.Nr_Tamanho_Total, A.Nr_Tamanho_Dados, A.Nr_Tamanho_Indice, A.Qt_Linhas
from Historico_Tamanho_Tabela A
	join Servidor B on A.Id_Servidor = B.Id_Servidor
	join BaseDados C on A.Id_BaseDados = C.Id_BaseDados
	join Tabela D on A.Id_Tabela = D.Id_Tabela

GO

if object_id('stpTamanhos_Tabelas') is not null
	drop procedure stpTamanhos_Tabelas

GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criação da procedure que realiza a carga do Tamanho das Tabelas.
--------------------------------------------------------------------------------------------------------------------------------
CREATE proc [dbo].[stpTamanhos_Tabelas]
AS
BEGIN
	declare @Databases table(Id_Database int identity(1,1), Nm_Database varchar(120))

	declare @Total int, @i int, @Database varchar(120), @cmd varchar(8000);
	
	insert into @Databases(Nm_Database)
	select name
	from sys.databases
	where	name not in ('master','model','tempdb') -- todos os servidores que não recebem restore
			and state_desc = 'online'
						
	select @Total = max(Id_Database)
	from @Databases

	set @i = 1

	if object_id('tempdb..##Tamanho_Tabelas') is not null 
		drop table ##Tamanho_Tabelas
				
	CREATE TABLE ##Tamanho_Tabelas(
		[Nm_Servidor] VARCHAR(256),
		[Nm_Database] varchar(256),
		[Nm_Schema] [varchar](8000) NULL,
		[Nm_Tabela] [varchar](8000) NULL,
		[Nm_Index] [varchar](8000) NULL,
		[Nm_Drive] CHAR(1),
		[Used_in_kb] [int] NULL,
		[Reserved_in_kb] [int] NULL,
		[Tbl_Rows] [bigint] NULL,
		[Type_Desc] [varchar](20) NULL
	) ON [PRIMARY]

	while (@i <= @Total)
	begin
		IF EXISTS (SELECT NULL from @Databases  where Id_Database = @i) -- caso a database foi deletada da tabela @databases, não faz nada.
		BEGIN
			select @Database = Nm_Database
			from @Databases
			where Id_Database = @i
						
			set @cmd = '
				insert into ##Tamanho_Tabelas
				select	@@SERVERNAME,					
						''' + @Database + ''' Nm_Database, t.schema_name, t.table_Name, t.Index_name,
						(
							SELECT SUBSTRING(filename,1,1) 
							FROM ' + QUOTENAME(@Database) + '.sys.sysfiles 
							WHERE fileid = 1
						),
						sum(t.used) as used_in_kb,
						sum(t.reserved) as Reserved_in_kb,
						--case grouping (t.Index_name) when 0 then sum(t.ind_rows) else sum(t.tbl_rows) end as rows,
						max(t.tbl_rows) as rows,
						type_Desc
				from	(
							select	s.name as schema_name, 
									o.name as table_Name,
									coalesce(i.name,''heap'') as Index_name,
									p.used_page_Count*8 as used,
									p.reserved_page_count*8 as reserved, 
									p.row_count as ind_rows,
									(case when i.index_id in (0,1) then p.row_count else 0 end) as tbl_rows, 
									i.type_Desc as type_Desc
							from
								' + QUOTENAME(@Database) + '.sys.dm_db_partition_stats p
								join ' + QUOTENAME(@Database) + '.sys.objects o on o.object_id = p.object_id
								join ' + QUOTENAME(@Database) + '.sys.schemas s on s.schema_id = o.schema_id
								left join ' + QUOTENAME(@Database) + '.sys.indexes i on i.object_id = p.object_id and i.index_id = p.index_id
							where o.type_desc = ''user_Table'' and o.is_Ms_shipped = 0
						) as t
				group by t.schema_name, t.table_Name,t.Index_name,type_Desc
				--with rollup -- no sql server 2005, essa linha deve ser habilitada **********************************************
				--order by grouping(t.schema_name),t.schema_name,grouping(t.table_Name),t.table_Name,	grouping(t.Index_name),t.Index_name
				'

			EXEC(@cmd);
			/*print @cmd; -- para debbug
			print '
				##################################################################################
			'; -- para debbug*/
		END
		
		set @i = @i + 1
	end 

	INSERT INTO Traces.dbo.Servidor(Nm_Servidor)
	SELECT DISTINCT A.Nm_Servidor 
	FROM ##Tamanho_Tabelas A
		LEFT JOIN Traces.dbo.Servidor B ON A.Nm_Servidor = B.Nm_Servidor
	WHERE B.Nm_Servidor IS null
		
	INSERT INTO Traces.dbo.BaseDados(Nm_Database)
	SELECT DISTINCT A.Nm_Database 
	FROM ##Tamanho_Tabelas A
		LEFT JOIN Traces.dbo.BaseDados B ON A.Nm_Database = B.Nm_Database
	WHERE B.Nm_Database IS null
	
	INSERT INTO Traces.dbo.Tabela(Nm_Tabela)
	SELECT DISTINCT A.Nm_Tabela 
	FROM ##Tamanho_Tabelas A
		LEFT JOIN Traces.dbo.Tabela B ON A.Nm_Tabela = B.Nm_Tabela
	WHERE B.Nm_Tabela IS null	

	insert into Traces.dbo.Historico_Tamanho_Tabela(Id_Servidor, Id_BaseDados, Id_Tabela, Nm_Drive, 
				Nr_Tamanho_Total, Nr_Tamanho_Dados, Nr_Tamanho_Indice, Qt_Linhas, Dt_Referencia)
	select	B.Id_Servidor, D.Id_BaseDados, C.Id_Tabela ,UPPER(A.Nm_Drive),
			sum(Reserved_in_kb)/1024.00 [Reservado (KB)], 
			sum(case when Type_Desc in ('CLUSTERED', 'HEAP') then Reserved_in_kb else 0 end)/1024.00 [Dados (KB)], 
			sum(case when Type_Desc in ('NONCLUSTERED') then Reserved_in_kb else 0 end)/1024.00 [Indices (KB)],
			max(Tbl_Rows) Qtd_Linhas,
			CONVERT(VARCHAR, GETDATE(), 112)						 
	from ##Tamanho_Tabelas A
		JOIN Traces.dbo.Servidor B ON A.Nm_Servidor = B.Nm_Servidor 
		JOIN Traces.dbo.Tabela C ON A.Nm_Tabela = C.Nm_Tabela
		JOIN Traces.dbo.BaseDados D ON A.Nm_Database = D.Nm_Database
		LEFT JOIN Traces.dbo.Historico_Tamanho_Tabela E ON	B.Id_Servidor = E.Id_Servidor 
															AND D.Id_BaseDados = E.Id_BaseDados AND C.Id_Tabela = E.Id_Tabela 
															AND E.Dt_Referencia = CONVERT(VARCHAR, GETDATE() ,112)    
	where Nm_Index is not null	and Type_Desc is not NULL AND E.Id_Historico_Tamanho IS NULL 
	group by B.Id_Servidor, D.Id_BaseDados, C.Id_Tabela, UPPER(A.Nm_Drive), E.Dt_Referencia
END
GO


--------------------------------------------------------------------------------------------------------------------------------
-- Criação da tabela para Histórico de Fragmentação de Índices.
--------------------------------------------------------------------------------------------------------------------------------
if object_id('Historico_Fragmentacao_Indice') is not null
	drop table Historico_Fragmentacao_Indice

CREATE TABLE [dbo].[Historico_Fragmentacao_Indice](
	[Id_Hitorico_Fragmentacao_Indice] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Referencia] [datetime] NULL,
	[Id_Servidor] [smallint] NULL,
	[Id_BaseDados] [smallint] NULL,
	[Id_Tabela] [int] NULL,
	[Nm_Indice] [varchar](1000) NULL,
	[Nm_Schema] varchar(50),
	[Avg_Fragmentation_In_Percent] [numeric](5, 2) NULL,
	[Page_Count] [int] NULL,
	[Fill_Factor] [tinyint] NULL,
	[Fl_Compressao] [tinyint] NULL
) ON [PRIMARY]

--------------------------------------------------------------------------------------------------------------------------------
-- Criação da View que retorna a Fragmentação dos Índices.
--------------------------------------------------------------------------------------------------------------------------------
if object_id('vwHistorico_Fragmentacao_Indice') is not null
	drop View vwHistorico_Fragmentacao_Indice

GO

CREATE VIEW [dbo].[vwHistorico_Fragmentacao_Indice]
AS

select	A.Dt_Referencia, B.Nm_Servidor, C.Nm_Database, D.Nm_Tabela, A.Nm_Indice, A.Nm_Schema, 
		A.Avg_Fragmentation_In_Percent, A.Page_Count, A.Fill_Factor, A.Fl_Compressao
from Historico_Fragmentacao_Indice A
	join Servidor B on A.Id_Servidor = B.Id_Servidor
	join BaseDados C on A.Id_BaseDados = C.Id_BaseDados
	join Tabela D on A.Id_Tabela = D.Id_Tabela


GO

if object_id('stpCarga_Fragmentacao_Indice') is not null
	drop procedure stpCarga_Fragmentacao_Indice
	
GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criação da procedure que realiza a carga da Fragmentação dos Índices.
--------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[stpCarga_Fragmentacao_Indice]
AS
BEGIN
	SET NOCOUNT ON	 
		
	IF object_id('tempdb..##Historico_Fragmentacao_Indice') IS NOT NULL DROP TABLE ##Historico_Fragmentacao_Indice
	
	CREATE TABLE ##Historico_Fragmentacao_Indice(
		[Id_Hitorico_Fragmentacao_Indice] [int] IDENTITY(1,1) NOT NULL,
		[Dt_Referencia] [datetime] NULL,
		[Nm_Servidor] VARCHAR(50) NULL,
		[Nm_Database] VARCHAR(100) NULL,
		[Nm_Tabela] VARCHAR(1000) NULL,
		[Nm_Indice] [varchar](1000) NULL,
		[Nm_Schema] varchar(50),
		[Avg_Fragmentation_In_Percent] [numeric](5, 2) NULL,
		[Page_Count] [int] NULL,
		[Fill_Factor] [tinyint] NULL,
		[Fl_Compressao] [tinyint] NULL
	) ON [PRIMARY]
 
	EXEC sp_MSforeachdb 'Use [?]; 
	declare @Id_Database int 
	set @Id_Database = db_id()
	
	insert into ##Historico_Fragmentacao_Indice
	select	getdate(), @@servername Nm_Servidor,  DB_NAME(db_id()) Nm_Database, D.Name Nm_Tabela, B.Name Nm_Indice, 
			F.name Nm_Schema, avg_fragmentation_in_percent, page_Count, fill_factor, data_compression	
	from sys.dm_db_index_physical_stats(@Id_Database,null,null,null,null) A
		join sys.indexes B on A.object_id = B.Object_id and A.index_id = B.index_id
        JOIN sys.partitions C ON C.object_id = B.object_id AND C.index_id = B.index_id
        JOIN sys.sysobjects D ON A.object_id = D.id
        join sys.objects E on D.id = E.object_id
        join  sys.schemas F on E.schema_id = F.schema_id
    '
          
    DELETE FROM ##Historico_Fragmentacao_Indice
    WHERE Nm_Database IN ('master', 'msdb', 'tempdb')
    
    INSERT INTO Traces.dbo.Servidor(Nm_Servidor)
	SELECT DISTINCT A.Nm_Servidor 
	FROM ##Historico_Fragmentacao_Indice A
		LEFT JOIN Traces.dbo.Servidor B ON A.Nm_Servidor = B.Nm_Servidor
	WHERE B.Nm_Servidor IS null
		
	INSERT INTO Traces.dbo.BaseDados(Nm_Database)
	SELECT DISTINCT A.Nm_Database 
	FROM ##Historico_Fragmentacao_Indice A
		LEFT JOIN Traces.dbo.BaseDados B ON A.Nm_Database = B.Nm_Database
	WHERE B.Nm_Database IS null
	
	INSERT INTO Traces.dbo.Tabela(Nm_Tabela)
	SELECT DISTINCT A.Nm_Tabela 
	FROM ##Historico_Fragmentacao_Indice A
		LEFT JOIN Traces.dbo.Tabela B ON A.Nm_Tabela = B.Nm_Tabela
	WHERE B.Nm_Tabela IS null	
	
    INSERT INTO Traces..Historico_Fragmentacao_Indice(	Dt_Referencia, Id_Servidor, Id_BaseDados, Id_Tabela, Nm_Indice, Nm_Schema,
														Avg_Fragmentation_In_Percent, Page_Count, Fill_Factor, Fl_Compressao)	
    SELECT	A.Dt_Referencia, E.Id_Servidor, D.Id_BaseDados, C.Id_Tabela, A.Nm_Indice, A.Nm_Schema,
			A.Avg_Fragmentation_In_Percent, A.Page_Count, A.Fill_Factor, A.Fl_Compressao 
    FROM ##Historico_Fragmentacao_Indice A 
    	JOIN Traces.dbo.Tabela C ON A.Nm_Tabela = C.Nm_Tabela
		JOIN Traces.dbo.BaseDados D ON A.Nm_Database = D.Nm_Database
		JOIN Traces.dbo.Servidor E ON A.Nm_Servidor = E.Nm_Servidor 
    	LEFT JOIN Historico_Fragmentacao_Indice B ON	E.Id_Servidor = B.Id_Servidor AND D.Id_BaseDados = B.Id_BaseDados  
    													AND C.Id_Tabela = B.Id_Tabela AND A.Nm_Indice = B.Nm_Indice 
    													AND CONVERT(VARCHAR, A.Dt_Referencia ,112) = CONVERT(VARCHAR, B.Dt_Referencia ,112)
	WHERE A.Nm_Indice IS NOT NULL AND B.Id_Hitorico_Fragmentacao_Indice IS NULL
    ORDER BY 2, 3, 4, 5        			
END
GO


--------------------------------------------------------------------------------------------------------------------------------
-- Criação das tabelas dos Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
if object_id('Historico_Waits_Stats') is not null
	drop table Historico_Waits_Stats
	
GO

CREATE TABLE [dbo].[Historico_Waits_Stats](
	[Id_Historico_Waits_Stats] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Referencia] [datetime] NULL default(getdate()),
	[WaitType] [varchar](60) NOT NULL,
	[Wait_S] [decimal](14, 2) NULL,
	[Resource_S] [decimal](14, 2) NULL,
	[Signal_S] [decimal](14, 2) NULL,
	[WaitCount] [bigint]  NULL,
	[Percentage] [decimal](4, 2) NULL,
	[Id_Coleta] int
) ON [PRIMARY]

GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criação da procedure que realiza a carga dos Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
if object_id('stpCarga_Historico_Waits_Stats') is not null
	drop procedure stpCarga_Historico_Waits_Stats
	
GO

CREATE PROCEDURE [dbo].[stpCarga_Historico_Waits_Stats]
AS
BEGIN
	-- Seleciona o último wait por WaitType.
	declare @Waits_Before table (WaitType varchar(60), WaitCount bigint, Id_Coleta int)
	declare @Id_Coleta int

	-- Seleciona o Id_Coleta da última coleta de dados.
	select @Id_Coleta = Id_Coleta
	from Historico_Waits_Stats A
		join	(
					select max(Id_Historico_Waits_Stats) AS Id_Historico_Waits_Stats
					from Historico_Waits_Stats
				) B on A.Id_Historico_Waits_Stats = B.Id_Historico_Waits_Stats

	insert into @Waits_Before
	select A.WaitType, A.WaitCount, A.Id_Coleta
	from Historico_Waits_Stats A
		join	(
					select [WaitType], max(Id_Historico_Waits_Stats) Id_Historico_Waits_Stats
					from Historico_Waits_Stats
					group by [WaitType] 
				) B on A.Id_Historico_Waits_Stats = B.Id_Historico_Waits_Stats
			
	;WITH Waits AS
		(
			SELECT
				wait_type,
				wait_time_ms / 1000.0 AS WaitS,
				(wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
				signal_wait_time_ms / 1000.0 AS SignalS,
				waiting_tasks_count AS WaitCount,
				100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
				ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
			FROM sys.dm_os_wait_stats
			WHERE wait_type NOT IN (
				'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 
				'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH', 'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT',
				'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 
				'BROKER_EVENTHANDLER', 'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'BROKER_RECEIVE_WAITFOR', 
				'DBMIRROR_EVENTS_QUEUE', 'DBMIRRORING_CMD', 'BROKER_TRANSMITTER', 'SQLTRACE_WAIT_ENTRIES', 'SLEEP_BPOOL_FLUSH', 'SQLTRACE_LOCK', 
				'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', 'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
				'DIRTY_PAGE_POLL', 'SP_SERVER_DIAGNOSTICS_SLEEP', 'ONDEMAND_TASK_QUEUE','LOGMGR_QUEUE')
		)
			
	INSERT INTO Historico_Waits_Stats(WaitType,Wait_S,Resource_S,Signal_S,WaitCount,Percentage,Id_Coleta)
	SELECT
		W1.wait_type AS WaitType, 
		CAST (W1.WaitS AS DECIMAL(14, 2)) AS Wait_S,
		CAST (W1.ResourceS AS DECIMAL(14, 2)) AS Resource_S,
		CAST (W1.SignalS AS DECIMAL(14, 2)) AS Signal_S,
		W1.WaitCount AS WaitCount,
		CAST (W1.Percentage AS DECIMAL(4, 2)) AS Percentage, isnull(@Id_Coleta,0) + 1
		--CAST ((W1.WaitS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgWait_S,
	   -- CAST ((W1.ResourceS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgRes_S,
		--CAST ((W1.SignalS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgSig_S
	FROM Waits AS W1
		INNER JOIN Waits AS W2 ON W2.RowNum <= W1.RowNum
	GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
	HAVING SUM (W2.Percentage) - W1.Percentage < 95 -- percentage threshold
	OPTION (RECOMPILE); 

	-- Verifica se o valor Wait_S diminuiu para algum WaitType.
	if exists	(
					select null
					from Historico_Waits_Stats A
					join	(	
								select [WaitType], max(Id_Historico_Waits_Stats) Id_Historico_Waits_Stats
								from Historico_Waits_Stats
								group by [WaitType] 
							) B on A.Id_Historico_Waits_Stats = B.Id_Historico_Waits_Stats
					join @Waits_Before C on A.WaitType = C.WaitType and A.WaitCount < C.WaitCount 
											and isnull(A.Id_Coleta,0)  = isnull(C.Id_Coleta,0) + 1 
				)
	BEGIN
		INSERT INTO Historico_Waits_Stats(WaitType)
		values('RESET WAITS STATS')
	END
END
GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criação da procedure que retorna o historico dos Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
if object_id('stpHistorico_Waits_Stats') is not null
	drop procedure stpHistorico_Waits_Stats
GO
CREATE procedure [dbo].[stpHistorico_Waits_Stats] @Dt_Inicial datetime, @Dt_Final datetime
AS
BEGIN
	--declare @Dt_Inicial datetime, @Dt_Final datetime
	--select @Dt_Inicial = '20110505 12:00',@Dt_Final = '20110505 13:00'
	 
	declare @Wait_Stats table(WaitType varchar(60), Min_Id int, Max_Id int, Menor_Data datetime)
	 
	insert into @Wait_Stats(WaitType, Min_Id,Max_Id, Menor_Data)
	select WaitType, min(Id_Historico_Waits_Stats) AS Min_Id, max(Id_Historico_Waits_Stats) AS Max_Id, min(Dt_Referencia) AS Menor_Data
	from Historico_Waits_Stats (nolock)
	where Dt_Referencia >= @Dt_Inicial and Dt_Referencia < @Dt_Final
	group by WaitType
	 
	-- Tratamento de erro simples para o caso de uma limpeza das estatísticas
	if exists (select null from @Wait_Stats where WaitType = 'RESET WAITS STATS')
	begin
		select	'Foi realizada uma limpeza dos WaitStats' AS WaitType, getdate() AS Min_Log, getdate() AS Max_Log, 0 AS DIf_Wait_S,
				0 AS DIf_Resource_S, 0 AS DIf_Signal_S, 0 AS DIf_WaitCount, 0 AS DIf_Percentage, 0 AS Last_Percentage
			
		/*
		select 'Houve uma limpeza das Waits Stats após a coleta do dia: ' + cast(Menor_Data as varchar) +
		' | Favor alterar o período para que não inclua essa limpeza.'
		from @Wait_Stats where WaitType = 'RESET WAITS STATS'
		*/
		 
		return
	End

	-- Procurar o menor id depois da última limpeza antes do intervalo final e utilizar
	--tratar caso da limpeza da estatistica
	select	A.WaitType, B.Dt_Referencia Min_Log, C.Dt_Referencia Max_Log, C.Wait_S - B.Wait_S DIf_Wait_S,
			C.Resource_S - B.Resource_S DIf_Resource_S, C.Signal_S - B.Signal_S DIf_Signal_S, C.WaitCount - B.WaitCount DIf_WaitCount,
			C.Percentage - B.Percentage DIf_Percentage, B.Percentage Last_Percentage
	from @Wait_Stats A
		join Historico_Waits_Stats B on A.Min_Id = B.Id_Historico_Waits_Stats -- Primeiro
		join Historico_Waits_Stats C on A.Max_Id = C.Id_Historico_Waits_Stats -- Último 
END

GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criação de índice para o Historico dos Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
use Traces

CREATE NONCLUSTERED INDEX [SK01_Historico_Waits_Stats] ON [Traces].[dbo].[Historico_Waits_Stats] ([Id_Historico_Waits_Stats]) 
INCLUDE ([WaitType], [WaitCount], [Id_Coleta]) with(fillfactor = 95)

GO


/*******************************************************************************************************************************
-- Criação dos JOBs para realizar a carga dos dados.
*******************************************************************************************************************************/
USE MSDB

GO

--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Carga Fragmentacao Indices.
--------------------------------------------------------------------------------------------------------------------------------

GO

-- Se o job já existe, exclui para criar novamente.
IF EXISTS (	SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Carga Fragmentacao Indices')
	EXEC msdb.dbo.sp_delete_job @job_name = N'DBA - Carga Fragmentacao Indices', @delete_unused_schedule=1

GO

BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Seleciona a Categoria do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'Database Maintenance' AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job 
			@job_name = N'DBA - Carga Fragmentacao Indices', 
			@enabled = 1, 
			@notify_level_eventlog = 0, 
			@notify_level_email = 0, 
			@notify_level_netsend = 0, 
			@notify_level_page = 0, 
			@delete_level = 0, 
			@description = N'No description available.', 
			@category_name = N'Database Maintenance', 
			@owner_login_name = N'sa', 
			@job_id = @jobId OUTPUT
		
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Step 1 do JOB - Carga Fragmentacao Indices
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'DBA - Carga Fragmentacao Indices', 
			@step_id = 1, 
			@cmdexec_success_code = 0, 
			@on_success_action = 1, 
			@on_success_step_id = 0, 
			@on_fail_action = 2, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'exec stpCarga_Fragmentacao_Indice', 
			@database_name = N'Traces', 
			@flags = 0
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Schedule do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'Carga Fragmentação de Indices', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 1, 
			@freq_subday_interval = 0, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual, 
			@active_end_date = 99991231, 
			@active_start_time = 3000, 
			@active_end_time = 235959
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    
EndSave:

GO

--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Carga Tamanho Tabelas.
--------------------------------------------------------------------------------------------------------------------------------
-- Se o job já existe, exclui para criar novamente.
IF EXISTS (	SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Carga Tamanho Tabelas')
	EXEC msdb.dbo.sp_delete_job @job_name = N'DBA - Carga Tamanho Tabelas', @delete_unused_schedule = 1

USE [msdb]

GO

BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Seleciona a Categoria do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'Database Maintenance' AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job 
			@job_name = N'DBA - Carga Tamanho Tabelas', 
			@enabled = 1, 
			@notify_level_eventlog = 0, 
			@notify_level_email = 0, 
			@notify_level_netsend = 0, 
			@notify_level_page = 0, 
			@delete_level = 0, 
			@description = N'No description available.', 
			@category_name = N'Database Maintenance', 
			@owner_login_name = N'sa', 
			@job_id = @jobId OUTPUT
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Step 1 do JOB - Carga Tamanho Tabelas
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId, 
			@step_name = N'DBA - Carga Tamanho Tabelas', 
			@step_id = 1, 
			@cmdexec_success_code = 0, 
			@on_success_action = 1, 
			@on_success_step_id = 0, 
			@on_fail_action = 2, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'exec stpTamanhos_Tabelas', 
			@database_name = N'Traces', 
			@flags = 0
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Schedule do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'Carga Tamanho Tabela', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 1, 
			@freq_subday_interval = 0, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual, 
			@active_end_date = 99991231, 
			@active_start_time = 1000, 
			@active_end_time = 235959
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    
EndSave:

GO


--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Carga Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
USE [msdb]
GO

-- Se o job já existe, exclui para criar novamente.
IF EXISTS (SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Carga Wait Stats')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Carga Wait Stats'  , @delete_unused_schedule=1

GO

BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Seleciona a Categoria do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'Database Maintenance' AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job 
			@job_name = N'DBA - Carga Wait Stats', 
			@enabled = 1, 
			@notify_level_eventlog = 0, 
			@notify_level_email = 0, 
			@notify_level_netsend = 0, 
			@notify_level_page = 0, 
			@delete_level = 0, 
			@description = N'No description available.', 
			@category_name = N'Database Maintenance', 
			@owner_login_name = N'sa', 
			@job_id = @jobId OUTPUT
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Step 1 do JOB - Carga Wait Stats
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'DBA - Carga Wait Stats', 
			@step_id = 1, 
			@cmdexec_success_code = 0, 
			@on_success_action = 1, 
			@on_success_step_id = 0, 
			@on_fail_action = 2, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'exec stpCarga_Historico_Waits_Stats', 
			@database_name = N'Traces', 
			@flags = 0
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Schedule do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)

	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'Histórico Wait', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 4, 
			@freq_subday_interval = 30, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual, 
			@active_end_date = 99991231, 
			@active_start_time = 707, 
			@active_end_time = 235959
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    
EndSave:

GO


--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Carga Contadores SQL Server.
--------------------------------------------------------------------------------------------------------------------------------
-- Se o job já existe, exclui para criar novamente.
IF EXISTS (SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Carga Contadores SQL Server')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Carga Contadores SQL Server'  , @delete_unused_schedule=1

USE [msdb]

GO

BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Seleciona a Categoria do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'Database Maintenance' AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job 
			@job_name = N'DBA - Carga Contadores SQL Server', 
			@enabled = 1, 
			@notify_level_eventlog = 0, 
			@notify_level_email = 0, 
			@notify_level_netsend = 0, 
			@notify_level_page = 0, 
			@delete_level = 0, 
			@description = N'No description available.', 
			@category_name = N'Database Maintenance', 
			@owner_login_name = N'sa', 
			@job_id = @jobId OUTPUT
		
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Step 1 do JOB - Carga Contadores
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'DBA - Carga Contadores', 
			@step_id = 1, 
			@cmdexec_success_code = 0, 
			@on_success_action = 1, 
			@on_success_step_id = 0, 
			@on_fail_action = 2, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0,
			@subsystem = N'TSQL', 
			@command = N'exec stpCarga_ContadoresSQL', 
			@database_name = N'Traces', 
			@flags=0
		
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Schedule do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'Contadores SQL', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 4, 
			@freq_subday_interval = 1, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual,
			@active_end_date = 99991231, 
			@active_start_time = 32, 
			@active_end_time = 235959
		
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    
EndSave:

GO

use Traces

GO

/*******************************************************************************************************************************
--	Utilização Arquivo
*******************************************************************************************************************************/

--------------------------------------------------------------------------------------------------------------------------------
-- Cria Tabela de Historico
--------------------------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID('[dbo].[Historico_Utilizacao_Arquivo]') IS NOT NULL)
	DROP TABLE [dbo].[Historico_Utilizacao_Arquivo]

CREATE TABLE [dbo].[Historico_Utilizacao_Arquivo] (
	[Nm_Database] [nvarchar](128) NULL,
	[file_id] [smallint] NOT NULL,
	[io_stall_read_ms] [bigint] NOT NULL,
	[num_of_reads] [bigint] NOT NULL,
	[avg_read_stall_ms] [numeric](10, 1) NULL,
	[io_stall_write_ms] [bigint] NOT NULL,
	[num_of_writes] [bigint] NOT NULL,
	[avg_write_stall_ms] [numeric](10, 1) NULL,
	[io_stalls] [bigint] NULL,
	[total_io] [bigint] NULL,
	[avg_io_stall_ms] [numeric](10, 1) NULL,
	[Dt_Registro] [datetime] NOT NULL
) ON [PRIMARY]

GO

--------------------------------------------------------------------------------------------------------------------------------
-- Cria Procedure para fazer a carga na tabela
--------------------------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID('[dbo].[stpCarga_Historico_Utilizacao_Arquivo]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCarga_Historico_Utilizacao_Arquivo]
GO

CREATE PROCEDURE [dbo].[stpCarga_Historico_Utilizacao_Arquivo]
AS
BEGIN
	INSERT INTO Traces.dbo.Historico_Utilizacao_Arquivo
	SELECT DB_NAME(database_id) AS [Database Name]
			, file_id 
			, io_stall_read_ms
			, num_of_reads
			, CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms]
			, io_stall_write_ms
			, num_of_writes
			, CAST(io_stall_write_ms/(1.0+num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms]
			, io_stall_read_ms + io_stall_write_ms AS [io_stalls]
			, num_of_reads + num_of_writes AS [total_io]
			, CAST((io_stall_read_ms + io_stall_write_ms)/(1.0 + num_of_reads + num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms]
			, GETDATE() as [Dt_Registro]
	FROM sys.dm_io_virtual_file_stats(null,null)
END
GO

--------------------------------------------------------------------------------------------------------------------------------
-- Cria o JOB
--------------------------------------------------------------------------------------------------------------------------------
USE [msdb]
GO

/****** Object:  Job [DBA - Carga Historico Utilização Arquivo]    Script Date: 02/15/2017 10:47:42 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 02/15/2017 10:47:42 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Carga Historico Utilização Arquivo', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Nenhuma descrição disponível.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'Alerta_BD', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Carga Utilização Arquivo]    Script Date: 02/15/2017 10:47:48 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Carga Utilização Arquivo', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[stpCarga_Historico_Utilizacao_Arquivo]', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DIARIO - A CADA 30 MINUTOS', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=126, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20161110, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'cd176e16-94e3-4911-9fb8-937d0c07a6e0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO