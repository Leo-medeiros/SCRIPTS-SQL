/*******************************************************************************************************************************
(C) 2016, Fabricio Lima Soluções em Banco de Dados

Site: http://www.fabriciolima.net/

Feedback: contato@fabriciolima.net
*******************************************************************************************************************************/

/*******************************************************************************************************************************

--	Criação das rotinas do Mirror que serão utilizadas para gerar o relatório do CheckList em HTML

--	INSTRUÇÕES DE USO: 

------------------------------------------------------------------------------------------------------------------------------------
--	PASSO 1:
------------------------------------------------------------------------------------------------------------------------------------
--	Alterar o PROFILE e o E-MAIL para os necessários:

		@profile_name = 'MSSQLServer',
		@recipients = 'fabricioflima@gmail.com', 

------------------------------------------------------------------------------------------------------------------------------------
--	PASSO 2:
------------------------------------------------------------------------------------------------------------------------------------
--	Apenas executar os scripts e conferir as tabelas e procedures criadas na database desejada.

*******************************************************************************************************************************/

USE Traces

--------------------------------------------------------------------------------------------------------------------------------
-- CRIA A TABELA E ROTINA PARA CARREGAR OS DADOS DO MIRROR
--------------------------------------------------------------------------------------------------------------------------------

GO
if OBJECT_ID('Historico_Log_DBMirror') is not null
	drop table Historico_Log_DBMirror
GO
CREATE TABLE  Historico_Log_DBMirror (
	Id_Historico_Log int identity,
	database_name   sysname,          -- Name of database
	role     tinyint,                 -- 1 = Principal, 2 = Mirror
	mirroring_state   tinyint,        -- 0 = Suspended, 1 = Disconnected, 2 = Synchronizing, 3 = Pending Failover, 4 = Synchronized
	witness_status   tinyint,         -- 1 = Connected, 2 = Disconnected
	log_generation_rate  int null,    -- Amount of log generated since preceding update of the mirroring status of this database in kb/sec
	-- Same as Perfmon Counter Log Bytes Flushed/Sec and Current rate of new transactions in Mirroring Monitor *****
	unsent_log    int,                -- Size of the unsent log in the send queue on the principal in KB (Send Queue) 
	-- Same as Log Send Queue in Perfmon and Unsent Log in Mirroring Monitor *****
	send_rate    int null,            -- Send rate of log from the principal to the mirror in kb/sec 
	-- Same as Log Bytes Sent/Sec in perfmon and Current send rate in Mirroring Monitor *****
	unrestored_log   int,             -- Size of the redo queue on the mirror in kb(Redo Queue)
	-- Same as Redo Queue KB in perfmon and Unrestored log in Mirroring Monitor. ******
	recovery_rate   int null,         -- Redo rate on the mirror in kb/sec
	-- Same as Redo Bytes/Sec in Perfmon and Current Restore rate in Mirroring Monitor *********
	transaction_delay  int null,      -- Total delay for all transactions in ms
	-- Same as perfmon counter Transaction Delay.
	transactions_per_sec int null,    -- Number of transactions that are occurring per second on the principal server instance in trans / sec
	-- Same as perfmon counter Transaction/Sec
	average_delay   int,              -- Average delay on the principal server instance for each transaction because of database mirroring.
	-- In high-performance mode, this value is generally 0 in ms and same asMirror Commit Overhead in Mirroring Monitor *****
	--time_recorded   datetime,         -- Time at which the row was recorded by the database mirroring monitor. This is the system clock time of the principal in GMT 
	--time_behind    datetime,          -- Approximate system-clock time of the principal to which the mirror database is currently caught up.
	-- This value is meaningful only on the principal server instance in GMT
	local_time    datetime   not null ,        -- System clock time on the local server instance when this row was updated
	Fl_Operation_Mode tinyint,
	constraint PK_Historico_Log_DBMirror primary key (Id_Historico_Log)
)
  
create unique nonclustered  index SK01_Historico_Log_DBMirror on Historico_Log_DBMirror(local_time, database_name)

GO

if OBJECT_ID('stpCarga_Log_DBMirror_Geral') is not null
	drop procedure stpCarga_Log_DBMirror_Geral
GO
/****** Object:  StoredProcedure [dbo].[stpCarga_Log_DBMirror]    Script Date: 5/16/2015 1:19:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEMPLO EXECUÇÃO
-- [stpCarga_Log_DBMirror_Geral] 4

CREATE procedure [dbo].[stpCarga_Log_DBMirror_Geral]  @mode tinyint
AS
BEGIN
	SET NOCOUNT ON 
	
	declare @database_name varchar(50)
	
	declare @DATABASES table(database_name varchar(50))

	insert into @DATABASES(database_name)
	SELECT  name
    FROM    sys.databases d
            LEFT OUTER JOIN sys.database_mirroring m ON m.database_id = d.database_id
    WHERE   mirroring_role_desc IS NOT NULL

	while exists(select null from @DATABASES)
	begin

	select top 1 @database_name = database_name
	from @DATABASES

		if OBJECT_ID('tempdb..#Log_DBMirror') is not null
			drop table #Log_DBMirror
		
		CREATE TABLE  #Log_DBMirror(
		 database_name   sysname,          -- Name of database
		 role     tinyint,                 -- 1 = Principal, 2 = Mirror
		 mirroring_state   tinyint,        -- 0 = Suspended, 1 = Disconnected, 2 = Synchronizing, 3 = Pending Failover, 4 = Synchronized
		 witness_status   tinyint,         -- 1 = Connected, 2 = Disconnected
		 log_generation_rate  int null,    -- Amount of log generated since preceding update of the mirroring status of this database in kb/sec
		 -- Same as Perfmon Counter Log Bytes Flushed/Sec and Current rate of new transactions in Mirroring Monitor *****
		 unsent_log    int,                -- Size of the unsent log in the send queue on the principal in KB (Send Queue) 
		 -- Same as Log Send Queue in Perfmon and Unsent Log in Mirroring Monitor *****
		 send_rate    int null,            -- Send rate of log from the principal to the mirror in kb/sec 
		 -- Same as Log Bytes Sent/Sec in perfmon and Current send rate in Mirroring Monitor *****
		 unrestored_log   int,             -- Size of the redo queue on the mirror in kb(Redo Queue)
		 -- Same as Redo Queue KB in perfmon and Unrestored log in Mirroring Monitor. ******
		 recovery_rate   int null,         -- Redo rate on the mirror in kb/sec
		 -- Same as Redo Bytes/Sec in Perfmon and Current Restore rate in Mirroring Monitor *********
		 transaction_delay  int null,      -- Total delay for all transactions in ms
		 -- Same as perfmon counter Transaction Delay.
		 transactions_per_sec int null,    -- Number of transactions that are occurring per second on the principal server instance in trans / sec
		 -- Same as perfmon counter Transaction/Sec
		 average_delay   int,              -- Average delay on the principal server instance for each transaction because of database mirroring.
		 -- In high-performance mode, this value is generally 0 in ms and same asMirror Commit Overhead in Mirroring Monitor *****
		 time_recorded   datetime,         -- Time at which the row was recorded by the database mirroring monitor. This is the system clock time of the principal in GMT 
		 time_behind    datetime,          -- Approximate system-clock time of the principal to which the mirror database is currently caught up.
		 -- This value is meaningful only on the principal server instance in GMT
		 local_time    datetime            -- System clock time on the local server instance when this row was updated
		  )
		--Somente para fazer a atualizacao da procedure, pois nao e possivel fazer isso no insert 
		exec msdb.dbo.sp_dbmmonitorresults @database_name , @mode, @update_table = 1
	
		insert into #Log_DBMirror
		exec msdb.dbo.sp_dbmmonitorresults @database_name , @mode, @update_table = 0

	/*
		-- Elimina informacoes duplicadas (Database e local_time)	
		insert into Historico_Log_DBMirror(database_name, role, mirroring_state, witness_status, log_generation_rate, unsent_log, send_rate, unrestored_log, recovery_rate, transaction_delay, transactions_per_sec, average_delay, local_time)
		select distinct A.database_name, A.role, A.mirroring_state, A.witness_status, A.log_generation_rate, A.unsent_log, A.send_rate, A.unrestored_log, A.recovery_rate, A.transaction_delay, A.transactions_per_sec, A.average_delay, A.local_time
		from #Log_DBMirror A
			left join Historico_Log_DBMirror B on A.local_time = B.local_time and A.database_name = B.database_name
		where B.local_time is null and A.recovery_rate is not null
	*/
		DECLARE @Fl_Operation_mode TINYINT
	
		-- Para logar o Operation mode Atual do Database Mirroring
		SELECT @Fl_Operation_mode = 
			 CASE WHEN mirroring_safety_level_desc = 'FULL' AND mirroring_witness_state_desc <> 'UNKNOWN' THEN 3
				 WHEN mirroring_safety_level_desc = 'FULL' AND mirroring_witness_state_desc = 'UNKNOWN' THEN 2
				 WHEN mirroring_safety_level_desc = 'OFF' THEN 1 end
		FROM sys.database_mirroring m 
			JOIN sys.databases db ON db.database_id = m.database_id
		where name = @database_name 
	
		-- Elimina informacoes duplicadas (Database e local_time). As vezes vem local_time igual e recovery_rate diferentes
		insert into Historico_Log_DBMirror(database_name, role, mirroring_state, witness_status, log_generation_rate, unsent_log, send_rate, unrestored_log, 
			recovery_rate, transaction_delay, transactions_per_sec, average_delay, local_time,Fl_Operation_mode)
		select distinct A.database_name, A.role, A.mirroring_state, A.witness_status, max(isnull(A.log_generation_rate,0)), 
				max(isnull(A.unsent_log,0)), max(isnull(A.send_rate,0)), max(isnull(A.unrestored_log,0)), max(isnull(A.recovery_rate,0)), 
				max(isnull(A.transaction_delay,0)), max(isnull(A.transactions_per_sec,0)), max(isnull(A.average_delay,0)), A.local_time,ISNULL(@Fl_Operation_mode,0)
		from #Log_DBMirror A
			left join Historico_Log_DBMirror B on A.local_time = B.local_time and A.database_name = B.database_name 
		where B.local_time is null 
		group by A.database_name, A.role, A.mirroring_state, A.witness_status,A.local_Time

		delete from @DATABASES 
		where database_name = @database_name 
	
	end
END
GO

--------------------------------------------------------------------------------------------------------------------------------
-- CRIA O ALERTA DO MIRROR
--------------------------------------------------------------------------------------------------------------------------------

GO
if OBJECT_ID('stpAlerta_Status_DBMirror_Geral') is not null
	drop procedure stpAlerta_Status_DBMirror_Geral
GO

CREATE procedure [dbo].[stpAlerta_Status_DBMirror_Geral] --@database_name varchar (50)
AS
BEGIN	
	declare @Ultimo_Registro as table(database_name varchar(100),Id_Historico_Log int)
	
	insert into @Ultimo_Registro
	select A.database_name, max(A.Id_Historico_Log) Id_Historico_Log
	from Historico_Log_DBMirror A (nolock) 					
	group by A.database_name	
	
	declare @Penultimo_Registro as table(database_name varchar(100),Id_Historico_Log int)
	
	insert into @Penultimo_Registro
	select A.database_name, max(A.Id_Historico_Log) Id_Historico_Log
	from Historico_Log_DBMirror A (nolock) 	
		left join @Ultimo_Registro B on A.Id_Historico_Log = B.Id_Historico_Log
	where B.Id_Historico_Log is null		
	group by A.database_name	
	
	if exists (
	select null
	from (	select E.* 
			from Historico_Log_DBMirror E
			join @Penultimo_Registro F on E.Id_Historico_Log = F.Id_Historico_Log
			) A
		join (	select C.* 
				from Historico_Log_DBMirror C
					join @Ultimo_Registro D on C.Id_Historico_Log = D.Id_Historico_Log		) 
			B on A.database_name = B.database_name 			
	where A.role <> B.role 
		or A.mirroring_state <> B.mirroring_state 
		or A.witness_status <> B.witness_status 
	--OR ISNULL(A.Fl_Operation_Mode,0) <>  ISNULL(B.Fl_Operation_Mode,0) 		
	--order by B.database_name
	)
	begin	
		
		/**************************************************************
					Header
		***************************************************************/

		DECLARE @MirrorHeader VARCHAR(MAX)
		SET @MirrorHeader='<font 
					color=black bold=true size= 5>'
		            
		SET @MirrorHeader=@MirrorHeader+'<BR /> Situação das Databases do Mirror<BR />' 
		SET @MirrorHeader=@MirrorHeader+'</font>'

		/**************************************************************
					Espaço em disco - Informações
		***************************************************************/

		DECLARE @MirrorTable VARCHAR(MAX)    
		SET @MirrorTable= cast( (    
		SELECT td =  database_name + 
				'</td><td> ' + Fl_Operation_Mode + 
				'</td><td>'+  ROLE_Mirror + 
				'</td><td>'  + mirroring_state + 
				'</td><td>'  + witness_status + 
				'</td><td>'  + Horario+ '</td>' 

		FROM (           
				select B.database_name database_name,
				CASE ISNULL(B.Fl_Operation_Mode ,0)
					WHEN 0 THEN 'Não configurado'
					WHEN 1 THEN 'HP Sem Failover'
					WHEN 2 THEN 'HS Sem Failover'
					WHEN 3 THEN 'HS Com Failover'
				END Fl_Operation_Mode,	
					case B.role when 1 then 'Principal' when 2 then 'Mirror' end ROLE_Mirror,
						case B.mirroring_state 
						when 0 then 'Suspended'
						when 1 then 'Disconnected'
						when 2 then 'Synchronizing'
						when 3 then 'Pending Failover'
						when 4 then 'Synchronized' end mirroring_state,
						
					case B.witness_status when 0 then 'UnKnown' when 1 then 'Connected' when 2 then 'Disconnecteed' end witness_status,
					convert(varchar,B.local_time,20) Horario
				from (select C.* 
					from Historico_Log_DBMirror C
						join @Ultimo_Registro D on C.Id_Historico_Log = D.Id_Historico_Log)	B 		
			
		
		
			  ) as d order by database_name
		  FOR XML PATH( 'tr' ), Type ) AS VARCHAR(MAX) )   
		      
			SET @MirrorTable = REPLACE( replace( replace( @MirrorTable, '&lt;', '<' ), '&gt;', '>' )    , '<td>', '<td align = center>')
		    
		  SET @MirrorTable= '<table cellpadding="0" cellspacing="0" border="3" >'    
					  + '<tr>
					  <th bgcolor=#0B0B61 width="200">Database</th>
					  <th bgcolor=#0B0B61 width="150">Operation Mode</th>
					  <th bgcolor=#0B0B61 width="150">Role</th>
					  <th bgcolor=#0B0B61 width="150">Status</th>
					  <th bgcolor=#0B0B61 width="150">Status Witness</th> 
					  <th bgcolor=#0B0B61 width="150">Horario</th>
						</tr>'    
					  + replace( replace( @MirrorTable, '&lt;', '<' ), '&gt;', '>' )   
					  + '</table>' 
	
		/**************************************************************
			Empty Section for giving space between table and headings
		***************************************************************/

		DECLARE @emptybody2 VARCHAR(MAX)  
		SET @emptybody2=''  
		SET @emptybody2 = '<table cellpadding="5" cellspacing="5" border="0">'    
					  + 
					  '<tr>
					  <th width="500">               </th>
					  </tr>'    
					  + REPLACE( REPLACE( isnull(@emptybody2,''), '&lt;', '<' ), '&gt;', '>' )   
					  + '</table>'    

		DECLARE @subject AS VARCHAR(500)    
		DECLARE @importance as varchar(6)    
		DECLARE @EmailBody VARCHAR(MAX)
		SET @importance ='High'     
		SET @subject = 'Situação das Databases do Mirror no Servidor: ' +  @@servername
	
		SELECT @EmailBody = @MirrorHeader + @emptybody2 + @MirrorTable+@emptybody2
	
		EXEC msdb.dbo.sp_send_dbmail    
			@profile_name = 'MSSQLServer',
			@recipients = 'fabricioflima@gmail.com',
			@subject = @subject ,    
			@body = @EmailBody ,    
			@body_format = 'HTML' ,    
			@importance=@importance    
	END
END
GO

--------------------------------------------------------------------------------------------------------------------------------
-- CRIA A TABELA E ROTINA DO MIRROR NO CHECKLIST
--------------------------------------------------------------------------------------------------------------------------------
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
GO

--------------------------------------------------------------------------------------------------------------------------------
-- CRIA O JOB QUE FAZ A CARGA DOS DADOS DO MIRROR
--------------------------------------------------------------------------------------------------------------------------------
GO
USE [msdb]
GO

/****** Object:  Job [DBA - Carga e Alerta Mirror]    Script Date: 05/10/2014 21:53:09 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 05/10/2014 21:53:09 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Carga e Alerta Mirror', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Nenhuma descrição disponível.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA - Carga e Alerta Mirror]    Script Date: 05/10/2014 21:53:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA - Carga e Alerta Mirror', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
exec stpCarga_Log_DBMirror_Geral 4

exec stpAlerta_Status_DBMirror_Geral

', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA - Carga e Alerta Mirror', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140510, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO