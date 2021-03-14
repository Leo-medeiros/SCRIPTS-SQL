use Traces
go

--exec stp_Load_all_Events  @help = 1 @fl_language = 'pt'
IF (OBJECT_ID('dbo.stp_Load_all_Events') IS  NULL) EXEC('CREATE PROCEDURE dbo.stp_Load_all_Events AS SELECT 1')
GO
ALTER PROCEDURE stp_Load_all_Events (@fl_language VARCHAR(2)= NULL, @help BIT = 0, @id VARCHAR(8) = NULL )


-----------------------------------------------------------------
-- Procedure stp_Load_all_Events, for help in creating a trace on profiler with t-sql
--
-- version 0.0.1 - created by: Leonardo Medeiros
--
-- last update = 02/01/2021
-----------------------------------------------------------------

AS
BEGIN

IF @help = 1 
BEGIN
		PRINT '/-----------------------------------------------------------/'
		PRINT 'Procedure para exibir os valores do event, para utilizarmos na query de criar um trace do profiler via t-sql'
		PRINT 'Alguns parametros que podem ser usados na execu��o dessa procedure'
		PRINT '                                                                                                             '
		PRINT '@fl_language = se colocar pt ira exbiir o resultado completo no idioma portugues, se digitar en, ir� exibir em ingl�s,'
		PRINT'se nao colocar nada, o sql gera com base no idioma da sua instancia'
		PRINT ''
		PRINT '@id = por default, a proc vai exibir os dados sem utilizar filtro no where, ira exibir os 182 eventos,' 
		PRINT'se voc� quiser, filtrar algum pelo ID, deve informar na variavel @ID = 10 por exemplo, �POR�M S� FUNCIONA QUANDO O IDIMOA FOR  INGL�S'
		PRINT '/-----------------------------------------------------------/'
		RETURN;
END

SET NOCOUNT ON


		
    SET @fl_language = (CASE
        WHEN NULLIF(LTRIM(RTRIM(@fl_language)), '') IS NULL THEN (SELECT CASE WHEN [value] IN (5, 7, 27) THEN 'pt' ELSE 'en' END FROM sys.configurations WHERE [name] = 'default language')
        ELSE @fl_language
		END)
-----------------
-- idioma
-----------------



IF @fl_language = 'pt'
BEGIN 
		IF OBJECT_ID('tempdb..#TracesEvent') IS NOT NULL
		DROP TABLE tempdb..#TracesEvent
		CREATE TABLE tempdb..#TracesEvent 
		(
		numero_do_evento varchar(8),
		Nome_Do_Evento varchar(200),
		Descricao varchar(max))
		
		CREATE CLUSTERED INDEX  SK01_#TracesEvent ON #TracesEvent (numero_do_evento)
		
		CREATE NONCLUSTERED INDEX SK21_#TracesEvent ON #TracesEvent (numero_do_evento) INCLUDE (Nome_Do_Evento,Descricao)
		
		INSERT INTO tempdb..#TracesEvent  VALUES (
		'0-9', 'Reservado','Reservado'),
		('10','RPC:Completed','Ocorre quando uma RPC (chamada de procedimento remoto) � conclu�da'),
		('11' ,'RPC:Starting', 	'Ocorre quando uma RPC � iniciada'),
		('12','SQL:BatchCompleted','Ocorre quando um lote Transact-SQL � conclu�do'),
		('13','SQL:BatchStarting','Ocorre quando um lote Transact-SQL � iniciado'),
		('14','Auditar logon','Ocorre quando um usu�rio faz logoff do SQL Server'),
		('15','Auditar logoff','Ocorre quando um usu�rio faz logoff do SQL Server'),
		('16' ,'Attention' ,'Ocorre quando eventos de aten��o, como solicita��es de interrup��o de cliente ou conex�es de cliente interrompidas, acontecem'),
		('17','ExistingConnection', 	'Detecta toda a atividade dos usu�rios conectados ao SQL Server antes do in�cio do rastreamento')
		,('18 	','Audit Server Starts and Stops','Ocorre quando o estado de servi�o do SQL Server � modificado.')
		,('19 	','DTCTransaction','Rastreia as transa��es do MS DTC (Microsoft Distributed Transaction Coordinator) entre dois ou mais bancos de dados.')
		,('20 	','Audit Login Failed','Indica que uma tentativa de logon no SQL Server de um cliente falhou.')
		,('21 	','EventLog','Indica que os eventos foram registrados no log de aplicativo do Windows.')
		,('22 	','ErrorLog','Indica que eventos de erro foram registrados no log de erros do SQL Server .')
		,('23 	','Lock:Released','Indica que um bloqueio em um recurso, como uma p�gina, foi liberado.')
		,('24 	','Lock:Acquired','Indica a aquisi��o de um bloqueio em um recurso, como uma p�gina de dados.')
		,('25 	','Lock:Deadlock','Indica que duas transa��es simult�neas fizeram deadlock uma na outra ao tentar obter bloqueios incompat�veis em recursos de propriedade da outra transa��o.')
		,('26 	','Lock:Cancel','Indica que a aquisi��o de um bloqueio em um recurso foi cancelada (por exemplo, devido a um deadlock')
		,('27 	','Lock:Timeout ','Indica que uma solicita��o para um bloqueio em um recurso, como uma p�gina, expirou por causa de outra transa��o que estava mantendo um bloqueio no recurso necess�rio. O tempo limite � determinado pela fun��o @ @LOCK_TIMEOUT e pode ser definido com a instru��o set LOCK_TIMEOUT.')
		,('28 	','Degree of Parallelism Event (7.0 Insert)','Acontece antes de uma instru��o SELECT, INSERT ou UPDATE ser executada')
		,('29-31 ','	Reservado' ,'Use o Evento 28 em vez disso')		
		,('32 ','Reservado',	'Reservado')
		,('33' ,'Exce��o','Indica que uma exce��o ocorreu no SQL Server')
		,('34 	','SP:CacheMiss' ,'Indica quando um procedimento armazenado n�o � localizado no cache de procedimento')
		,('35 	','SP:CacheInsert','Indica quando um item � inserido no cache de procedimento.')
		,('36 	','SP:CacheRemove ','Indica quando um item � removido do cache de procedimento.')
		,('37 	','SP:Recompile','Indica que um procedimento armazenado foi recompilado.')
		,('38 	','SP:CacheHit','Indica quando um procedimento armazenado � localizado no cache de procedimento.')
		,('39 	','Preterido', 'Preterido')
		,('40 	','SQL:StmtStarting','Ocorre quando a instru��o Transact-SQL � iniciada.')
		,('41 	','SQL:StmtCompleted','Ocorre quando a instru��o Transact-SQL � conclu�da.')
		,('42 	','SP:Starting','Indica quando o procedimento armazenado � iniciado.')
		,('43 	','SP:Completed','Indica quando o procedimento armazenado � conclu�do.')
		,('44 	','SP:StmtStarting','Indica que a execu��o de uma instru��o Transact-SQL em um procedimento armazenado foi iniciada.')
		,('45 	','SP:StmtCompleted','Indica que a execu��o de uma instru��o Transact-SQL em um procedimento armazenado foi conclu�da.')
		,('46 	','Object:Created','Indica que um objeto foi criado, tal como para as instru��es CREATE INDEX, CREATE TABLE e CREATE DATABASE.')
		,('47 	','Object:Deleted','Indica que um objeto foi exclu�do, tal como nas instru��es DROP INDEX e DROP TABLE.')
		,('48 	','Reservado','')
		,('49 	','Reservado','')
		,('50 	','SQL Transaction','Rastreia as seguintes instru��es Transact-SQL: BEGIN TRAN, COMMIT TRAN, SAVE TRAN e ROLLBACK TRAN.')
		,('51 	','Scan:Started' ,'Indica quando foi iniciada uma verifica��o de tabela ou de �ndice.')
		,('52 	','Scan:Stopped','Indica quando foi interrompida uma verifica��o de tabela ou de �ndice.')
		,('53 	','CursorOpen','Indica quando um cursor � aberto em uma instru��o Transact-SQL por ODBC, OLE DB ou DB-Library.')
		,('54 	','TransactionLog','Rastreia quando as transa��es s�o gravadas no log de transa��es.')
		,('55 	','Hash Warning	','Indica que uma opera��o de hash (por exemplo, jun��o hash, agrega��o de hash, uni�o de hash e distin��o de hash) que n�o est� sendo processada em uma parti��o de buffer foi revertida para um plano alternativo. Isso pode ocorrer por causa de profundidade de recurs�o, distor��o de dados, sinalizadores de rastreamento ou contagem de bits.')
		,('56-57 ','	Reservado ','')
		,('58 	','Auto Stats','Indica que ocorreu uma atualiza��o autom�tica de estat�sticas de �ndice.')
		,('59 	','Lock:Deadlock Chain','Produzido para cada um dos eventos que resultam no deadlock.')
		,('60 	','Lock:Escalation ','Indica que um bloqueio mais refinado foi convertido em um bloqueio mais r�stico (por exemplo, um bloqueio de p�gina escalonado ou convertido em um bloqueio TABLE ou HoBT).')
		,('61 	','OLE DB Errors','Indica que ocorreu um erro OLE DB.')
		,('62-66 ','	Reservado ','')
		,('67 	','Execution Warnings','Indicam qualquer aviso que ocorreu durante a execu��o de uma instru��o ou um procedimento armazenado do SQL Server.')
		,('68 	','Showplan Text (Unencoded)','Exibe a �rvore de plano da instru��o Transact-SQL executada.')
		,('69 	','Sort Warnings','Indica opera��es de classifica��o que n�o cabem na mem�ria. Isso n�o inclui opera��es de classifica��o envolvendo a cria��o de �ndices, mas somente opera��es de classifica��o em uma consulta (como uma cl�usula ORDER BY usada em uma instru��o SELECT).')
		,('70 	','CursorPrepare','Indica quando um cursor em uma instru��o Transact-SQL est� pronto para ser usado por ODBC, OLE DB ou DB-Library.')
		,('71 	','Prepare SQL ','ODBC, OLE DB ou DB-Library preparou uma instru��o Transact-SQL ou instru��es para uso.')
		,('72 	','Exec Prepared SQL','ODBC, OLE DB ou DB-Library executou uma instru��o ou instru��es Transact-SQL preparadas.')
		,('73 	','Unprepare SQL','ODBC, OLE DB ou DB-Library despreparou (excluiu) uma instru��o ou instru��es Transact-SQL preparadas.')
		,('74 	','CursorExecute','Um cursor anteriormente preparado em uma instru��o Transact-SQL por ODBC, OLE DB ou DB-Library � executado.')
		,('75 	','CursorRecompile ','Um cursor aberto em uma instru��o Transact-SQL por ODBC, OLE DB, ou DB-Library foi recompilado diretamente ou devido a uma altera��o de esquema. Disparado para cursores ANSI e n�o ANSI')
		,('76 	','CursorImplicitConversion','Um cursor em uma instru��o Transact-SQL � convertido de um tipo para outro pelo SQL Server. Disparado para cursores ANSI e n�o ANSI.')
		,('77 	','CursorUnprepare','Um cursor preparado em uma instru��o Transact-SQL � despreparado (exclu�do) por ODBC, OLE DB ou DB-Library.')
		,('78 	','CursorClose ','Um cursor anteriormente aberto em uma instru��o Transact-SQL por ODBC, OLE DB, ou DB-Library foi fechado.')
		,('79 	','Missing Column Statistics','Estat�sticas de coluna que podem ter sido �teis para o otimizador n�o est�o dispon�veis.')
		,('80 	','Missing Join Predicate','A consulta que est� sendo executada n�o tem nenhum predicado de jun��o. Isso pode resultar em uma consulta de longa execu��o.')
		,('81 	','Server Memory Change','O uso de mem�ria do SQL Server aumentou ou diminuiu em 1 megabyte (MB) ou em 5 por cento da mem�ria m�xima de servidor, o que for maior.')
		,('82-91 ','	User Configurable (0-9)','Dados de evento definidos pelo usu�rio.')
		,('92 	','Data File Auto Grow','Indica que um arquivo de dados foi automaticamente estendido pelo servidor.')
		,('93 	','Log File Auto Grow ','Indica que um arquivo de log foi automaticamente estendido pelo servidor.')
		,('94 	','Data File Auto Shrink ','Indica que um arquivo de dados foi automaticamente reduzido pelo servidor.')
		,('95 	','Log File Auto Shrink ','Indica que um arquivo de log foi automaticamente reduzido pelo servidor.')
		,('96 	','Showplan Text','Exibe a �rvore de plano de consulta da instru��o SQL a partir do otimizador de consulta. Observe que a coluna TextData n�o cont�m o Showplan para esse evento.')
		,('97 	','Showplan All','Exibe o plano de consulta com detalhes completos de tempo de compila��o da instru��o SQL executada. Observe que a coluna TextData n�o cont�m o Showplan para esse evento.')
		,('98 	','Showplan Statistics Profile','Exibe o plano de consulta com detalhes completos de tempo de execu��o da instru��o SQL executada. Observe que a coluna TextData n�o cont�m o Showplan para esse evento.')
		,('99 	','Reservado','')
		,('100 	','RPC Output Parameter','Produz valores de sa�da dos par�metros para todo RPC.')
		,('101 	','Reservado','')
		,('102 	','Audit Database Scope GDR ','Ocorre sempre que GRANT, DENY, REVOKE � emitido para uma permiss�o de instru��o por qualquer usu�rio no SQL Server para a��es somente de banco de dados, como conceder permiss�es em um banco de dados.')
		,('103 	','Evento Audit Object GDR','Ocorre sempre que um GRANT, DENY, REVOKE para uma permiss�o de objeto � emitido por qualquer usu�rio no SQL Server.')
		,('104 	','Evento Audit AddLogin','Ocorre quando um SQL Server logon � adicionado ou removido; por sp_addlogin e sp_droplogin.')
		,('105 	','Evento Audit Login GDR','Ocorre quando um direito de logon do Windows � adicionado ou removido; para sp_grantlogin, sp_revokelogine sp_denylogin.')
		,('106 	','Evento Audit Login Change Property','Ocorre quando uma propriedade de um logon, exceto senhas, � modificada; para sp_defaultdb e sp_defaultlanguage.')
		,('107 	','Evento Audit Login Change Password','Ocorre quando uma senha de logon do SQL Server � alterada. As senhas n�o s�o registradas.')
		,('108 	','Evento Audit Add Login to Server Role','Ocorre quando um logon � adicionado ou removido de uma fun��o de servidor fixa; para sp_addsrvrolemembere sp_dropsrvrolemember.')
		,('109 	','Evento Audit Add DB User','Ocorre quando um logon � adicionado ou removido como um usu�rio de banco de dados (Windows ou SQL Server ) para um banco de dados; para sp_grantdbaccess, sp_revokedbaccess, sp_addusere sp_dropuser.')
		,('110 	','Evento Audit Add Member to DB Role','Ocorre quando um logon � adicionado ou removido como um usu�rio de banco de dados (fixo ou definido pelo usu�rio) para um banco de dados; para sp_addrolemember, sp_droprolemembere sp_changegroup.')
		,('111 	','Evento Audit Add Role ','Ocorre quando um logon � adicionado ou removido como um usu�rio de banco de dados para um banco de dados; para sp_addrole e sp_droprole.')
		,('112 	','Evento Audit App Role Change Password ','Ocorre quando uma senha de uma fun��o de aplicativo � alterada.')
		,('113 	','Evento Audit Statement Permission','Ocorre quando uma permiss�o de instru��o (como CREATE TABLE) � usada.')
		,('114 	','Evento Audit Schema Object Access','Ocorre quando uma permiss�o de objeto (como SELECT) � usada, com �xito ou n�o.')
		,('115 	','Audit Backup/Restore Event','Ocorre quando um comando BACKUP ou RESTORE � emitido.')
		,('116 	','Evento Audit DBCC ','Ocorre quando comandos DBCC s�o emitidos.')
		,('117 	','Evento Audit Change Audit ','Ocorre quando s�o feitas modifica��es de rastreamento de auditoria.')
		,('118 	','Evento Audit Object Derived Permission','Ocorre quando um comando de objeto CREATE, ALTER e DROP � emitido.')
		,('119 	','Evento OLEDB Call','Ocorre quando as chamadas de provedor OLE DB s�o feitas para consultas distribu�das e procedimentos armazenados remotos.')
		,('120 	','Evento OLEDB QueryInterface','Ocorre quando OLE DB chamadas de QueryInterface s�o feitas para consultas distribu�das e procedimentos armazenados remotos.')
		,('121 	','Evento OLEDB DataRead','Ocorre quando uma chamada de solicita��o de dados � feita ao provedor OLE DB.')
		,('122 	','Showplan XML','Ocorre quando uma instru��o SQL � executada. Inclua este evento para identificar operadores de plano de execu��o. Cada evento � armazenado em um documento XML bem formado. Observe que a coluna Binary desse evento cont�m o Showplan codificado. Use o SQL Server Profiler para abrir o rastreamento e exibir o plano de execu��o.')
		,('123 	','SQL:FullTextQuery','Ocorre quando uma consulta de texto completo � executada.')
		,('124 	','Broker:Conversation','Relata o progresso de uma conversa do Agente de Servi�o.')
		,('125 	','Deprecation Announcement ','Ocorre quando � usado um recurso que ser� removido de uma vers�o futura do SQL Server.')
		,('126 	','Deprecation Final Support','Ocorre quando � usado um recurso que ser� removido da pr�xima vers�o principal do SQL Server.')
		,('127 	','Evento Exchange Spill','Ocorre quando os buffers de comunica��o em um plano de consulta paralelo foram gravados temporariamente no banco de dados tempdb .')
		,('128 	','Evento Audit Database Management','Ocorre quando um banco de dados � criado, alterado ou descartado.')
		,('129 	','Evento Audit Database Object Management','Ocorre quando uma instru��o CREATE, ALTER ou DROP � executada em objetos de banco de dados, como esquemas.')
		,('130 	','Evento Audit Database Principal Management ','Ocorre quando os principais, como usu�rios, s�o criados, alterados ou descartados de um banco de dados.')
		,('131 	','Evento Audit Schema Object Management','Ocorre quando objetos de servidor s�o criados, alterados ou descartados.')
		,('132 	','Evento Audit Server Principal Impersonation','Ocorre quando h� uma representa��o no escopo de servidor, como EXECUTE LOGIN AS.')
		,('133 	','Evento Audit Database Principal Impersonation','Ocorre quando uma representa��o acontece no escopo de banco de dados, como EXECUTE AS USER ou SETUSER.')
		,('134 	','Evento Audit Server Object Take Ownership','Ocorre quando o propriet�rio � alterado para objetos no escopo de servidor.')
		,('135 	','Evento Audit Database Object Take Ownership','Ocorre quando acontece uma altera��o de propriet�rio para objetos no escopo de banco de dados.')
		,('136 	','Broker:Conversation Group' ,'Ocorre quando o Agente de Servi�o cria um novo grupo de conversa ou descarta um existente.')
		,('137 	','Blocked Process Report','Ocorre quando um processo foi bloqueado para mais do que um per�odo especificado. N�o inclui processos do sistema ou processos que est�o aguardando em recursos n�o detect�veis por deadlock. Use sp_configure para configurar o limite e a frequ�ncia em que os relat�rios s�o gerados.')
		,('138 	','Broker:Connection ','Relata o status de uma conex�o de transporte administrada pelo Agente de Servi�o.')
		,('139 	','Broker:Forwarded Message Sent','Ocorre quando o Agente de Servi�o encaminha uma mensagem.')
		,('140 	','Broker:Forwarded Message Dropped','Ocorre quando o Agente de Servi�o descarta uma mensagem destinada a ser encaminhada.')
		,('141 	','Broker:Message Classify','Ocorre quando o Agente de Servi�o determina o roteamento para uma mensagem.')
		,('142 	','Broker:Transmission' ,'Indica que erros ocorreram na camada de transporte do Agente de Servi�o. O n�mero do erro e os valores de estado indicam a origem do erro.')
		,('143 ','Broker:Queue Disabled','Indica que uma mensagem suspeita foi detectada porque havia cinco revers�es de transa��o sucessivas em uma fila do Agente de Servi�o. O evento cont�m a ID do banco de dados e a ID de fila da fila que cont�m a mensagem suspeita.')
		,('144-145','Reservado','') 									
		,('146 	','Showplan XML Statistics Profile','Ocorre quando uma instru��o SQL � executada. Identifica os operadores de plano de execu��o e exibe dados de tempo de compila��o completos. Observe que a coluna Binary desse evento cont�m o Showplan codificado. Use o SQL Server Profiler para abrir o rastreamento e exibir o plano de execu��o.')
		,('148 	','Deadlock Graph','Ocorre quando uma tentativa para adquirir um bloqueio � cancelada porque a tentativa fazia parte de um deadlock e foi escolhida como a v�tima de deadlock. Fornece uma descri��o XML de um deadlock.')
		,('149 	','Broker:Remote Message Acknowledgement','Ocorre quando o Agente de Servi�o envia ou recebe uma confirma��o de mensagem.')
		,('150 	','Trace File Close','Ocorre quando um arquivo de rastreamento � fechado durante a sua substitui��o.')
		,('151 	','Reservado '	,'')
		,('152 	','Audit Change Database Owner','Ocorre quando a instru��o ALTER AUTHORIZATION � usada para alterar o propriet�rio de um banco de dados e as permiss�es s�o marcadas para fazer isso.')
		,('153 	','Evento Audit Schema Object Take Ownership','Ocorre quando a instru��o ALTER AUTHORIZATION � usada para atribuir um propriet�rio a um objeto e as permiss�es para fazer isso est�o marcadas.')
		,('154 	','Reservado' ,'')
		,('155 	','FT:Crawl Started ','Ocorre quando um rastreamento (popula��o) de texto completo � iniciado. Use para verificar se uma solicita��o de rastreamento est� sendo selecionada por tarefas de trabalhado.')
		,('156 	','FT:Crawl Stopped','Ocorre quando um rastreamento (popula��o) de texto completo � interrompido. As interrup��es acontecem quando um rastreamento � conclu�do com �xito ou quando ocorre um erro fatal.')
		,('157 	','FT:Crawl Aborted','Ocorre quando uma exce��o � encontrada em um rastreamento de texto completo. Em geral, provoca a interrup��o do rastreamento de texto completo.')
		,('158 	','Audit Broker Conversation' ,'Relata mensagens de auditoria relacionadas � seguran�a de di�logo do Agente de Servi�o.')
		,('159 	','Audit Broker Login','Relata mensagens de auditoria relacionadas � seguran�a de transporte do Agente de Servi�o.')
		,('160 	','Broker:Message Undeliverable','Ocorre quando o Agente de Servi�o n�o pode reter uma mensagem recebida que deve ser entregue a um servi�o.')
		,('161 	','Broker:Corrupted Message','Ocorre quando o Agente de Servi�o recebe uma mensagem corrompida.')
		,('162 	','User Error Message' ,'Exibe mensagens de erro que os usu�rios veem no caso de um erro ou uma exce��o.')
		,('163 	','Broker:Activation' ,'Ocorre quando um monitor de fila inicia um procedimento armazenado de ativa��o, envia uma notifica��o QUEUE_ACTIVATION ou quando um procedimento armazenado de ativa��o iniciado por um monitor de fila � encerrado.')
		,('164 	','Object:Altered','Ocorre quando um objeto de banco de dados � alterado.')
		,('165 	','Performance statistics'	,'Ocorre quando um plano de consulta compilado foi armazenado em cache pela primeira vez, recompilado ou removido do cache do plano.')
		,('166 	','SQL:StmtRecompile','Ocorre quando uma recompila��o do n�vel de instru��o acontece.')
		,('167 	','Database Mirroring State Change','Ocorre quando o estado de um banco de dados espelho � alterado.')
		,('168 	','Showplan XML For Query Compile','Ocorre quando uma instru��o SQL � compilada. Exibe os dados de tempo de compila��o completos. Observe que a coluna Binary desse evento cont�m o Showplan codificado. Use o SQL Server Profiler para abrir o rastreamento e exibir o plano de execu��o.')
		,('169 	','Showplan All For Query Compile','Ocorre quando uma instru��o SQL � compilada. Exibe dados completos e em tempo de compila��o. Use para identificar operadores de plano de execu��o')
		,('170 	','Evento Audit Server Scope GDR','Indica que ocorreu um evento de concess�o, recusa ou revoga��o para permiss�es no escopo de servidor, tal como criar um logon.')
		,('171 	','Evento Audit Server Object GDR','Indica que ocorreu um evento de concess�o, nega��o ou revoga��o para um objeto de esquema, tal como uma tabela ou fun��o.')
		,('172 	','Evento Audit Database Object GDR','Indica que ocorreu um evento de concess�o, nega��o ou revoga��o para objetos de banco de dados, tal como assemblies e esquemas.')
		,('173 	','Evento Audit Server Operation','Ocorre quando s�o usadas opera��es de Seguran�a Auditoria, tal como alterar configura��es, recursos, acesso externo ou autoriza��o.')
		,('175 	','Evento Audit Server Alter Trace','Ocorre quando uma instru��o verifica a permiss�o ALTER TRACE.')
		,('176 	','Evento Audit Server Object Management','Ocorre quando objetos de servidor s�o criados, alterados ou descartados.')
		,('177 	','Evento Audit Server Principal Management' ,'Ocorre quando principais s�o criados, alterados ou descartados.')
		,('178 	','Evento Audit Database Operation','Ocorre quando ocorrem opera��es de banco de dados, tal como ponto de verifica��o ou notifica��o de consulta de assinatura.')
		,('180 	','Evento Audit Database Object Access','Ocorre quando s�o acessados objetos de banco de dados, tal como esquemas.')
		,('181 	','TM: Begin Tran starting','Ocorre quando uma solicita��o BEGIN TRANSACTION � iniciada.')
		,('182 	','TM: Begin Tran completed ','Ocorre quando uma solicita��o BEGIN TRANSACTION � conclu�da.')
		,('183 	','TM: Promote Tran starting','Ocorre quando uma solicita��o PROMOTE TRANSACTION � iniciada.')
		,('184 	','TM: Promote Tran completed' ,'Ocorre quando uma solicita��o PROMOTE TRANSACTION � conclu�da.')
		,('185 	','TM: Commit Tran starting ','Ocorre quando uma solicita��o COMMIT TRANSACTION � iniciada.')
		,('186 	','TM: Commit Tran completed ','Ocorre quando uma solicita��o COMMIT TRANSACTION � conclu�da.')
		,('187 	','TM: Rollback Tran starting ','Ocorre quando uma solicita��o ROLLBACK TRANSACTION � iniciada.')
		,('188 	','TM: Rollback Tran completed','Ocorre quando uma solicita��o ROLLBACK TRANSACTION � conclu�da.')
		,('189 	','Bloqueio: tempo limite (tempo limite > 0)','Ocorre quando uma solicita��o para um bloqueio em um recurso, como uma p�gina, expira.')
		,('190 	','Progress Report: Online Index Operation','Relata o progresso de uma opera��o de cria��o de �ndice online quando o processo de cria��o est� sendo executado.')
		,('191 	','TM: Save Tran starting','Ocorre quando uma solicita��o SAVE TRANSACTION � iniciada.')
		,('192 	','TM: Save Tran completed','Ocorre quando uma solicita��o SAVE TRANSACTION � conclu�da.')
		,('193 	','Background Job Error','Ocorre quando um trabalho em segundo plano � terminado de maneira anormal.')
		,('194 	','OLEDB Provider Information','Ocorre quando uma consulta distribu�da � executada e coleta informa��es que correspondem � conex�o de provedor.')
		,('195 	','Mount Tape','Ocorre quando uma solicita��o de montagem de fita � recebida.')
		,('196 	','Assembly Load','Ocorre quando acontece uma solicita��o para carregar um assembly CLR.')
		,('197 	','Reservado ','')
		,('198 	','XQuery Static Type','Ocorre quando uma express�o XQuery � executada. Essa classe de evento fornece o tipo est�tico da express�o XQuery.')
		,('199 	','QN: subscription ','Ocorre quando um registro de consulta n�o pode ser assinado. A coluna TextData cont�m informa��es sobre o evento.')
		,('200 	','QN: parameter table','Informa��es sobre assinaturas ativas s�o armazenadas em tabelas de par�metro internas. Esta classe de evento ocorre quando uma tabela de par�metro � criada ou exclu�da. Normalmente, essas tabelas s�o criadas ou exclu�das quando o banco de dados � reiniciado. A coluna TextData cont�m informa��es sobre o evento.')
		,('201 	','QN: template','Um modelo de consulta representa uma classe de consultas de assinatura. Normalmente, as consultas de mesma classe s�o id�nticas com exce��o dos valores de par�metro. Essa classe de evento ocorre quando uma nova solicita��o de assinatura se enquadra em uma classe j� existente de (Match), uma nova classe (Create) ou uma classe Drop, que indica a limpeza de modelos para classes de consulta sem assinaturas ativas. A coluna TextData cont�m informa��es sobre o evento.')
		,('202 	','QN: dynamics','Rastreia atividades internas de notifica��es de consulta. A coluna TextData cont�m informa��es sobre o evento.')
		,('212 	','Aviso de bitmap','Indica quando os filtros do bitmap foram desabilitados em uma consulta.')
		,('213 	','Database Suspect Data Page','Indica quando uma p�gina � adicionada � tabela de suspect_pages no msdb.')
		,('214 	','Limite de CPU excedido','Indica quando o Administrador de Recursos detecta que uma consulta excedeu o valor do limite de CPU em (REQUEST_MAX_CPU_TIME_SEC.')
		,('215 	','PreConnect:Starting','Indica quando uma fun��o do gatilho LOGON ou do classificador Administrador de Recursos inicia a execu��o.')
		,('216 	','PreConnect:Completed','Indica quando uma fun��o do gatilho LOGON ou do classificador Administrador de Recursos conclui a execu��o.')
		,('217 ','Guia de plano bem-sucedido','Indica que o SQL Server produziu com sucesso um plano de execu��o para uma consulta ou lote, que continha um guia de plano.')
		,('218 ','Guia de plano malsucedido','Indica que o SQL Server n�o p�de produzir um plano de execu��o, para uma consulta ou lote, que continha um guia de plano. O SQL Server tentou gerar um plano de execu��o para esta consulta ou lote sem aplicar o guia de plano. Um guia de plano inv�lido pode ser a causa deste problema. Voc� pode validar o guia de plano usando a fun��o de sistema sys.fn_validate_plan_guide.')
		,('235', 'Audit Fulltext','')




END


ELSE IF (@fl_language = 'en')
 BEGIN 
		IF OBJECT_ID('tempdb..##TracesEvent2') IS NOT NULL
		DROP TABLE tempdb..#TracesEvent2
		CREATE TABLE tempdb..#TracesEvent2
		(
		event_number varchar(8),
		event_name varchar(200),
		description_ varchar(max))
		
			CREATE CLUSTERED INDEX  SK01_#TracesEvent ON #TracesEvent2 (event_number)
		
		CREATE NONCLUSTERED INDEX SK21_#TracesEvent ON #TracesEvent2 (event_number) INCLUDE(event_name,description_)
		
		
		INSERT INTO tempdb..#TracesEvent2  VALUES (
		
 '0-9' 	,'Reserved','Reserved'),
('10' 	,'RPC:Completed','Occurs when a remote procedure call (RPC) has completed.')
,('11' 	,'RPC:Starting','Occurs when an RPC has started.')
,('12' 	,'SQL:BatchCompleted','Occurs when a Transact-SQL batch has completed.')
,('13' 	,'SQL:BatchStarting','Occurs when a Transact-SQL batch has started.')
,('14' 	,'Audit Login','Occurs when a user successfully logs in to SQL Server.')
,('15' 	,'Audit Logout','Occurs when a user logs out of SQL Server.')
,('16' 	,'Attention','Occurs when attention events, such as client-interrupt requests or broken client connections, happen.')
,('17' 	,'ExistingConnection','Detects all activity by users connected to SQL Server before the trace started.')
,('18' 	,'Audit Server Starts and Stops','Occurs when the SQL Server service state is modified.')
,('19' 	,'DTCTransaction','Tracks Microsoft Distributed Transaction Coordinator (MS DTC) coordinated transactions between two or more databases.')
,('20' 	,'Audit Login Failed','Indicates that a login attempt to SQL Server from a client failed.')
,('21' 	,'EventLog','Indicates that events have been logged in the Windows application log.')
,('22' 	,'ErrorLog','Indicates that error events have been logged in the SQL Server error log.')
,('23' 	,'Lock:Released','Indicates that a lock on a resource, such as a page, has been released.')
,('24' 	,'Lock:Acquired','Indicates acquisition of a lock on a resource, such as a data page.')
,('25' 	,'Lock:Deadlock','Indicates that two concurrent transactions have deadlocked each other by trying to obtain incompatible locks on resources the other transaction owns.')
,('26' 	,'Lock:Cancel','Indicates that the acquisition of a lock on a resource has been canceled (for example, due to a deadlock).')
,('27' 	,'Lock:Timeout ','Indicates that a request for a lock on a resource, such as a page, has timed out due to another transaction holding a blocking lock on the required resource. Time-out is determined by the @@LOCK_TIMEOUT function, and can be set with the SET LOCK_TIMEOUT statement.')
,('28' 	,'Degree of Parallelism Event (7.0 Insert)','Occurs before a SELECT, INSERT, or UPDATE statement is executed.')
,('29-31' ,'	Reserved ','Use Event 28 instead.')
,('32' 	,'Reserved','Reserved')
,('33' 	,'Exception','Indicates that an exception has occurred in SQL Server.')
,('34' 	,'SP:CacheMiss','Indicates when a stored procedure is not found in the procedure cache.')
,('35' 	,'SP:CacheInsert','Indicates when an item is inserted into the procedure cache.')
,('36' 	,'SP:CacheRemove','Indicates when an item is removed from the procedure cache.')
,('37' 	,'SP:Recompile ','Indicates that a stored procedure was recompiled.')
,('38' 	,'SP:CacheHit ','Indicates when a stored procedure is found in the procedure cache.')
,('39' 	,'Deprecated','Deprecated')
,('40' 	,'SQL:StmtStarting ','Occurs when the Transact-SQL statement has started.')
,('41' 	,'SQL:StmtCompleted ','Occurs when the Transact-SQL statement has completed.')
,('42' 	,'SP:Starting ','Indicates when the stored procedure has started.')
,('43' 	,'SP:Completed ','Indicates when the stored procedure has completed.')
,('44' 	,'SP:StmtStarting','Indicates that a Transact-SQL statement within a stored procedure has started executing.')
,('45' 	,'SP:StmtCompleted ','Indicates that a Transact-SQL statement within a stored procedure has finished executing.')
,('47' 	,'Object:Deleted ','Indicates that an object has been deleted, such as in DROP INDEX and DROP TABLE statements.')
,('46' 	,'Object:Created ','Indicates that an object has been created, such as for CREATE INDEX, CREATE TABLE, and CREATE DATABASE statements.')
,('48' 	,'Reserved ', '')   	
,('49' 	,'Reserved ','')	
,('50' 	,'SQL Transaction ','Tracks Transact-SQL BEGIN, COMMIT, SAVE, and ROLLBACK TRANSACTION statements.')
,('51' 	,'Scan:Started','Indicates when a table or index scan has started.')
,('52' 	,'Scan:Stopped ','Indicates when a table or index scan has stopped.')
,('53' 	,'CursorOpen ','Indicates when a cursor is opened on a Transact-SQL statement by ODBC, OLE DB, or DB-Library.')
,('54' 	,'TransactionLog ','Tracks when transactions are written to the transaction log.')
,('55' 	,'Hash Warning ','Indicates that a hashing operation (for example, hash join, hash aggregate, hash union, and hash distinct) that is not processing on a buffer partition has reverted to an alternate plan. This can occur because of recursion depth, data skew, trace flags, or bit counting.')
,('56-57' ,'	Reserved','')	
,('58' 	,'Auto Stats ','Indicates an automatic updating of index statistics has occurred.')
,('59' 	,'Lock:Deadlock Chain ','Produced for each of the events leading up to the deadlock.')
,('60' 	,'Lock:Escalation','Indicates that a finer-grained lock has been converted to a coarser-grained lock (for example, a page lock escalated or converted to a TABLE or HoBT lock).')
,('61' 	,'OLE DB Errors','Indicates that an OLE DB error has occurred.')
,('62-66' ,'	Reserved','')
,('67' 	,'Execution Warnings ','Indicates any warnings that occurred during the execution of a SQL Server statement or stored procedure.')
,('68' 	,'Showplan Text (Unencoded)','Displays the plan tree of the Transact-SQL statement executed.')
,('69' 	,'Sort Warnings ','Indicates sort operations that do not fit into memory. Does not include sort operations involving the creating of indexes; only sort operations within a query (such as an ORDER BY clause used in a SELECT statement).')
,('70' 	,'CursorPrepare ','Indicates when a cursor on a Transact-SQL statement is prepared for use by ODBC, OLE DB, or DB-Library.')
,('71' 	,'Prepare SQL','ODBC, OLE DB, or DB-Library has prepared a Transact-SQL statement or statements for use.')
,('72' 	,'Exec Prepared SQL','ODBC, OLE DB, or DB-Library has executed a prepared Transact-SQL statement or statements.')
,('73' 	,'Unprepare SQL','ODBC, OLE DB, or DB-Library has unprepared (deleted) a prepared Transact-SQL statement or statements.')
,('74' 	,'CursorExecute ','A cursor previously prepared on a Transact-SQL statement by ODBC, OLE DB, or DB-Library is executed.')
,('75' 	,'CursorRecompile','A cursor opened on a Transact-SQL statement by ODBC or DB-Library has been recompiled either directly or due to a schema change. Triggered for ANSI and non-ANSI cursors.')
,('76' 	,'CursorImplicitConversion ','A cursor on a Transact-SQL statement is converted by SQL Server from one type to another. Triggered for ANSI and non-ANSI cursors.')
,('77' 	,'CursorUnprepare ','A prepared cursor on a Transact-SQL statement is unprepared (deleted) by ODBC, OLE DB, or DB-Library.')
,('78' 	,'CursorClose','A cursor previously opened on a Transact-SQL statement by ODBC, OLE DB, or DB-Library is closed.')
,('79' 	,'Missing Column Statistics ','Column statistics that could have been useful for the optimizer are not available.')
,('80' 	,'Missing Join Predicate ','Query that has no join predicate is being executed. This could result in a long-running query.')
,('81' 	,'Server Memory Change ','SQL Server memory usage has increased or decreased by either 1 megabyte (MB) or 5 percent of the maximum server memory, whichever is greater.')
,('82-91' ,'	User Configurable (0-9)','Event data defined by the user.')
,('92 '	,'Data File Auto Grow ','Indicates that a data file was extended automatically by the server.')
,('93 '	,'Log File Auto Grow ','Indicates that a log file was extended automatically by the server.')
,('94 '	,'Data File Auto Shrink ','Indicates that a data file was shrunk automatically by the server.')
,('95 '	,'Log File Auto Shrink ','Indicates that a log file was shrunk automatically by the server.')
,('96 '	,'Showplan Text ','Displays the query plan tree of the SQL statement from the query optimizer. Note that the TextData column does not contain the Showplan for this event.')
,('97 '	,'Showplan All','Displays the query plan with full compile-time details of the SQL statement executed. Note that the TextData column does not contain the Showplan for this event.')
,('98 '	,'Showplan Statistics Profile','Displays the query plan with full run-time details of the SQL statement executed. Note that the TextData column does not contain the Showplan for this event.')
,('99 '	,'Reserved','')
,('100' 	,'RPC Output Parameter ','Produces output values of the parameters for every RPC.')
,('101' 	,'Reserved','')
,('102' 	,'Audit Database Scope GDR','Occurs every time a GRANT, DENY, REVOKE for a statement permission is issued by any user in SQL Server for database-only actions such as granting permissions on a database.')
,('103' 	,'Audit Object GDR Event','Occurs every time a GRANT, DENY, REVOKE for an object permission is issued by any user in SQL Server.')
,('104' 	,'Audit AddLogin Event ','Occurs when a SQL Server login is added or removed; for sp_addlogin and sp_droplogin.')
,('105' 	,'Audit Login GDR Event ','Occurs when a Windows login right is added or removed; for sp_grantlogin, sp_revokelogin, and sp_denylogin.')
,('106' 	,'Audit Login Change Property Event ','Occurs when a property of a login, except passwords, is modified; for sp_defaultdb and sp_defaultlanguage.')
,('107' 	,'Audit Login Change Password Event ','Occurs when a SQL Server login password is changed. Passwords are not recorded.')
,('108' 	,'Audit Add Login to Server Role Event','Occurs when a login is added or removed from a fixed server role; for sp_addsrvrolemember, and sp_dropsrvrolemember.')
,('109' 	,'Audit Add DB User Event ','Occurs when a login is added or removed as a database user (Windows or SQL Server) to a database; for sp_grantdbaccess, sp_revokedbaccess, sp_adduser, and sp_dropuser.')
,('110' 	,'Audit Add Member to DB Role Event ','Occurs when a login is added or removed as a database user (fixed or user-defined) to a database; for sp_addrolemember, sp_droprolemember, and sp_changegroup.')
,('111' 	,'Audit Add Role Event 	','Occurs when a login is added or removed as a database user to a database; for sp_addrole and sp_droprole.')
,('112' 	,'Audit App Role Change Password Event','Occurs when a password of an application role is changed.')
,('113' 	,'Audit Statement Permission Event','Occurs when a statement permission (such as CREATE TABLE) is used.')
,('114' 	,'Audit Schema Object Access Event','Occurs when an object permission (such as SELECT) is used, both successfully or unsuccessfully.')
,('115' 	,'Audit Backup/Restore Event','Occurs when a BACKUP or RESTORE command is issued.')
,('116' 	,'Audit DBCC Event','Occurs when DBCC commands are issued.')
,('117' 	,'Audit Change Audit Event ','Occurs when audit trace modifications are made.')
,('118' 	,'Audit Object Derived Permission Event ','Occurs when a CREATE, ALTER, and DROP object commands are issued.')
,('119' 	,'OLEDB Call Event 	','Occurs when OLE DB provider calls are made for distributed queries and remote stored procedures.')
,('120' 	,'OLEDB QueryInterface Event','Occurs when OLE DB QueryInterface calls are made for distributed queries and remote stored procedures.')
,('121' 	,'OLEDB DataRead Event ','Occurs when a data request call is made to the OLE DB provider.')
,('122' 	,'Showplan XML 	','Occurs when an SQL statement executes. Include this event to identify Showplan operators. Each event is stored in a well-formed XML document. Note that the Binary column for this event contains the encoded Showplan. Use SQL Server Profiler to open the trace and view the Showplan.')
,('123' 	,'SQL:FullTextQuery ','Occurs when a full text query executes.')
,('124' 	,'Broker:Conversation','Reports the progress of a Service Broker conversation.')
,('125' 	,'Deprecation Announcement','Occurs when you use a feature that will be removed from a future version of SQL Server.')
,('126' 	,'Deprecation Final Support ','Occurs when you use a feature that will be removed from the next major release of SQL Server.')
,('127' 	,'Exchange Spill Event','Occurs when communication buffers in a parallel query plan have been temporarily written to the tempdb database.')
,('128' 	,'Audit Database Management Event ','Occurs when a database is created, altered, or dropped.')
,('129' 	,'Audit Database Object Management Event','Occurs when a CREATE, ALTER, or DROP statement executes on database objects, such as schemas.')
,('130' 	,'Audit Database Principal Management Event ','Occurs when principals, such as users, are created, altered, or dropped from a database.')
,('131' 	,'Audit Schema Object Management Event ','Occurs when server objects are created, altered, or dropped.')
,('132' 	,'Audit Server Principal Impersonation Event','Occurs when there is an impersonation within server scope, such as EXECUTE AS LOGIN.')
,('133' 	,'Audit Database Principal Impersonation Event','Occurs when an impersonation occurs within the database scope, such as EXECUTE AS USER or SETUSER.')
,('134' 	,'Audit Server Object Take Ownership Event','Occurs when the owner is changed for objects in server scope.')
,('135' 	,'Audit Database Object Take Ownership Event ','Occurs when a change of owner for objects within database scope occurs.')
,('136' 	,'Broker:Conversation Group','Occurs when Service Broker creates a new conversation group or drops an existing conversation group.')
,('137' 	,'Blocked Process Report','Occurs when a process has been blocked for more than a specified amount of time. Does not include system processes or processes that are waiting on non deadlock-detectable resources. Use sp_configure to configure the threshold and frequency at which reports are generated.')
,('138' 	,'Broker:Connection ','Reports the status of a transport connection managed by Service Broker.')
,('139' 	,'Broker:Forwarded Message Sent','Occurs when Service Broker forwards a message.')
,('140' 	,'Broker:Forwarded Message Dropped','Occurs when Service Broker drops a message that was intended to be forwarded.')
,('141' 	,'Broker:Message Classify','Occurs when Service Broker determines the routing for a message.')
,('142' 	,'Broker:Transmission ','Indicates that errors have occurred in the Service Broker transport layer. The error number and state values indicate the source of the error.')
,('143' 	,'Broker:Queue Disabled','Indicates a poison message was detected because there were five consecutive transaction rollbacks on a Service Broker queue. The event contains the database ID and queue ID of the queue that contains the poison message.')
,('144-145' 	,'Reserved','')
,('146' 	,'Showplan XML Statistics Profile','Occurs when an SQL statement executes. Identifies the Showplan operators and displays complete, compile-time data. Note that the Binary column for this event contains the encoded Showplan. Use SQL Server Profiler to open the trace and view the Showplan.')
,('148' 	,'Deadlock Graph ','Occurs when an attempt to acquire a lock is canceled because the attempt was part of a deadlock and was chosen as the deadlock victim. Provides an XML description of a deadlock.')
,('149' 	,'Broker:Remote Message Acknowledgement ','Occurs when Service Broker sends or receives a message acknowledgement.')
,('150' 	,'Trace File Close ','Occurs when a trace file closes during a trace file rollover.')
,('151' 	,'Reserved','')
,('152' 	,'Audit Change Database Owner ','Occurs when ALTER AUTHORIZATION is used to change the owner of a database and permissions are checked to do that.')
,('153' 	,'Audit Schema Object Take Ownership Event ','Occurs when ALTER AUTHORIZATION is used to assign an owner to an object and permissions are checked to do that.')
,('154' 	,'Reserved','	')
,('155' 	,'FT:Crawl Started','Occurs when a full-text crawl (population) starts. Use to check if a crawl request is picked up by worker tasks.')
,('156' 	,'FT:Crawl Stopped','Occurs when a full-text crawl (population) stops. Stops occur when a crawl completes successfully or when a fatal error occurs.')
,('157' 	,'FT:Crawl Aborted','Occurs when an exception is encountered during a full-text crawl. Usually causes the full-text crawl to stop.')
,('158' 	,'Audit Broker Conversation ','Reports audit messages related to Service Broker dialog security.')
,('159' 	,'Audit Broker Login ','Reports audit messages related to Service Broker transport security.')
,('160' 	,'Broker:Message Undeliverable','Occurs when Service Broker is unable to retain a received message that should have been delivered to a service.')
,('161' 	,'Broker:Corrupted Message','Occurs when Service Broker receives a corrupted message.')
,('162' 	,'User Error Message ','Displays error messages that users see in the case of an error or exception.')
,('163' 	,'Broker:Activation ','Occurs when a queue monitor starts an activation stored procedure, sends a QUEUE_ACTIVATION notification, or when an activation stored procedure started by a queue monitor exits.')
,('164' 	,'Object:Altered ','Occurs when a database object is altered.')
,('165' 	,'Performance statistics ','Occurs when a compiled query plan has been cached for the first time, recompiled, or removed from the plan cache.')
,('166' 	,'SQL:StmtRecompile','Occurs when a statement-level recompilation occurs.')
,('167' 	,'Database Mirroring State Change','Occurs when the state of a mirrored database changes.')
,('168' 	,'Showplan XML For Query Compile','Occurs when an SQL statement compiles. Displays the complete, compile-time data. Note that the Binary column for this event contains the encoded Showplan. Use SQL Server Profiler to open the trace and view the Showplan.')
,('169' 	,'Showplan All For Query Compile ','Occurs when an SQL statement compiles. Displays complete, compile-time data. Use to identify Showplan operators.')
,('170' 	,'Audit Server Scope GDR Event ','Indicates that a grant, deny, or revoke event for permissions in server scope occurred, such as creating a login.')
,('171' 	,'Audit Server Object GDR Event','Indicates that a grant, deny, or revoke event for a schema object, such as a table or function, occurred.')
,('172' 	,'Audit Database Object GDR Event','Indicates that a grant, deny, or revoke event for database objects, such as assemblies and schemas, occurred.')
,('173' 	,'Audit Server Operation Event ','Occurs when Security Audit operations such as altering settings, resources, external access, or authorization are used.')
,('175' 	,'Audit Server Alter Trace Event','Occurs when a statement checks for the ALTER TRACE permission.')
,('176' 	,'Audit Server Object Management Event','Occurs when server objects are created, altered, or dropped.')
,('177' 	,'Audit Server Principal Management Event','Occurs when server principals are created, altered, or dropped.')
,('178' 	,'Audit Database Operation Event','Occurs when database operations occur, such as checkpoint or subscribe query notification.')
,('180' 	,'Audit Database Object Access Event','Occurs when database objects, such as schemas, are accessed.')
,('181' 	,'TM: Begin Tran starting ','Occurs when a BEGIN TRANSACTION request starts.')
,('182' 	,'TM: Begin Tran completed 	','Occurs when a BEGIN TRANSACTION request completes.')
,('183' 	,'TM: Promote Tran starting ','Occurs when a PROMOTE TRANSACTION request starts.')
,('184' 	,'TM: Promote Tran completed ','Occurs when a PROMOTE TRANSACTION request completes.')
,('185' 	,'TM: Commit Tran starting ','Occurs when a COMMIT TRANSACTION request starts.')
,('186' 	,'TM: Commit Tran completed','Occurs when a COMMIT TRANSACTION request completes.')
,('187' 	,'TM: Rollback Tran starting ','Occurs when a ROLLBACK TRANSACTION request starts.')
,('188' 	,'TM: Rollback Tran completed','Occurs when a ROLLBACK TRANSACTION request completes.')
,('189' 	,'Lock:Timeout (timeout > 0)','Occurs when a request for a lock on a resource, such as a page, times out.')
,('190' 	,'Progress Report: Online Index Operation','Reports the progress of an online index build operation while the build process is running.')
,('191' 	,'TM: Save Tran starting','Occurs when a SAVE TRANSACTION request starts.')
,('192' 	,'TM: Save Tran completed','Occurs when a SAVE TRANSACTION request completes.')
,('193' 	,'Background Job Error','Occurs when a background job terminates abnormally.')
,('194' 	,'OLEDB Provider Information','Occurs when a distributed query runs and collects information corresponding to the provider connection.')
,('195' 	,'Mount Tape ','Occurs when a tape mount request is received.')
,('196' 	,'Assembly Load','Occurs when a request to load a CLR assembly occurs.')
,('197' 	,'Reserved','')
,('198' 	,'XQuery Static Type','Occurs when an XQuery expression is executed. This event class provides the static type of the XQuery expression.')
,('199' 	,'QN: subscription','Occurs when a query registration cannot be subscribed. The TextData column contains information about the event.')
,('200' 	,'QN: parameter table ','Information about active subscriptions is stored in internal parameter tables. This event class occurs when a parameter table is created or deleted. Typically, these tables are created or deleted when the database is restarted. The TextData column contains information about the event.')
,('201' 	,'QN: template','A query template represents a class of subscription queries. Typically, queries in the same class are identical except for their parameter values. This event class occurs when a new subscription request falls into an already existing class of (Match), a new class (Create), or a Drop class, which indicates cleanup of templates for query classes without active subscriptions. The TextData column contains information about the event.')
,('202' 	,'QN: dynamics ','Tracks internal activities of query notifications. The TextData column contains information about the event.')
,('212' 	,'Bitmap Warning','Indicates when bitmap filters have been disabled in a query.')
,('213' 	,'Database Suspect Data Page','Indicates when a page is added to the suspect_pages table in msdb.')
,('214' 	,'CPU threshold exceeded','Indicates when the Resource Governor detects a query has exceeded the CPU threshold value (REQUEST_MAX_CPU_TIME_SEC).')
,('215' 	,'PreConnect:Starting','Indicates when a LOGON trigger or Resource Governor classifier function starts execution.')
,('216' 	,'PreConnect:Completed','Indicates when a LOGON trigger or Resource Governor classifier function completes execution.')
,('217' 	,'Plan Guide Successful','Indicates that SQL Server successfully produced an execution plan for a query or batch that contained a plan guide.')
,('218' 	,'Plan Guide Unsuccessful','Indicates that SQL Server could not produce an execution plan for a query or batch that contained a plan guide. SQL Server attempted to generate an execution plan for this query or batch without applying the plan guide. An invalid plan guide may be the cause of this problem. You can validate the plan guide by using the sys.fn_validate_plan_guide system function.')
,('235' 	,'Audit Fulltext','') 	


-- APENAS QUANDO TEM A VARIAVEL ID <> NULL	
	 IF (@id IS NOT NULL AND (@fl_language = 'en'))
		BEGIN
			SELECT * FROM tempdb..#TracesEvent2
			where event_number = @id
			order by event_name  
			RETURN;
		END
		
	END
	IF (@fl_language = 'pt')
	BEGIN
		SELECT * FROM tempdb..#TracesEvent
		order by nome_do_evento
	END
		ELSE IF (@fl_language = 'en')
		BEGIN
			SELECT * FROM tempdb..#TracesEvent2
			order by event_name    
		END





	
END






