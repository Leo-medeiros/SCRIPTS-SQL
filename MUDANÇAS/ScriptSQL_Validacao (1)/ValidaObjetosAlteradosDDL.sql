

-- valida scripts DDL na base de dados da tarefa --

select SERVERPROPERTY('ServerName') as server_name,DB_NAME() as database_name,
name as object_name, type_desc, create_date, modify_date 
from sys.objects 
where modify_date >= convert(char(23), getdate(), 102)
order by modify_date

