 --executar a proc, para validar os dados, que deseja usar no evento do trace:
-- @help = 1


--exec stp_Load_all_Events @help = 1
--@id = 122
--@fl_language = 'pt'
--@id = 12

--@fl_language = 'pt', 
  
 --exec stp_Load_All_columns 

--DECLARE @c_ int = 0

--WHILE @c_ < 6
--BEGIN
--		PRINT 'DECLARE @c_'+ CONVERT(VARCHAR(8),@c_ + 1)+' INT'
--		SET @c_ = @c_ + 1
--END
--PRINT 'GERADO VARIAVEIS'
--GO
IF (OBJECT_ID('dbo.Stp_Teste1') IS  NULL) EXEC('CREATE PROCEDURE dbo.Stp_Teste1 AS SELECT 1')
GO
ALTER PROCEDURE Stp_Teste1 (@ID_Eventos VARCHAR(150),@ID_Colunas VARCHAR(150) )
AS
BEGIN

DECLARE @ID_Colunas VARCHAR(150)
--
DECLARE @ID_Eventos VARCHAR(150) 
--DECLARE @SQL VARCHAR(MAX)
set @ID_Colunas = ('2,3,4,6,12,5,20,1,15,20,30')
SET @ID_Eventos = ('12,10,14,15,122,14')

if(OBJECT_ID('tempdb..#resultado')IS NOT NULL)
DROP TABLE tempdb..#resultado

select   palavra  INTO #resultado from dbo.fncSplitTexto(@ID_Eventos, ',')
 
 DECLARE @SQL VARCHAR(MAX)
 DECLARE @eventos INT



DECLARE Cursor_VarreTBL CURSOR FOR

	SELECT palavra FROM #resultado

OPEN Cursor_VarreTBL  
	FETCH NEXT FROM Cursor_VarreTBL INTO @eventos  
	WHILE @@FETCH_STATUS = 0  
	   BEGIN 
SELECT @SQL   =  'EXEC sp_trace_setevent @TraceID,'+ convert(varchar(10),@eventos) +',@c_1,@on'
	
  ----exec (@SQL )
	
	select @SQL
			set @SQL = ''

 FETCH NEXT FROM Cursor_VarreTBL INTO @eventos
 END
CLOSE Cursor_VarreTBL
DEALLOCATE Cursor_VarreTBL














--SELECT @COUNT =  COUNT(1) from @vezes_Coluna

--SELECT @COUNT
--WHILE @COUNT < 
--BEGIN 
	


--DECLARE @c_ int = 0

--WHILE @c_ < 6
--BEGIN
--		PRINT 'SET @c_'+ CONVERT(VARCHAR(8),@c_ + 1)+' ='
--		SET @c_ = @c_ + 1
--END
--PRINT 'GERADO VARIAVEIS'
--GO
-- aqui vamos declarar a quantidade em variaveis do evento e o ID

DECLARE @ev_id1 int,  @ev_id2 int,  @ev_id3 int

SET @ev_id1 = 10 
SET @ev_id2 = 122
SET @ev_id3 = 12

-- aqui vamos declarar a quantidade em variaveis das colunas e o ID

DECLARE @c_1 INT
DECLARE @c_2 INT
DECLARE @c_3 INT
DECLARE @c_4 INT
DECLARE @c_5 INT
DECLARE @c_6 INT
DECLARE @c_7 INT
       
SET @c_1 = 1
SET @c_2 = 6
SET @c_3 = 8
SET @c_4 = 11
SET @c_5 = 10
SET @c_6 = 13
SET @c_7  = 18


-- executar essa proc para  pegar as colunas que deseja utilizar para cada evento do trace:
-- exec stp_Load_all_Columns @fl_language = 'pt'

-- select exibindo o ID de cada base de dados, caso deseje criar o trace utilizando uma base de dados de filtro

--select name, database_id from sys.databases 
-- variavel para informar o ID do bacno
DECLARE @id_db INT



set @id_db = 5
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


--------------------------------------------------------
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_1, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_2, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_3, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_4, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_5, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_6, @on 
EXEC sp_trace_setevent @TraceID, @ev_id2, @c_7, @on 

 

 --------------------------------------------------------
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_1, @on 
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_2, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_3, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_4, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_5, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_6, @on
EXEC sp_trace_setevent @TraceID, @ev_id3, @c_7, @on






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


-- DA QUI PRA CIMA 
/*
para buscar o resultado do trace no arquivo e mostrar no sql:
select * from fn_trace_gettable(N'D:\Bancos\estudos e testes\ProfileTrace2021.trc',default)
*/


-------------------------------------------------

IF (OBJECT_ID('dbo.Stp_Teste1') IS  NULL) EXEC('CREATE PROCEDURE dbo.Stp_Teste1 AS SELECT 1')
GO
ALTER PROCEDURE Stp_Teste1 (@ID_Eventos VARCHAR(150),@ID_Colunas VARCHAR(150) )
AS
BEGIN


DECLARE @em INT
DECLARE @TraceID INT
DECLARE @maxFileSize BIGINT
DECLARE @filename NVARCHAR(200)
DECLARE @on BIT


SELECT @maxFileSize = MaxFileSize,
	   @filename = FileName
FROM Profiler_Parameter

SET @on = 1




DECLARE @SQL VARCHAR(MAX)
DECLARE @eventos INT
DECLARE @colunas INT
 DECLARE @CMD VARCHAR(MAX)

 --  cria o trace


EXEC @em = sp_trace_create @TraceID OUTPUT,
0,@filename, @maxFileSize,NULL

 





--DECLARE @ID_Eventos  VARCHAR(150)
--DECLARE  @ID_Colunas VARCHAR(150)
---- erro
IF (@em != 0) GOTO error

--DECLARE @SQL VARCHAR(MAX)

--SET @ID_Eventos = ('27,10,169 ')
--set @ID_Colunas = ('1,11,14,16,59')

-- setando os eventos e dados de coluna a serem coletados

if(OBJECT_ID('tempdb..#resultado')IS NOT NULL)
DROP TABLE tempdb..#resultado

select   palavra  INTO #resultado from dbo.fncSplitTexto(@ID_Eventos, ',')

DECLARE Cursor_VarreTBL CURSOR FOR

	SELECT palavra FROM #resultado

OPEN Cursor_VarreTBL  
	FETCH NEXT FROM Cursor_VarreTBL INTO @eventos  
	WHILE @@FETCH_STATUS = 0  
	   BEGIN 
SELECT @SQL   =  'INSERT INTO  Profile_eventos (comando) values (''EXEC sp_trace_setevent @TraceID,'+ convert(varchar(10),@eventos) +',@c,@on'')'
	
exec (@SQL )
	
	--select @SQL   
			set @SQL = ''

 FETCH NEXT FROM Cursor_VarreTBL INTO @eventos
 END
CLOSE Cursor_VarreTBL
DEALLOCATE Cursor_VarreTBL


if(OBJECT_ID('tempdb..#resultadoColunas')IS NOT NULL)
DROP TABLE tempdb..#resultadoColunas

select   palavra  INTO #resultadoColunas from dbo.fncSplitTexto(@ID_Colunas, ',')

DECLARE Cursor_VarreCOL CURSOR FOR

	SELECT palavra FROM #resultadoColunas

OPEN Cursor_VarreCOL  
	FETCH NEXT FROM Cursor_VarreCOL INTO @colunas  
	WHILE @@FETCH_STATUS = 0  
	   BEGIN 
SELECT @CMD   =  'INSERT INTO  Profile_Colunas (comando) values (''EXEC sp_trace_setevent @TraceID, @e,'+convert(varchar(10),@colunas)+',@on'')'
	
exec (@CMD )
	
	--select @@CMD   
			set @CMD = ''

 FETCH NEXT FROM Cursor_VarreCOL INTO @colunas
 END
CLOSE Cursor_VarreCOL
DEALLOCATE Cursor_VarreCOL

-- truncate table  Profile_eventos
--truncate table  Profile_Colunas

if(OBJECT_ID('tempdb..#TBL')IS NOT NULL)
DROP TABLE tempdb..#TBL


SELECT comando, ROW_NUMBER() over (order by comando) As myRowNumber INTO #TBL
    FROM Profile_eventos  





	if(OBJECT_ID('tempdb..#TBL2')IS NOT NULL)
DROP TABLE tempdb..#TBL2


 SELECT comando, ROW_NUMBER() over (order by comando) As myRowNumber  into #TBL2
 FROM Profile_Colunas

 	truncate table  Profile_eventos

	truncate table  Profile_Colunas


 	if(OBJECT_ID('tempdb..#valida')IS NOT NULL)
DROP TABLE tempdb..#valida

SELECT  replace(SUBSTRING(comando,37,2),',' ,'') as [CMD] into #valida

 
FROM #TBL2  


 	if(OBJECT_ID('tempdb..#FIM')IS NOT NULL)
DROP TABLE tempdb..#FIM


select replace(A.comando,'@c',B.CMD) AS [CMD] , ROW_NUMBER() over (order by [CMD]) As NLinhas  
into #FIM from #valida B, #TBL A 

declare @Loop int, @Comando nvarchar(MAX)
	set @Loop = 1

	while exists(select top 1 null from #FIM)
	begin

				
		select top 1 @Comando = [CMD],@Loop = NLinhas
		from #FIM		
		
		EXECUTE sp_executesql @Comando

		set @Loop = @Loop + 1 



	END






-- Start the Trace
DECLARE @CC NVARCHAR(MAX)

SELECT @CC =  'EXEC sp_trace_setstatus' +@TraceID+ ' ,1'
EXECUTE sp_executesql @CC




PRINT @TraceID
GOTO finish ;
-- Error 
error:
SELECT ErrorCode = @em ;
-- Exit 
finish: ;

END


IF (OBJECT_ID('dbo.Stp_stop') IS  NULL) EXEC('CREATE PROCEDURE dbo.Stp_stop AS SELECT 1')
go
ALTER PROCEDURE Stp_stop (@ID_trace INT )
AS 
BEGIN
--Stop the trace
EXEC sp_trace_setstatus 2, 0 ;
--Close the trace */
EXEC sp_trace_setstatus 2, 2 ;


END






 
 










