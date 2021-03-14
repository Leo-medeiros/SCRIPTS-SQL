-- executar a proc, para validar os dados, que deseja usar no evento do trace:
--exec stp_Load_all_Events @fl_language = 'pt', @id = 122

DECLARE @EventN int = 0

WHILE @EventN < 3
BEGIN
		PRINT '@EventN'+ CONVERT(VARCHAR(8),@EventN + 1)+' INT'
		SET @EventN = @EventN + 1
END
PRINT 'FUNFO LELEO'
GO

DECLARE @EventN int = 0

WHILE @EventN < 11
BEGIN
		PRINT 'SET @c_'+ CONVERT(VARCHAR(8),@EventN + 1)+'='
		SET @EventN = @EventN + 1
END
PRINT 'FUNFO LELEO'
GO



DECLARE @EventN int = 0

WHILE @EventN < 11
BEGIN
		PRINT '@c_'+ CONVERT(VARCHAR(8),@EventN + 1)+' INT,'
		SET @EventN = @EventN + 1
END
PRINT 'FUNFO LELEO'
GO
-- aqui vamos declarar a quantidade em variaveis do evento e o ID

DECLARE @EventN1 INT, @EventN2 INT,@EventN3 INT


SET @EventN1 = 10 
SET @EventN2 = 12
SET @EventN3 = 13

-- aqui vamos declarar a quantidade em variaveis das colunas e o ID

DECLARE @c_1 INT,
@c_2 INT,
@c_3 INT,
@c_4 INT,
@c_5 INT,
@c_6 INT,
@c_7 INT,
@c_8 INT,
@c_9 INT,
@c_10 INT,
@c_11 INT,

SET @c_1= 1
SET @c_2=
SET @c_3=
SET @c_4=
SET @c_5=
SET @c_6=
SET @c_7=
SET @c_8=
SET @c_9=
SET @c_10=
SET @c_11=

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