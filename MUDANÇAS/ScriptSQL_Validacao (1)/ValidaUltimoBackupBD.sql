-- Validação do backup da base de dados
-- Definir a variável @database com o nome do banco de dados da tarefa


USE [msdb]
GO

declare @database varchar(150)
set @database = ''

select  server_name,
		isnull(convert(varchar(128),SERVERPROPERTY('InstanceName')),'') as instance,
		database_name,
		[type], 
		(select convert(varchar(20), databasepropertyex(name, 'Recovery')) 
		from master.dbo.sysdatabases where name = database_name)
		as recovery_model,
		max(backup_start_date) as backup_start_date, max(backup_finish_date) as backup_finish_date,
		getdate() as date_atual
from 	msdb.dbo.backupset with (NOLOCK)
group by server_name, database_name, [type]
having 	max(backup_start_date) between DATEADD(day, -30,GETDATE()) and GETDATE()
and type in ('D','I', 'L') 
and database_name = @database
order by  server_name, database_name, max(backup_start_date) desc, type asc
go

