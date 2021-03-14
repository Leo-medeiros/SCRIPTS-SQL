
-- Verificação do estado online das bases de dados da tarefa -- 

USE [master]
GO

select serverproperty('ServerName') as ServerName, database_id, name, compatibility_level, collation_name, 
create_date,state_desc, user_access_desc, GETDATE() as DataAtu  from sys.databases
order by name
