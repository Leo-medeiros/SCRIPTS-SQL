exec stp_Load_all_Columns

declare @ID_Col_filter varchar(150)
declare @SQL varchar(max)
declare @filter int
declare @logical_operator varchar(1)
declare @comparison_operator varchar(10)
declare @value varchar(20)

set @logical_operator = '0'
set @ID_Col_filter = '35,12'
set @comparison_operator = '0'


if(OBJECT_ID('tempdb..#Filtros')IS NOT NULL)    
DROP TABLE tempdb..#Filtros    
    
select   palavra  INTO #Filtros from dbo.fncSplitTexto(@ID_Col_filter, ',')    
    --select * from #Filtros
DECLARE Cursor_Filter CURSOR FOR    
    
 SELECT palavra FROM #Filtros 


 OPEN Cursor_Filter      
 FETCH NEXT FROM Cursor_Filter INTO @filter      
 WHILE @@FETCH_STATUS = 0      
    BEGIN     
--SELECT @SQL   =  'INSERT INTO  Profile_eventos (comando) values ('' EXEC sp_trace_setevent '+CONVERT(VARCHAR(10),@TraceID)+','+ convert(varchar(10),@eventos) +',@c,1'')'    
  SELECT @SQL   =  'sp_trace_setfilter @TraceID,'+convert(varchar(10),@filter)+','+convert(varchar(10),@logical_operator)+','+convert(varchar(10),@comparison_operator)+', 6'    
--exec (@SQL )    
     
 select @SQL       
   set @SQL = ''    
    
 FETCH NEXT FROM Cursor_Filter INTO @filter    
 END    
CLOSE Cursor_Filter    
DEALLOCATE Cursor_Filter