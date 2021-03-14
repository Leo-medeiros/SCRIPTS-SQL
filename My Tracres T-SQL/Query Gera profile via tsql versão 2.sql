-- executar a proc, para validar os dados, que deseja usar no evento do trace:
--exec stp_Load_all_Events @fl_language = 'pt', @id = 122

--DECLARE @EventN int = 0

--WHILE @EventN < 3
--BEGIN
--		PRINT 'DECLARE @EventN'+ CONVERT(VARCHAR(8),@EventN + 1)+' INT'
--		SET @EventN = @EventN + 1
--END
--PRINT 'FUNFO LELEO'
--GO




--DECLARE @EventN int = 0

--WHILE @EventN < 15
--BEGIN
--		PRINT 'SET @EventN'+ CONVERT(VARCHAR(8),@EventN + 1)+' ='
--		SET @EventN = @EventN + 1
--END
--PRINT 'FUNFO LELEO'
--GO
-- aqui vamos declarar a quantidade em variaveis do evento e o ID

DECLARE @ev_id1 int,  @ev_id2 int,  @ev_id3 int

SET @ev_id1 = 10 
SET @ev_id2 = 12
SET @ev_id3 = 13

-- aqui vamos declarar a quantidade em variaveis das colunas e o ID

DECLARE @c_1 int, @c_2 int, @c_3 int, @c_4 int, @c_5 int, @c_6 int , @c_7 int, @c_8 int, @c_9 int, @c_10 int, @c_11 int

SET @c_1  = 12
SET @c_2  = 1
SET @c_3  = 8
SET @c_4  = 10
SET @c_5  = 11
SET @c_6  = 13
SET @c_7  = 18
SET @c_8  = 16
SET @c_9  = 14
SET @c_10 = 15
SET @c_11 = 34

-- executar essa proc para  pegar as colunas que deseja utilizar para cada evento do trace:
-- exec stp_Load_all_Columns @fl_language = 'pt'

-- select exibindo o ID de cada base de dados, caso deseje criar o trace utilizando uma base de dados de filtro

--select name, database_id from sys.databases 
-- variavel para informar o ID do bacno
DECLARE @id_db INT

set @id_db = 7
-- declarando as variaveis do trace
DECLARE @em INT
DECLARE @TraceID INT
DECLARE @maxFileSize BIGINT
DECLARE @filename NVARCHAR(200)

select * from Profiler_Parameter


update Profiler_Parameter set FileName = 'D:\Bancos\estudos e testes\ProfileTrace2021'
ALTER TABLE Profiler_Parameter ADD FileName  NVARCHAR(200)
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

EXEC sp_trace_setevent @TraceID, @ev_id1, @c_1, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_2, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_3, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_4, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_5, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_6, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_7, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_8, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_9, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_10, @on
EXEC sp_trace_setevent @TraceID, @ev_id1, @c_11, @on
--------------------------------------------------------
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_1, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_2, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_3, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_4, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_5, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_6, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_7, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_8, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_9, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_10, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_11, @on 

 --------------------------------------------------------
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_1, @on 
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_2, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_3, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_4, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_5, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_6, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_7, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_8, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_9, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_10, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_11, @on


-- setando os filtros
-- o ultimo valor, numero 6, é o ID da database que deseja criar o trace
EXEC sp_trace_setfilter @TraceID, 3, 0, 0, @id_db ;

-- Start the Trace
EXEC sp_trace_setstatus @TraceID, 1 

-- codigo para finalizar o trace



SELECT TraceID=@TraceID ;
PRINT @TraceID
GOTO finish ;
-- Error 
error:
SELECT ErrorCode = @em ;
-- Exit 
finish: ;
GO 

--Stop the trace
--EXEC sp_trace_setstatus 2, 0 ;
--Close the trace */
--EXEC sp_trace_setstatus 2, 2 ;

/*
para buscar o resultado do trace no arquivo e mostrar no sql:
select * from fn_trace_gettable(N'D:\Bancos\estudos e testes\ProfileTrace2021.trc',default)
*/