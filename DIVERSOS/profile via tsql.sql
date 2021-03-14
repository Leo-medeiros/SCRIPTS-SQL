-- executar a proc, para validar os dados, que deseja usar no evento do trace:
--exec stp_Load_all_Events

-- executar essa proc para  pegar as colunas que deseja utilizar para cada evento do trace:
-- exec stp_Load_all_Columns

-- select exibindo o ID de cada base de dados, caso deseje criar o trace utilizando uma base de dados de filtro

--select name, database_id from sys.databases 
-- variavel para informar o ID do bacno
DECLARE @id_db INT

set @id_db = 
-- declarando as variaveis do trace
DECLARE @em INT
DECLARE @TraceID INT
DECLARE @maxFileSize BIGINT
DECLARE @filename NVARCHAR(200)

DECLARE @on BIT

-- setando os valores das variaveis, apenas as tres ultimas
SET @maxFileSize = 10
-- aqui seta o caminho para ser salvo o arquivo .trc
SET @filename = N'D:\Bancos\estudos e testes\ProfileTrace2021'
SET @on = 1

-- create trace
EXEC @em = sp_trace_create @TraceID OUTPUT,
0,
@filename,
@maxFileSize,
NULL


---- erro
IF (@em != 0) GOTO error

-- setando os eventos e dados de coluna a serem coletados
-- collect RPM: completed event and selected data columns
EXEC sp_trace_setevent @TraceID, 10, 13, @on
EXEC sp_trace_setevent @TraceID, 10, 34, @on 
EXEC sp_trace_setevent @TraceID, 10, 1, @on 
EXEC sp_trace_setevent @TraceID, 10, 18, @on 
EXEC sp_trace_setevent @TraceID, 10, 16, @on 
EXEC sp_trace_setevent @TraceID, 10, 17, @on 
EXEC sp_trace_setevent @TraceID, 10, 25, @on 
EXEC sp_trace_setevent @TraceID, 10, 35, @on 
EXEC sp_trace_setevent @TraceID, 10, 10, @on
EXEC sp_trace_setevent @TraceID, 10, 14, @on 
EXEC sp_trace_setevent @TraceID, 10, 15, @on 
EXEC sp_trace_setevent @TraceID, 10, 12, @on 
EXEC sp_trace_setevent @TraceID, 10, 11, @on 
EXEC sp_trace_setevent @TraceID, 10, 51, @on 
EXEC sp_trace_setevent @TraceID, 10, 2, @on 
--Collect SP:StmtCompleted Event and Selected Data Columns
EXEC sp_trace_setevent @TraceID, 43, 13, @on 
EXEC sp_trace_setevent @TraceID, 43, 34, @on 
EXEC sp_trace_setevent @TraceID, 43, 1, @on 
EXEC sp_trace_setevent @TraceID, 43, 18, @on 
EXEC sp_trace_setevent @TraceID, 43, 16, @on 
EXEC sp_trace_setevent @TraceID, 43, 17, @on 
EXEC sp_trace_setevent @TraceID, 43, 25, @on 
EXEC sp_trace_setevent @TraceID, 43, 35, @on 
EXEC sp_trace_setevent @TraceID, 43, 10, @on 
EXEC sp_trace_setevent @TraceID, 43, 14, @on 
EXEC sp_trace_setevent @TraceID, 43, 15, @on 
EXEC sp_trace_setevent @TraceID, 43, 12, @on 
EXEC sp_trace_setevent @TraceID, 43, 11, @on 
EXEC sp_trace_setevent @TraceID, 43, 51, @on 
EXEC sp_trace_setevent @TraceID, 43, 2, @on  
--Collect SQL:BatchStarting Event and Selected Data Columns
EXEC sp_trace_setevent @TraceID, 13, 13, @on 
EXEC sp_trace_setevent @TraceID, 13, 34, @on 
EXEC sp_trace_setevent @TraceID, 13, 1, @on 
EXEC sp_trace_setevent @TraceID, 13, 18, @on 
EXEC sp_trace_setevent @TraceID, 13, 16, @on 
EXEC sp_trace_setevent @TraceID, 13, 17, @on 
EXEC sp_trace_setevent @TraceID, 13, 25, @on 
EXEC sp_trace_setevent @TraceID, 13, 35, @on 
EXEC sp_trace_setevent @TraceID, 13, 10, @on 
EXEC sp_trace_setevent @TraceID, 13, 14, @on 
EXEC sp_trace_setevent @TraceID, 13, 15, @on 
EXEC sp_trace_setevent @TraceID, 13, 12, @on 
EXEC sp_trace_setevent @TraceID, 13, 11, @on 
EXEC sp_trace_setevent @TraceID, 13, 51, @on 
EXEC sp_trace_setevent @TraceID, 13, 2, @on
--Collect SQL:BatchCompleted Event and Selected Data Columns
EXEC sp_trace_setevent @TraceID, 12, 13, @on 
EXEC sp_trace_setevent @TraceID, 12, 34, @on 
EXEC sp_trace_setevent @TraceID, 12, 1, @on 
EXEC sp_trace_setevent @TraceID, 12, 18, @on 
EXEC sp_trace_setevent @TraceID, 12, 16, @on 
EXEC sp_trace_setevent @TraceID, 12, 17, @on 
EXEC sp_trace_setevent @TraceID, 12, 25, @on 
EXEC sp_trace_setevent @TraceID, 12, 35, @on 
EXEC sp_trace_setevent @TraceID, 12, 10, @on 
EXEC sp_trace_setevent @TraceID, 12, 14, @on 
EXEC sp_trace_setevent @TraceID, 12, 15, @on 
EXEC sp_trace_setevent @TraceID, 12, 12, @on 
EXEC sp_trace_setevent @TraceID, 12, 11, @on 
EXEC sp_trace_setevent @TraceID, 12, 51, @on 
EXEC sp_trace_setevent @TraceID, 12, 2, @on 
--Collect Showplan XML Event and Selected Data Columns 
EXEC sp_trace_setevent @TraceID, 122, 13, @on 
EXEC sp_trace_setevent @TraceID, 122, 34, @on 
EXEC sp_trace_setevent @TraceID, 122, 1, @on 
EXEC sp_trace_setevent @TraceID, 122, 18, @on 
EXEC sp_trace_setevent @TraceID, 122, 16, @on 
EXEC sp_trace_setevent @TraceID, 122, 17, @on 
EXEC sp_trace_setevent @TraceID, 122, 25, @on 
EXEC sp_trace_setevent @TraceID, 122, 35, @on 
EXEC sp_trace_setevent @TraceID, 122, 10, @on 
EXEC sp_trace_setevent @TraceID, 122, 14, @on 
EXEC sp_trace_setevent @TraceID, 122, 15, @on 
EXEC sp_trace_setevent @TraceID, 122, 12, @on 
EXEC sp_trace_setevent @TraceID, 122, 11, @on 
EXEC sp_trace_setevent @TraceID, 122, 51, @on 
EXEC sp_trace_setevent @TraceID, 122, 2, @on 

-- setando os filtros
-- o ultimo valor, numero 6, é o ID da database que deseja criar o trace
EXEC sp_trace_setfilter @TraceID, 3, 0, 0, @id_db ;

-- Start the Trace
EXEC sp_trace_setstatus @TraceID, 1 

-- codigo para finalizar o trace

SELECT TraceID=@TraceID ;
GOTO finish ;
-- Error 
error:
SELECT ErrorCode = @em ;
-- Exit 
finish: ;
GO 

-- Stop the trace
EXEC sp_trace_setstatus 3, 0 ;
-- Close the trace */
EXEC sp_trace_setstatus 3, 2 ;

/*
para buscar o resultado do trace no arquivo e mostrar no sql:
select * from fn_trace_gettable(N'C:\Teste Trace script\ProfileTrace2020.trc',default)
*/