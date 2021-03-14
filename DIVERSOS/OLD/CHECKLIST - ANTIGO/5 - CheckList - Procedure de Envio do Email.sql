/*******************************************************************************************************************************
(C) 2016, Fabricio Lima Soluções em Banco de Dados

Site: http://www.fabriciolima.net/

Feedback: fabricioflima@gmail.com
*******************************************************************************************************************************/


/***********************************************************************************************************************************
------------------------------------------------------------------------------------------------------------------------------------
--	LEIA-ME!!! INSTRUÇÕES DE EXECUÇÃO:
------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
--	PASSO 1:
------------------------------------------------------------------------------------------------------------------------------------
--	Alterar o PROFILE e o E-MAIL para os necessários:

		@profile_name = 'MSSQLServer',
		@recipients = 'fabricioflima@gmail.com', 
	
------------------------------------------------------------------------------------------------------------------------------------
--	PASSO 2:
------------------------------------------------------------------------------------------------------------------------------------
--	Alterar no Subject o Nome da Empresa:

		SET @subject = 'CheckList Diário do Banco de Dados - NomeEmpresa - ' + @@SERVERNAME
			
***********************************************************************************************************************************/


/*******************************************************************************************************************************
--	Database que será utilizada para armazenar os dados do CheckList. Se for necessário, altere o nome da mesma.
*******************************************************************************************************************************/
USE Traces


/*******************************************************************************************************************************
--	Cria a procedure que envia o E-Mail do CheckList do Banco de Dados
*******************************************************************************************************************************/
IF OBJECT_ID('[dbo].[stpEnvia_CheckList_Diario_DBA]') is not null
	DROP PROCEDURE [dbo].[stpEnvia_CheckList_Diario_DBA]

GO

/****** Object:  StoredProcedure [dbo].[stpEnvia_CheckList_Diario_DBA]    Script Date: 03/06/2016 11:44:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
CREATE PROCEDURE [dbo].[stpEnvia_CheckList_Diario_DBA]
AS
BEGIN
	/***********************************************************************************************************************************
	--	1) Disponibilidade SQL Server - HEADER
	***********************************************************************************************************************************/
	DECLARE @DisponibilidadeSQL_Header VARCHAR(MAX)
	SET @DisponibilidadeSQL_Header = '<font color=black size=5>'
	SET @DisponibilidadeSQL_Header = @DisponibilidadeSQL_Header + '<br/> Tempo de Disponibilidade do SQL Server <br/>' 
	SET @DisponibilidadeSQL_Header = @DisponibilidadeSQL_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	1) Disponibilidade SQL Server - BODY
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @DisponibilidadeSQL_Table VARCHAR(MAX)
	SET @DisponibilidadeSQL_Table = CAST( (    
		SELECT td =	DisponibilidadeSQL + '</td>'
		FROM (           
				SELECT	RTRIM(CONVERT(CHAR(17), DATEDIFF(SECOND, CONVERT(DATETIME, [Create_Date]), GETDATE()) / 86400)) + ' Dia(s) ' +
						RIGHT('00' + RTRIM(CONVERT(CHAR(7), DATEDIFF(SECOND, CONVERT(DATETIME, [Create_Date]), GETDATE()) % 86400 / 3600)), 2) + ' Hora(s) ' +
						RIGHT('00' + RTRIM(CONVERT(CHAR(7), DATEDIFF(SECOND, CONVERT(DATETIME, [Create_Date]), GETDATE()) % 86400 % 3600 / 60)), 2) + ' Minuto(s) ' AS DisponibilidadeSQL
				FROM [sys].[databases]
				WHERE [Database_Id] = 2
				    
			  ) AS D
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX)
	)  
      
	SET @DisponibilidadeSQL_Table =	REPLACE( REPLACE( REPLACE( REPLACE(@DisponibilidadeSQL_Table, '&lt;', '<'), '&gt;', '>'), 
													'<td> ', '<td align=center '),'<td>', '<td align=center>')
    
	SET @DisponibilidadeSQL_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
			+	'<tr>
					<th width="300" bgcolor=#0B0B61><font color=white>Tempo Disponibilidade</font></th>
				</tr>'    
			+ REPLACE( REPLACE( @DisponibilidadeSQL_Table, '&lt;', '<'), '&gt;', '>')
			+ '</table>'


	/***********************************************************************************************************************************
	--	2) Espaço em Disco - Header
	***********************************************************************************************************************************/
	DECLARE @EspacoDisco_Header VARCHAR(MAX)
	SET @EspacoDisco_Header = '<font color=black size=5>'
	SET @EspacoDisco_Header = @EspacoDisco_Header + '<br/> Espaço em Disco <br/>' 
	SET @EspacoDisco_Header = @EspacoDisco_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	2) Espaço em Disco - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @EspacoDisco_Table VARCHAR(MAX)
	SET @EspacoDisco_Table = CAST( (    
		SELECT td =				   CASE WHEN [SpaceUsed_Percent] = '-' THEN '' WHEN CAST([SpaceUsed_Percent] AS NUMERIC(9,2)) >= 90 THEN ' bgcolor=yellow>' ELSE '' END + [DriveName]			+ '</td>' +
						+ '<td>' + CASE WHEN [SpaceUsed_Percent] = '-' THEN '' WHEN CAST([SpaceUsed_Percent] AS NUMERIC(9,2)) >= 90 THEN ' bgcolor=yellow>' ELSE '' END + [TotalSize_GB]		+ '</td>' +
						+ '<td>' + CASE WHEN [SpaceUsed_Percent] = '-' THEN '' WHEN CAST([SpaceUsed_Percent] AS NUMERIC(9,2)) >= 90 THEN ' bgcolor=yellow>' ELSE '' END + [SpaceUsed_GB]		+ '</td>' +
						+ '<td>' + CASE WHEN [SpaceUsed_Percent] = '-' THEN '' WHEN CAST([SpaceUsed_Percent] AS NUMERIC(9,2)) >= 90 THEN ' bgcolor=yellow>' ELSE '' END + [FreeSpace_GB]		+ '</td>' +
						+ '<td>' + CASE WHEN [SpaceUsed_Percent] = '-' THEN '' WHEN CAST([SpaceUsed_Percent] AS NUMERIC(9,2)) >= 90 THEN ' bgcolor=yellow>' ELSE '' END + [SpaceUsed_Percent]	+ '</td>'
		FROM (           
				SELECT	[DriveName], 
						ISNULL(CAST([TotalSize_GB]		AS VARCHAR), '-')	AS [TotalSize_GB], 
						ISNULL(CAST([SpaceUsed_GB]		AS VARCHAR), '-')	AS [SpaceUsed_GB],
						ISNULL(CAST([FreeSpace_GB]		AS VARCHAR), '-')	AS [FreeSpace_GB], 
						ISNULL(CAST([SpaceUsed_Percent] AS VARCHAR), '-')	AS [SpaceUsed_Percent] 
				FROM [dbo].[CheckList_Espaco_Disco]
				    
			  ) AS D ORDER BY [DriveName]
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX)
	)  
      
	SET @EspacoDisco_Table =	REPLACE( REPLACE( REPLACE( REPLACE(@EspacoDisco_Table, '&lt;', '<'), '&gt;', '>'), 
													'<td> ', '<td align=center '),'<td>', '<td align=center>')
    
	SET @EspacoDisco_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
			+	'<tr>
					<th width="50" bgcolor=#0B0B61><font color=white>Drive</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Tamanho (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Utilizado (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Livre (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Utilizado (%)</font></th>
				</tr>'    
			+ REPLACE( REPLACE( @EspacoDisco_Table, '&lt;', '<'), '&gt;', '>')
			+ '</table>' 
              
              
	/***********************************************************************************************************************************
	--	3) Arquivos MDF e LDF - Header
	***********************************************************************************************************************************/
	DECLARE @ArquivosMDFLDF_Header VARCHAR(MAX)
	SET @ArquivosMDFLDF_Header = '<font color=black size=5>'
	SET @ArquivosMDFLDF_Header = @ArquivosMDFLDF_Header + '<br/> TOP 10 - Informações dos Arquivos .MDF e .LDF <br/>' 
	SET @ArquivosMDFLDF_Header = @ArquivosMDFLDF_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	3) Arquivos MDF e LDF - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @ArquivosMDFLDF_Table VARCHAR(MAX)
	SET @ArquivosMDFLDF_Table = CAST( (
		SELECT td =				  [Nm_Database]			+ 
					'</td><td>' + [Logical_Name]		+ 
					'</td><td>' + [Total_Reservado]		+ 
					'</td><td>' + [Total_Utilizado]		+ 		
					'</td><td>' + [Espaco_Livre (MB)]	+ 
					'</td><td>' + [Espaco_Livre (%)]	+ 
					'</td><td>' + [MAXSIZE]				+ 	
					'</td><td>' + [Growth]				+	'</td>'
	                                    
		FROM (           
				SELECT	TOP 10
						[Nm_Database], 
						ISNULL([Logical_Name], '-')							AS [Logical_Name], 
						ISNULL(CAST([Total_Reservado]	AS VARCHAR), '-')	AS [Total_Reservado], 
						ISNULL(CAST([Total_Utilizado]	AS VARCHAR), '-')	AS [Total_Utilizado],
						ISNULL(CAST([Espaco_Livre (MB)]	AS VARCHAR), '-')	AS [Espaco_Livre (MB)], 
						ISNULL(CAST([Espaco_Livre (%)]	AS VARCHAR), '-')	AS [Espaco_Livre (%)],
						ISNULL(CAST([MaxSize]			AS VARCHAR), '-')	AS [MAXSIZE], 
						ISNULL(CAST([Growth]			AS VARCHAR), '-')	AS [Growth]
				FROM  [dbo].[CheckList_Arquivos_MDF_LDF]
				ORDER BY CAST(REPLACE([Espaco_Livre (%)], '-', 0) AS NUMERIC(15,2))
				    
			  ) AS D
		  FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
      
    SET @ArquivosMDFLDF_Table = REPLACE( REPLACE( REPLACE(@ArquivosMDFLDF_Table, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align=center>')
    
	SET @ArquivosMDFLDF_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
            +	'<tr>
					<th width="170" bgcolor=#0B0B61><font color=white>Nome Database</font></th>
					<th width="200" bgcolor=#0B0B61><font color=white>Nome Lógico</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Total Reservado (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Total Utilizado (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Espaco_Livre (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Espaco_Livre (%)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>MAXSIZE</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Growth</font></th>          
				</tr>'    
            + REPLACE( REPLACE( @ArquivosMDFLDF_Table, '&lt;', '<'), '&gt;', '>')   
            + '</table>' 
            

	/***********************************************************************************************************************************
	--	4) Crescimento das Bases - Header
	***********************************************************************************************************************************/
	DECLARE @CrescimentoBases_Header VARCHAR(MAX)
	SET @CrescimentoBases_Header = '<font color=black size=5>'
	SET @CrescimentoBases_Header = @CrescimentoBases_Header + '<br/> TOP 10 - Crescimento das Bases <br/>'
	SET @CrescimentoBases_Header = @CrescimentoBases_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	4) Crescimento das Bases - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CrescimentoBases_Table VARCHAR(MAX)    
	SET @CrescimentoBases_Table = CAST( (    
		SELECT td = CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Nm_Database]	+ '</font>'
															ELSE [Nm_Database]   END  + '</td><td>'  +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Tamanho_Atual]	+ '</font>'
															ELSE [Tamanho_Atual] END  + '</td><td>'  +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Cresc_1_dia]	+ '</font>'
															ELSE [Cresc_1_dia]   END  + '</td><td>'  +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Cresc_15_dia]	+ '</font>'
															ELSE [Cresc_15_dia]  END  + '</td><td>'  +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Cresc_30_dia]	+ '</font>'
															ELSE [Cresc_30_dia]  END  + '</td><td>'  +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Cresc_60_dia]	+ '</font>'
															ELSE [Cresc_60_dia]  END  + '</td>'                                 
		FROM (           
				SELECT	TOP 10
						[Nm_Servidor], 
						[Nm_Database], 
						ISNULL(CAST([Tamanho_Atual] AS VARCHAR), '-') AS [Tamanho_Atual],
						ISNULL(CAST([Cresc_1_dia]   AS VARCHAR), '-') AS [Cresc_1_dia],
						ISNULL(CAST([Cresc_15_dia]  AS VARCHAR), '-') AS [Cresc_15_dia], 
						ISNULL(CAST([Cresc_30_dia]  AS VARCHAR), '-') AS [Cresc_30_dia],
						ISNULL(CAST([Cresc_60_dia]  AS VARCHAR), '-') AS [Cresc_60_dia]
				FROM [dbo].[CheckList_Database_Growth_Email]
				WHERE [Nm_Servidor] IS NOT NULL		-- REGISTROS NORMAIS
				
				UNION
				
				SELECT	[Nm_Servidor], 
						[Nm_Database], 
						ISNULL(CAST([Tamanho_Atual] AS VARCHAR), '-') AS [Tamanho_Atual], 
						ISNULL(CAST([Cresc_1_dia]   AS VARCHAR), '-') AS [Cresc_1_dia],
						ISNULL(CAST([Cresc_15_dia]  AS VARCHAR), '-') AS [Cresc_15_dia], 
						ISNULL(CAST([Cresc_30_dia]  AS VARCHAR), '-') AS [Cresc_30_dia],
						ISNULL(CAST([Cresc_60_dia]  AS VARCHAR), '-') AS [Cresc_60_dia]
				FROM [dbo].[CheckList_Database_Growth_Email]
				WHERE [Nm_Servidor] IS NULL			-- TOTAL GERAL
				
			  ) AS D ORDER BY	[Nm_Servidor] DESC,
								CAST(REPLACE([Cresc_1_dia],  '-', 0) AS NUMERIC(15,2)) DESC,
								CAST(REPLACE([Cresc_15_dia], '-', 0) AS NUMERIC(15,2)) DESC,
								CAST(REPLACE([Cresc_30_dia], '-', 0) AS NUMERIC(15,2)) DESC,
								CAST(REPLACE([Cresc_60_dia], '-', 0) AS NUMERIC(15,2)) DESC
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) )   
      
    SET @CrescimentoBases_Table = REPLACE( REPLACE( REPLACE( REPLACE(@CrescimentoBases_Table, '&lt;', '<'), '&gt;', '>'), 
													'<td> ', '<td align=center '),'<td>', '<td align=center>')
    
	SET @CrescimentoBases_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
            +	'<tr>
					<th width="170" bgcolor=#0B0B61><font color=white>Nome Database</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Tamanho Atual (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Cresc. 1 Dia (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Cresc. 15 Dia (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Cresc. 30 Dia (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Cresc. 60 Dia (MB)</font></th>               
				</tr>'    
            + REPLACE( REPLACE( @CrescimentoBases_Table, '&lt;', '<'), '&gt;', '>')   
            + '</table>' 
                        

	/***********************************************************************************************************************************
	--	5) Crescimento das Tabelas - Header
	***********************************************************************************************************************************/
	DECLARE @CrescimentoTabelas_Header VARCHAR(MAX)
	SET @CrescimentoTabelas_Header = '<font color=black size=5>'
	SET @CrescimentoTabelas_Header = @CrescimentoTabelas_Header + '<br/> TOP 10 - Crescimento das Tabelas <br/>' 
	SET @CrescimentoTabelas_Header = @CrescimentoTabelas_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	5) Crescimento das Tabelas - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CrescimentoTabelas_Table VARCHAR(MAX)    
	SET @CrescimentoTabelas_Table = CAST( (    
		SELECT td = CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Nm_Database]	+ '</font>'
															ELSE [Nm_Database] END   + '</td><td>'	 +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Nm_Tabela]		+ '</font>'
															ELSE [Nm_Tabela] END	 + '</td><td>'	 +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Tamanho_Atual]	+ '</font>'
															ELSE [Tamanho_Atual] END + '</td><td>'   +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Cresc_1_dia]	+ '</font>'
															ELSE [Cresc_1_dia] END   + '</td><td>'	 +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Cresc_15_dia]	+ '</font>'
															ELSE [Cresc_15_dia] END  + '</td><td>'	 +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Cresc_30_dia]	+ '</font>'
															ELSE [Cresc_30_dia] END  + '</td><td>'	 +
					CASE WHEN [Nm_Database] = 'TOTAL GERAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Cresc_60_dia]	+ '</font>'
															ELSE [Cresc_60_dia] END  + '</td>'	                                    
		FROM (
				SELECT	TOP 10
						[Nm_Servidor], 
						[Nm_Database], 
						ISNULL([Nm_Tabela], '-')					   AS [Nm_Tabela], 
						ISNULL(CAST([Tamanho_Atual] AS VARCHAR),  '-') AS [Tamanho_Atual], 
						ISNULL(CAST([Cresc_1_dia]	AS VARCHAR),  '-') AS [Cresc_1_dia],
						ISNULL(CAST([Cresc_15_dia]	AS VARCHAR),  '-') AS [Cresc_15_dia], 
						ISNULL(CAST([Cresc_30_dia]	AS VARCHAR),  '-') AS [Cresc_30_dia],
						ISNULL(CAST([Cresc_60_dia]	AS VARCHAR),  '-') AS [Cresc_60_dia]
				FROM [dbo].[CheckList_Table_Growth_Email]
				WHERE [Nm_Servidor] IS NOT NULL		-- REGISTROS NORMAIS
							
				UNION ALL
				
				SELECT	[Nm_Servidor], 
						[Nm_Database], 
						ISNULL([Nm_Tabela], '-')					   AS [Nm_Tabela], 
						ISNULL(CAST([Tamanho_Atual] AS VARCHAR),  '-') AS [Tamanho_Atual], 
						ISNULL(CAST([Cresc_1_dia]	AS VARCHAR),  '-') AS [Cresc_1_dia],
						ISNULL(CAST([Cresc_15_dia]	AS VARCHAR),  '-') AS [Cresc_15_dia], 
						ISNULL(CAST([Cresc_30_dia]	AS VARCHAR),  '-') AS [Cresc_30_dia],
						ISNULL(CAST([Cresc_60_dia]	AS VARCHAR),  '-') AS [Cresc_60_dia]
				FROM [dbo].[CheckList_Table_Growth_Email]
				WHERE [Nm_Servidor] IS NULL			-- TOTAL GERAL
				
			  ) AS D ORDER BY	[Nm_Servidor] DESC,
								CAST(REPLACE([Cresc_1_dia],  '-', 0) AS NUMERIC(15,2)) DESC,
								CAST(REPLACE([Cresc_15_dia], '-', 0) AS NUMERIC(15,2)) DESC,
								CAST(REPLACE([Cresc_30_dia], '-', 0) AS NUMERIC(15,2)) DESC,
								CAST(REPLACE([Cresc_60_dia], '-', 0) AS NUMERIC(15,2)) DESC
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
      
    SET @CrescimentoTabelas_Table = REPLACE( REPLACE( REPLACE( REPLACE(@CrescimentoTabelas_Table, '&lt;', '<'), '&gt;', '>'), 
													'<td> ', '<td align=center '),'<td>', '<td align=center>')
    
	SET @CrescimentoTabelas_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
			+	'<tr>
					<th width="170" bgcolor=#0B0B61><font color=white>Nome Database</font></th>
					<th width="170" bgcolor=#0B0B61><font color=white>Nome Tabela</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Tamanho Atual (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Cresc. 1 Dia (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Cresc. 15 Dia (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Cresc. 30 Dia (MB)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Cresc. 60 Dia (MB)</font></th>
				</tr>'    
            + REPLACE( REPLACE(@CrescimentoTabelas_Table, '&lt;', '<'), '&gt;', '>')
            + '</table>'


	/***********************************************************************************************************************************
	--	6) Backup - Header
	***********************************************************************************************************************************/
	DECLARE @Backup_Header VARCHAR(MAX)
	SET @Backup_Header = '<font color=black size=5>'
	SET @Backup_Header = @Backup_Header + '<br/> TOP 10 - Backup FULL e Diferencial das Bases <br/>'
	SET @Backup_Header = @Backup_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	6) Backup - Informações
	------------------------------------------------------------------------------------------------------------------------------------ 
	DECLARE @Backup_Table VARCHAR(MAX)
	SET @Backup_Table = CAST( (    
		SELECT td =				  [Database_Name]		+ 
					'</td><td>' + [Backup_Start_Date]	+ 
					'</td><td>' + [Tempo_Min]			+
					'</td><td>' + [Recovery_Model]		+ 
					'</td><td>' + [Tipo]				+ 		
					'</td><td>' + [Tamanho_MB]			+	'</td>'                                     
		FROM (           
				SELECT	TOP 10
						[Database_Name], 
						ISNULL(CONVERT(VARCHAR, [Backup_Start_Date], 120), '-') AS [Backup_Start_Date], 
						ISNULL(CAST([Tempo_Min] AS VARCHAR), '-')				AS [Tempo_Min],
						ISNULL(CAST([Recovery_Model] AS VARCHAR), '-')			AS [Recovery_Model],
						ISNULL(
							CASE [Type]
								WHEN 'D' THEN 'FULL'
								WHEN 'I' THEN 'Diferencial'
								WHEN 'L' THEN 'Log'
							END, '-')											AS [Tipo],
						ISNULL(CAST([Tamanho_MB] AS VARCHAR), '-')				AS [Tamanho_MB]
				FROM [dbo].[CheckList_Backups_Executados]
				ORDER BY CONVERT(VARCHAR, [Backup_Start_Date], 120)
				
			  ) AS D 
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
      
    SET @Backup_Table = REPLACE( REPLACE( REPLACE(@Backup_Table, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align=center>')
    
	SET @Backup_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
			+	'<tr>
					<th width="170" bgcolor=#0B0B61><font color=white>Nome Database</font></th>
					<th width="170" bgcolor=#0B0B61><font color=white>Horário Execução</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Tempo (min)</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Recovery</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Tipo Backup</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Tamanho (MB)</font></th>             
				</tr>'    
			+ REPLACE( REPLACE(@Backup_Table, '&lt;', '<'), '&gt;', '>')
			+ '</table>' 


	/***********************************************************************************************************************************
	--	7) Jobs que Falharam - Header
	***********************************************************************************************************************************/
	DECLARE @JobsFailed_Header VARCHAR(MAX)
	SET @JobsFailed_Header = '<font color=black size=5>'
	SET @JobsFailed_Header = @JobsFailed_Header + '<br/> TOP 10 - Jobs que Falharam <br/>'
	SET @JobsFailed_Header = @JobsFailed_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	7) Jobs que Falharam - Informações
	------------------------------------------------------------------------------------------------------------------------------------ 
	DECLARE @JobsFailed_Table VARCHAR(MAX)    
	SET @JobsFailed_Table = CAST( (    
		SELECT td =				  [Job_Name]	 +
					'</td><td>' + [Status]		 + 
					'</td><td>' + [Dt_Execucao]  + 
					'</td><td>' + [Run_Duration] + 
					'</td><td>' + [SQL_Message]  +	'</td>'                                     
		FROM (
				SELECT	TOP 10
						[Job_Name], 
						ISNULL([Status], '-')								AS [Status], 
						ISNULL(CONVERT(VARCHAR, [Dt_Execucao], 120), '-')	AS [Dt_Execucao], 
						ISNULL([Run_Duration], '-')							AS [Run_Duration], 
						ISNULL([SQL_Message], '-')							AS [SQL_Message]
				FROM [dbo].[CheckList_Jobs_Failed]
				ORDER BY [Run_Duration] DESC
				
			  ) AS D 
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
      
    SET @JobsFailed_Table = REPLACE( REPLACE( REPLACE(@JobsFailed_Table, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align=center>')
    
	SET @JobsFailed_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
            +	'<tr>
					<th width="200" bgcolor=#0B0B61><font color=white>Nome Job</font></th>
					<th width="80" bgcolor=#0B0B61><font color=white>Status</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Horário Execução</font></th>    
					<th width="100" bgcolor=#0B0B61><font color=white>Duração (hh:mm:ss)</font></th>
					<th width="320" bgcolor=#0B0B61><font color=white>Mensagem</font></th>        
				</tr>'
            + REPLACE( REPLACE(@JobsFailed_Table, '&lt;', '<'), '&gt;', '>')   
            + '</table>' 


	/***********************************************************************************************************************************
	--	8) Jobs Alterados - Header
	***********************************************************************************************************************************/ 
	DECLARE @JobsAlterados_Header VARCHAR(MAX)
	SET @JobsAlterados_Header = '<font color=black size=5>'
	SET @JobsAlterados_Header = @JobsAlterados_Header + '<br/> TOP 10 - Jobs Alterados <br/>'
	SET @JobsAlterados_Header = @JobsAlterados_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	8) Jobs Alterados - Informações
	------------------------------------------------------------------------------------------------------------------------------------ 
	DECLARE @JobsAlterados_Table VARCHAR(MAX)    
	SET @JobsAlterados_Table = CAST( (    
		SELECT td =				  [Nm_Job]			+ 
					'</td><td>' + [Fl_Habilitado]	+ 
					'</td><td>' + [Dt_Criacao]		+ 
					'</td><td>' + [Dt_Modificacao]  + 
					'</td><td>' + [Nr_Versao]		+	'</td>'                                     
		FROM (	
				SELECT	TOP 10
						[Nm_Job], 
						ISNULL(
							CASE [Fl_Habilitado] 
								WHEN 1 THEN 'SIM' 
								WHEN 0 THEN 'Não' 
							END, '-')											AS [Fl_Habilitado], 
						ISNULL(CONVERT(VARCHAR, [Dt_Criacao], 120), '-')		AS [Dt_Criacao],
						ISNULL(CONVERT(VARCHAR, [Dt_Modificacao], 120), '-')	AS [Dt_Modificacao],
						ISNULL(CAST([Nr_Versao] AS VARCHAR), '-')				AS [Nr_Versao]
				FROM [dbo].[CheckList_Alteracao_Jobs]
				ORDER BY [Dt_Modificacao] DESC
				
			  ) AS D 
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
      
    SET @JobsAlterados_Table = REPLACE( REPLACE( REPLACE( @JobsAlterados_Table, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align=center>')
    
	SET @JobsAlterados_Table = 
			'<table cellpadding="0" cellspacing="0" border="3" >'    
            +	'<tr>
					<th width="200" bgcolor=#0B0B61><font color=white>Nome Job</font></th>
					<th width="60" bgcolor=#0B0B61><font color=white>Habilitado</font></th>
					<th width="170" bgcolor=#0B0B61><font color=white>Data Criação</font></th>    
					<th width="170" bgcolor=#0B0B61><font color=white>Data Alteração</font></th>
					<th width="80" bgcolor=#0B0B61><font color=white>Núm. Versão</font></th>        
				</tr>'    
            + REPLACE( REPLACE(@JobsAlterados_Table, '&lt;', '<'), '&gt;', '>')   
            + '</table>' 


	/***********************************************************************************************************************************
	--	9) Jobs Demorados - Header
	***********************************************************************************************************************************/ 
	DECLARE @TempoJobs_Header VARCHAR(MAX)
	SET @TempoJobs_Header = '<font color=black size=5>'
	SET @TempoJobs_Header = @TempoJobs_Header + '<br/> TOP 10 - Jobs Demorados <br/>' 
	SET @TempoJobs_Header = @TempoJobs_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	9) Jobs Demorados - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TempoJobs_Table VARCHAR(MAX)    
	SET @TempoJobs_Table = CAST( (    
		SELECT td =				  [Job_Name]	 + 
					'</td><td>' + [Status]		 + 
					'</td><td>' + [Dt_Execucao]  + 
					'</td><td>' + [Run_Duration] + 
					'</td><td>' + [SQL_Message]	 +	'</td>'                                     
		FROM (	
				SELECT	TOP 10
						[Job_Name], 
						ISNULL([Status], '-')								AS [Status], 
						ISNULL(CONVERT(VARCHAR, [Dt_Execucao], 120), '-')	AS [Dt_Execucao], 
						ISNULL([Run_Duration], '-')							AS [Run_Duration], 
						ISNULL([SQL_Message], '-')							AS [SQL_Message]
				FROM [dbo].[CheckList_Job_Demorados]
				ORDER BY [Run_Duration] DESC
				
			  ) AS D 
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
      
    SET @TempoJobs_Table = REPLACE( REPLACE( REPLACE(@TempoJobs_Table, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align=center>')
    
	SET @TempoJobs_Table = 
			'<table cellpadding="0" cellspacing="0" border="3" >'    
            +	'<tr>
					<th width="200" bgcolor=#0B0B61><font color=white>Nome Job</font></th>
					<th width="80" bgcolor=#0B0B61><font color=white>Status</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Horário Execução</font></th>    
					<th width="80" bgcolor=#0B0B61><font color=white>Duração</font></th>
					<th width="320" bgcolor=#0B0B61><font color=white>Mensagem</font></th>        
				</tr>'    
            + REPLACE( REPLACE(@TempoJobs_Table, '&lt;', '<'), '&gt;', '>')
            + '</table>'


	/***********************************************************************************************************************************
	--	10) Queries Demoradas - Header
	***********************************************************************************************************************************/
	DECLARE @QueriesDemoradas_Header VARCHAR(MAX)
	SET @QueriesDemoradas_Header = '<font color=black size=5>'
	SET @QueriesDemoradas_Header = @QueriesDemoradas_Header + '<br/> TOP 10 - Queries Demoradas Dia Anterior (08:00 - 23:00) <br/>'
	SET @QueriesDemoradas_Header = @QueriesDemoradas_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	10) Queries Demoradas - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @QueriesDemoradas_Table VARCHAR(MAX)    
	SET @QueriesDemoradas_Table = CAST( (    
		SELECT td =	CASE WHEN [PrefixoQuery] = 'TOTAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [PrefixoQuery]	+ '</font>'
														ELSE [PrefixoQuery] END  + '</td><td>'	 +
					CASE WHEN [PrefixoQuery] = 'TOTAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [QTD]			+ '</font>'
														ELSE [QTD] END			 + '</td><td>'   +
					CASE WHEN [PrefixoQuery] = 'TOTAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Total]			+ '</font>'
														ELSE [Total] END		 + '</td><td>'   +
					CASE WHEN [PrefixoQuery] = 'TOTAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Media]			+ '</font>'
														ELSE [Media] END		 + '</td><td>'   + 
					CASE WHEN [PrefixoQuery] = 'TOTAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Menor]			+ '</font>'
														ELSE [Menor] END		 + '</td><td>'   + 
					CASE WHEN [PrefixoQuery] = 'TOTAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Maior]			+ '</font>'
														ELSE [Maior] END		 + '</td><td>'   + 
					CASE WHEN [PrefixoQuery] = 'TOTAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [Writes]			+ '</font>'
														ELSE [Writes] END		 + '</td><td>'   +
					CASE WHEN [PrefixoQuery] = 'TOTAL'	THEN ' bgcolor=#0B0B61><font color=white>' + [CPU]			+ '</font>'
														ELSE [CPU] END			 + '</td>'
		FROM (	
				SELECT	[dbo].[fncRetira_Caractere_Invalido_XML] ([PrefixoQuery])	AS [PrefixoQuery],
						ISNULL(CAST([QTD]	 AS VARCHAR), '-')						AS [QTD],
						ISNULL(CAST([Total]  AS VARCHAR), '-')						AS [Total],
						ISNULL(CAST([Media]  AS VARCHAR), '-')						AS [Media],
						ISNULL(CAST([Menor]  AS VARCHAR), '-')						AS [Menor],
						ISNULL(CAST([Maior]  AS VARCHAR), '-')						AS [Maior],
						ISNULL(CAST([Writes] AS VARCHAR), '-')						AS [Writes],
						ISNULL(CAST([CPU]	 AS VARCHAR), '-')						AS [CPU],
						[Ordem]
				FROM [dbo].[CheckList_Traces_Queries]			
			
			  ) AS D ORDER BY [Ordem], LEN([QTD]) DESC, [QTD] DESC
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)
	  
    SET @QueriesDemoradas_Table = REPLACE( REPLACE( REPLACE( REPLACE(@QueriesDemoradas_Table, '&lt;', '<'), '&gt;', '>'), 
													'<td> ', '<td align=center '),'<td>', '<td align=center>')
    
	SET @QueriesDemoradas_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
            +	'<tr>
					<th width="150" bgcolor=#0B0B61><font color=white>Prefixo Query (150 caracteres iniciais)</font></th>
					<th width="40" bgcolor=#0B0B61><font color=white>Qtd</font></th>
					<th width="60" bgcolor=#0B0B61><font color=white>Total (s)</font></th>    
					<th width="60" bgcolor=#0B0B61><font color=white>Média (s)</font></th>
					<th width="50" bgcolor=#0B0B61><font color=white>Menor (s)</font></th>       
					<th width="50" bgcolor=#0B0B61><font color=white>Maior (s)</font></th>     
					<th width="50" bgcolor=#0B0B61><font color=white>Writes</font></th> 
					<th width="60" bgcolor=#0B0B61><font color=white>CPU</font></th> 
				</tr>'    
            + REPLACE( REPLACE(@QueriesDemoradas_Table, '&lt;', '<'), '&gt;', '>')
            + '</table>'


	/***********************************************************************************************************************************
	--	11) Contadores -  Header
	***********************************************************************************************************************************/
	DECLARE @Contadores_Header VARCHAR(MAX)
	SET @Contadores_Header = '<font color=black size=5>'
	SET @Contadores_Header = @Contadores_Header + '<br/> Média Contadores Dia Anterior (08:00 - 21:00) <br/>' 
	SET @Contadores_Header = @Contadores_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	11) Contadores - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @Contadores_Table VARCHAR(MAX)    

	SET @Contadores_Table = CAST( (    
		SELECT td =				  [Hora]				 + 	
					'</td><td>' + [BatchRequests]		 + 
					'</td><td>' + [CPU]					 + 
					'</td><td>' + [Page Life Expectancy] + 	
					'</td><td>' + [User_Connection]		 +	'</td>'                                     
		FROM (           
				SELECT	ISNULL(CAST(U.[Hora]					AS VARCHAR), '-')							AS [Hora], 
						ISNULL(CAST(U.[BatchRequests]			AS VARCHAR), 'Sem registro de Contador')	AS [BatchRequests],
						ISNULL(CAST(U.[CPU]						AS VARCHAR), '-')							AS [CPU],
						ISNULL(CAST(U.[Page Life Expectancy]	AS VARCHAR), '-')							AS [Page Life Expectancy], 
						ISNULL(CAST(U.[User_Connection]			AS VARCHAR), '-')							AS [User_Connection]
				FROM [dbo].[CheckList_Contadores] AS C
				PIVOT	(
							SUM([Media]) 
							FOR [Nm_Contador] IN ([BatchRequests], [CPU], [Page Life Expectancy], [User_Connection])
						) AS U				
				
			  ) AS D ORDER BY LEN([Hora]), [Hora]
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
      
    SET @Contadores_Table = REPLACE( REPLACE( REPLACE( @Contadores_Table, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align=center>')
    
	SET @Contadores_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'
            +	'<tr>
					<th width="50" bgcolor=#0B0B61><font color=white>Hora</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Batch Requests</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>CPU</font></th>    
					<th width="120" bgcolor=#0B0B61><font color=white>Page Life Expectancy</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Número de Conexões</font></th>
				</tr>'    
            + REPLACE( REPLACE(@Contadores_Table, '&lt;', '<'), '&gt;', '>')
            + '</table>'


	/***********************************************************************************************************************************
	--	12) Fragmentação de Índices - Header
	***********************************************************************************************************************************/
	DECLARE @FragmentacaoIndice_Header VARCHAR(MAX)
	SET @FragmentacaoIndice_Header = '<font color=black size=5>'
	SET @FragmentacaoIndice_Header = @FragmentacaoIndice_Header + '<br/> TOP 10 - Fragmentação dos Índices <br/>'
	SET @FragmentacaoIndice_Header = @FragmentacaoIndice_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	12) Fragmentação de Índices - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @FragmentacaoIndice_Table VARCHAR(MAX)    

	SET @FragmentacaoIndice_Table = CAST( (
		SELECT td =				  [Dt_Referencia]				 +
					'</td><td>' + [Nm_Database]					 +
					'</td><td>' + [Nm_Tabela]					 +
					'</td><td>' + [Nm_Indice]					 +
					'</td><td>' + [Avg_Fragmentation_In_Percent] +
					'</td><td>' + [Page_Count]					 +
					'</td><td>' + [Fill_Factor]					 +
					'</td><td>' + [Compressao]					 +	'</td>'
		FROM (
				SELECT	TOP 10
						ISNULL(CONVERT(VARCHAR, [Dt_Referencia], 120), '-')				AS [Dt_Referencia], 
						[Nm_Database], 
						ISNULL([Nm_Tabela], '-')										AS [Nm_Tabela], 
						ISNULL([Nm_Indice], '-')										AS [Nm_Indice],
						ISNULL(CAST([Avg_Fragmentation_In_Percent]	AS VARCHAR), '-')	AS [Avg_Fragmentation_In_Percent],
						ISNULL(CAST([Page_Count]					AS VARCHAR), '-')	AS [Page_Count], 
						ISNULL(CAST([Fill_Factor]					AS VARCHAR), '-')	AS [Fill_Factor],
						ISNULL(	
							CASE [Fl_Compressao]
								WHEN 0 THEN 'Sem Compressão'
								WHEN 1 THEN 'Compressão de Linha' 
								WHEN 2 THEN 'Compressao de Página'
							END, '-') AS [Compressao]
				FROM [dbo].[CheckList_Fragmentacao_Indices]
				ORDER BY CAST(REPLACE([Avg_Fragmentation_In_Percent], '-', 0)  AS NUMERIC(15,2)) DESC
				
		  ) AS D 
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
      
    SET @FragmentacaoIndice_Table = REPLACE( REPLACE( REPLACE( @FragmentacaoIndice_Table, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align=center>')
    
	SET @FragmentacaoIndice_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
            +	'<tr>
					<th width="50" bgcolor=#0B0B61><font color=white>Referencia</font></th>
					<th width="150" bgcolor=#0B0B61><font color=white>Database</font></th>
					<th width="150" bgcolor=#0B0B61><font color=white>Tabela</font></th>    
					<th width="150" bgcolor=#0B0B61><font color=white>Indice</font></th>
					<th width="120" bgcolor=#0B0B61><font color=white>Fragmentacao (%)</font></th>      
					<th width="120" bgcolor=#0B0B61><font color=white>Qtd Páginas</font></th>   
					<th width="60" bgcolor=#0B0B61><font color=white>Fill Factor (%)</font></th> 
					<th width="100" bgcolor=#0B0B61><font color=white>Compressão de Dados</font></th> 
				</tr>'    
            + REPLACE( REPLACE( @FragmentacaoIndice_Table, '&lt;', '<'), '&gt;', '>')
            + '</table>'
	
	
	/***********************************************************************************************************************************
	--	13) Waits Stats -  Header
	***********************************************************************************************************************************/
	DECLARE @WaitsStats_Header VARCHAR(MAX)
	SET @WaitsStats_Header = '<font color=black size=5>'
	SET @WaitsStats_Header = @WaitsStats_Header + '<br/> Waits Stats Dia Anterior (08:00 - 23:00) <br/>'
	SET @WaitsStats_Header = @WaitsStats_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	13) Waits Stats - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @WaitsStats_Table VARCHAR(MAX)    

	SET @WaitsStats_Table = CAST( (    
		SELECT td =				  [WaitType]		+
					'</td><td>' + [Max_Log]			+
					'</td><td>' + [DIf_Wait_S]		+
					'</td><td>' + [DIf_Resource_S]	+
					'</td><td>' + [DIf_Signal_S]	+
					'</td><td>' + [DIf_WaitCount]	+
					'</td><td>' + [Last_Percentage] +	'</td>'                                     
		FROM (           
				SELECT	[WaitType], 
						ISNULL(CONVERT(VARCHAR, [Max_Log], 120),     '-') AS [Max_Log],
						ISNULL(CAST([DIf_Wait_S]		AS VARCHAR), '-') AS [DIf_Wait_S], 
						ISNULL(CAST([DIf_Resource_S]	AS VARCHAR), '-') AS [DIf_Resource_S],
						ISNULL(CAST([DIf_Signal_S]		AS VARCHAR), '-') AS [DIf_Signal_S], 
						ISNULL(CAST([DIf_WaitCount]		AS VARCHAR), '-') AS [DIf_WaitCount],
						ISNULL(CAST([Last_Percentage]	AS VARCHAR), '-') AS [Last_Percentage]
				FROM [dbo].[CheckList_Waits_Stats]				
			
		  ) AS D ORDER BY LEN([DIf_Wait_S]) DESC, [DIf_Wait_S] DESC 
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
      
    SET @WaitsStats_Table = REPLACE( REPLACE( REPLACE( @WaitsStats_Table, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align=center>')
    
	SET @WaitsStats_Table =
			'<table cellpadding="0" cellspacing="0" border="3">'    
            +	'<tr>
					<th width="210" bgcolor=#0B0B61><font color=white>WaitType</font></th>
					<th width="150" bgcolor=#0B0B61><font color=white>Data Log</font></th>    
					<th width="80" bgcolor=#0B0B61><font color=white>Wait (s)</font></th>
					<th width="80" bgcolor=#0B0B61><font color=white>Resource (s)</font></th>      
					<th width="80" bgcolor=#0B0B61><font color=white>Signal (s)</font></th>   
					<th width="80" bgcolor=#0B0B61><font color=white>Qtd Wait</font></th> 	
					<th width="70" bgcolor=#0B0B61><font color=white>Last (%)</font></th> 			
				</tr>'    
            + REPLACE( REPLACE( @WaitsStats_Table, '&lt;', '<'), '&gt;', '>')
            + '</table>'
              
    /*
    ------------------------------------------------------------------------------------------------------------------------------------
	--	14) Mirror - Header
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @MirrorHeader VARCHAR(MAX)
	SET @MirrorHeader = '<font color=black size=5>'	            
	SET @MirrorHeader = @MirrorHeader + '<br/> Situação das Databases do Mirror <br/>' 
	SET @MirrorHeader = @MirrorHeader + '</font>'	

	------------------------------------------------------------------------------------------------------------------------------------
	--	14) Mirror - Informações
	------------------------------------------------------------------------------------------------------------------------------------	
	DECLARE @MirrorTable VARCHAR(MAX)
	
	SET @MirrorTable = CAST( (    
	SELECT td =			  [Database_Name]		+ 
			'</td><td>' + [Fl_Operation_Mode]	+ 
			'</td><td>' + [Role_Mirror]			+ 
			'</td><td>' + [Mirroring_State]		+ 
			'</td><td>' + [Witness_Status]		+ 
			'</td><td>' + [Horario]				+	'</td>'
		FROM (           
				SELECT	[Database_Name],
						ISNULL([Fl_Operation_Mode], '-')	AS [Fl_Operation_Mode],	
						ISNULL([Role_Mirror], '-')			AS [Role_Mirror],
						ISNULL([Mirroring_State], '-')		AS [Mirroring_State],								
						ISNULL([Witness_Status], '-')		AS [Witness_Status],
						ISNULL([Horario], '-')				AS [Horario]
				FROM [dbo].[CheckList_Databases_Mirror]
					
			  ) AS D ORDER BY [Database_Name]
			FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
		)   

	SET @MirrorTable = REPLACE( REPLACE( REPLACE( @MirrorTable, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align = center>')
		    
	SET @MirrorTable = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
			+	'<tr>
					  <th width="50" bgcolor=#0B0B61><font color=white>Database</font></th>
					  <th width="120" bgcolor=#0B0B61><font color=white>Operation Mode</font></th>
					  <th width="120" bgcolor=#0B0B61><font color=white>Role</font></th>
					  <th width="120" bgcolor=#0B0B61><font color=white>Status</font></th>
					  <th width="120" bgcolor=#0B0B61><font color=white>Status Witness</font></th> 
					  <th width="120" bgcolor=#0B0B61><font color=white>Horario</font></th>
				</tr>'    
			  + REPLACE( REPLACE( @MirrorTable, '&lt;', '<'), '&gt;', '>')   
			+ '</table>'
	*/
    
	/***********************************************************************************************************************************
	--	14) Error Log SQL - Header
	***********************************************************************************************************************************/
	DECLARE @LogSQL_Header VARCHAR(MAX)
	SET @LogSQL_Header = '<font color=black size=5>'
	SET @LogSQL_Header = @LogSQL_Header + '<br/> TOP 100 - Error Log do SQL Server <br/>' 
	SET @LogSQL_Header = @LogSQL_Header + '</font>'

	------------------------------------------------------------------------------------------------------------------------------------
	--	14) Error Log SQL - Informações
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @LogSQL_Table VARCHAR(MAX)    

	SET @LogSQL_Table = CAST( (    
		SELECT td =				  [Dt_Log]		+ 	
					'</td><td>' + [ProcessInfo] + 
					'</td><td>' + [Text]		+ 	'</td>'                                     
		FROM (
				SELECT	TOP 100
						ISNULL(CONVERT(VARCHAR, [Dt_Log], 120), '-') AS [Dt_Log], 
						ISNULL([ProcessInfo], '-')					 AS [ProcessInfo], 
						[Text] 
				FROM [dbo].[CheckList_SQLServer_ErrorLog]

			  ) AS D ORDER BY [Dt_Log] DESC
		FOR XML PATH( 'tr' ), TYPE ) AS VARCHAR(MAX) 
	)   
	      
	SET @LogSQL_Table = REPLACE( REPLACE( REPLACE(@LogSQL_Table, '&lt;', '<'), '&gt;', '>'), '<td>', '<td align=center>')
	    
	SET @LogSQL_Table = 
			'<table cellpadding="0" cellspacing="0" border="3">'    
			+	'<tr>
					<th width="120" bgcolor=#0B0B61><font color=white>Data Log</font></th>
					<th width="80" bgcolor=#0B0B61><font color=white>Processo</font></th>
					<th width="600" bgcolor=#0B0B61><font color=white>Mensagem</font></th>              
				</tr>'    
			+ REPLACE( REPLACE( @LogSQL_Table, '&lt;', '<'), '&gt;', '>')   
			+ '</table>'
              

	/***********************************************************************************************************************************
	-- Seção em branco para dar espaço entre AS tabelas e os cabeçalhos
	***********************************************************************************************************************************/
	DECLARE @emptybody2 VARCHAR(MAX)  
	SET @emptybody2 =	''  
	SET @emptybody2 =	'<table cellpadding="5" cellspacing="5" border="0">' +              
							'<tr>
								<th width="500">               </th>
							</tr>'
							+ REPLACE( REPLACE( ISNULL(@emptybody2,''), '&lt;', '<'), '&gt;', '>')
						+ '</table>'    

	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Seta AS Informações do E-Mail
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE	@importance AS VARCHAR(6) = 'High',			
			@Reportdate DATETIME = GETDATE(),
			@recipientsList VARCHAR(8000),
			@subject AS VARCHAR(500),
			@EmailBody VARCHAR(MAX) = ''
	
	-- ALTERAR O NOME DA EMPRESA AQUI!!!
	SELECT @subject = 'CheckList Diário do Banco de Dados - NomeEmpresa - ' + @@SERVERNAME					
				
	IF ( @DisponibilidadeSQL_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @DisponibilidadeSQL_Header + @emptybody2 + @DisponibilidadeSQL_Table + @emptybody2		-- Disponibilidade SQL
	
	IF ( @EspacoDisco_Table IS NOT NULL )	
		SELECT @EmailBody = @EmailBody + @EspacoDisco_Header + @emptybody2 + @EspacoDisco_Table + @emptybody2					-- Espaço em Disco
		
	IF ( @ArquivosMDFLDF_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @ArquivosMDFLDF_Header + @emptybody2 + @ArquivosMDFLDF_Table + @emptybody2				-- Arquivos MDF e LDF
		
	IF ( @CrescimentoBases_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @CrescimentoBases_Header + @emptybody2 + @CrescimentoBases_Table + @emptybody2			-- Crescimento das Bases
		
	IF ( @CrescimentoTabelas_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @CrescimentoTabelas_Header + @emptybody2 + @CrescimentoTabelas_Table + @emptybody2		-- Crescimento das Tabelas
		
	IF ( @Backup_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @Backup_Header + @emptybody2 + @Backup_Table + @emptybody2								-- Backups Executados
		
	IF ( @JobsFailed_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @JobsFailed_Header + @emptybody2 + @JobsFailed_Table + @emptybody2						-- Jobs Failed
		
	IF ( @JobsAlterados_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @JobsAlterados_Header + @emptybody2 + @JobsAlterados_Table + @emptybody2				-- Jobs Alterados
		
	IF ( @TempoJobs_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @TempoJobs_Header + @emptybody2 + @TempoJobs_Table + @emptybody2						-- Jobs Demorados
		
	IF ( @QueriesDemoradas_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @QueriesDemoradas_Header + @emptybody2 + @QueriesDemoradas_Table + @emptybody2			-- Queries Demoradas
		
	IF ( @Contadores_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @Contadores_Header + @emptybody2 + @Contadores_Table + @emptybody2						-- Contadores
		
	IF ( @FragmentacaoIndice_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @FragmentacaoIndice_Header + @emptybody2 + @FragmentacaoIndice_Table + @emptybody2		-- Fragmentação Índice
		
	IF ( @WaitsStats_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @WaitsStats_Header + @emptybody2 + @WaitsStats_Table + @emptybody2						-- Waits Stats
		
	--IF ( @MirrorTable IS NOT NULL )
	--	SELECT @EmailBody = @EmailBody + @MirrorHeader + @emptybody2 + @MirrorTable + @emptybody2								-- Database Mirror
		
	IF ( @LogSQL_Table IS NOT NULL )
		SELECT @EmailBody = @EmailBody + @LogSQL_Header + @emptybody2 + @LogSQL_Table + @emptybody2								-- Error Log SQL

	/*
	-- P/ TESTE
	select  @EmailBody, 
			, @DisponibilidadeSQL_Header, @emptybody2, @DisponibilidadeSQL_Table, @emptybody2 AS [DisponibilidadeSQL]	-- Disponibilidade SQL
			, @EspacoDisco_Header, @emptybody2, @EspacoDisco_Table, @emptybody2 AS [Disco]								-- Espaço em Disco
			, @ArquivosMDFLDF_Header, @emptybody2, @ArquivosMDFLDF_Table, @emptybody2 AS [MDF_LDF]						-- MDF e LDF
			, @CrescimentoBases_Header, @emptybody2, @CrescimentoBases_Table, @emptybody2 AS [Bases]					-- Crescimento Bases
			, @CrescimentoTabelas_Header, @emptybody2, @CrescimentoTabelas_Table, @emptybody2 AS [Tabelas]				-- Crescimento Tabelas
			, @Backup_Header, @emptybody2, @Backup_Table, @emptybody2 AS [Backup]										-- Backup
			, @JobsFailed_Header, @emptybody2, @JobsFailed_Table, @emptybody2 AS [JobsFailed]							-- JobsFailed
			, @JobsAlterados_Header, @emptybody2, @JobsAlterados_Table, @emptybody2 AS [JobsAlterados]					-- Jobs Alterados
			, @TempoJobs_Header, @emptybody2, @TempoJobs_Table, @emptybody2 AS [JobsDemorados]							-- Tempo Jobs
			, @QueriesDemoradas_Header, @emptybody2, @QueriesDemoradas_Table, @emptybody2 AS [QueriesDemoradas]			-- Queries Demoradas
			, @Contadores_Header, @emptybody2, @Contadores_Table, @emptybody2 AS [Contadores]							-- Contadores
			, @FragmentacaoIndice_Header, @emptybody2, @FragmentacaoIndice_Table, @emptybody2 AS [FragmentacaoIndice]	-- Fragmentação Índice
			, @WaitsStats_Header , @emptybody2, @WaitsStats_Table, @emptybody2 AS [WaitsStats]							-- WaitsStats
			--, @MirrorHeader , @emptybody2 , @MirrorTable , @emptybody2 Mirror											-- Database Mirror
			, @LogSQL_Header, @emptybody2, @LogSQL_Table, @emptybody2 AS [ErrorLogSQL]									-- Error Log SQL
	*/
	
	
	/***********************************************************************************************************************************
	-- Inclui uma imagem com link para o site do Fabricio Lima
	***********************************************************************************************************************************/
	select @EmailBody = @EmailBody + '<br/><br/>' +
				'<a href="http://www.fabriciolima.net" target=”_blank”> 
					<img src="http://www.fabriciolima.net/wp-content/uploads/2016/04/Logo_Fabricio-Lima_horizontal.png" height="100" width="400"/></a>'
				

	/***********************************************************************************************************************************
	-- Envia o E-Mail do CheckList do Banco de Dados
	***********************************************************************************************************************************/
	EXEC [msdb].[dbo].[sp_send_dbmail]  
			@profile_name = 'MSSQLServer',
			@recipients = 'fabricioflima@gmail.com',
			@subject = @subject,
			@body = @EmailBody,    
			@body_format = 'HTML',    
			@importance = @importance
END


GO

USE [msdb]

GO

/***********************************************************************************************************************************
-- CRIA JOB: [DBA - CheckList do Banco de Dados]
***********************************************************************************************************************************/
BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Seleciona a Categoria do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS ( SELECT [name] FROM [msdb].[dbo].[syscategories] WHERE [name] = N'Database Maintenance' AND [category_class] = 1 )
	BEGIN
		EXEC @ReturnCode = [msdb].[dbo].[sp_add_category] @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_job]
			@job_name = N'DBA - CheckList do Banco de Dados', 
			@enabled = 1, 
			@notify_level_eventlog = 0, 
			@notify_level_email = 0, 
			@notify_level_netsend = 0, 
			@notify_level_page = 0, 
			@delete_level = 0, 
			@description = N'JOB responsável por enviar o E-Mail com o CheckList do Banco de Dados.', 
			@category_name = N'Database Maintenance', 
			@owner_login_name = N'sa', 
			@job_id = @jobId OUTPUT
											
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Step 1 do JOB - Carga Tabelas CheckList
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobstep]
			@job_id = @jobId,
			@step_name = N'DBA - Carga Tabelas CheckList',
			@step_id = 1,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL',
			@command = N'EXEC [dbo].[stpCheckList_Espaco_Disco]				-- Espaço em Disco
EXEC [dbo].[stpCheckList_Arquivos_MDF_LDF]			-- Arquivos MDF e LDF
EXEC [dbo].[stpCheckList_Database_Growth]			-- Crescimento das Bases
EXEC [dbo].[stpCheckList_Table_Growth]				-- Crescimento das Tabelas
EXEC [dbo].[stpCheckList_Backups_Executados]		-- Backups Executados
EXEC [dbo].[stpCheckList_Jobs_Failed]				-- Jobs Failed
EXEC [dbo].[stpCheckList_Alteracao_Jobs]			-- Jobs Alterados
EXEC [dbo].[stpCheckList_Job_Demorados]				-- Jobs Demorados
EXEC [dbo].[stpCheckList_Traces_Queries]			-- Queries Demoradas
EXEC [dbo].[stpCheckList_Contadores]				-- Contadores
EXEC [dbo].[stpCheckList_Fragmentacao_Indices]		-- Fragmentacao Índice
EXEC [dbo].[stpCheckList_Waits_Stats]				-- Waits Stats
EXEC [dbo].[stpCheckList_SQLServer_ErrorLog]		-- Error Log SQL',		
			@database_name = N'Traces',
			@flags = 0
							
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Step 2 do JOB - Envio de E-mail em HTML com o CheckList do Banco de Dados
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobstep]
			@job_id = @jobId, 
			@step_name = N'DBA - Envio de E-mail em HTML com o CheckList do Banco de Dados', 
			@step_id = 2, 
			@cmdexec_success_code = 0,
			@on_success_action = 1,
			@on_success_step_id = 0, 
			@on_fail_action = 2,
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'EXEC [dbo].[stpEnvia_CheckList_Diario_DBA]', 
			@database_name = N'Traces', 
			@flags = 0

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_update_job] @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Schedule do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @Dt_Atual VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 112)
		
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobschedule]
			@job_id = @jobId, 
			@name = N'DIÁRIO - 07:30', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1 , 
			@freq_subday_type = 1, 
			@freq_subday_interval = 0, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual,
			@active_end_date = 99991231, 
			@active_start_time = 73000, 
			@active_end_time = 235959, 
			@schedule_uid = N'5db1dad0-4ec4-4cb2-8bb4-6841a8a90cfc'
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobserver] @job_id = @jobId, @server_name = N'(local)'
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    
EndSave:

GO