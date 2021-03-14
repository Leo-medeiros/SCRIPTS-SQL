# Power Tuning (c) Todos os Direitos Reservados
# Este script foi desenvolvido exclusivamente para o ambiente Comprocard!

# Ele é resposavel por monitorar o status do sincronismo com o Azure e realizar as ações pós-sincronismo.
# O script foi criado para que possa ser usado com um job do SQL Agent!
param(
	#Remover o arquivo somente se a data da modificação for mais antiga que este número de dias.
	#Também, só serão considerados arquivos que já foram sincronizados.
	 $CleanupDays = 10
	 
	,#Por padrão, o Cleanup não é executado, e apenas os arquivos elegíveis para delação são printados.
		#Se quiser confirmar a deleção, use este parâmetro!
		[switch]$ExecuteCleanup
		
	,#Instância SQL onde importar as estatísticas!
	 #TODO: Add usuário e senha
		$ServerInstance = '.'
		
	,#Banco onde executar a importação das estatíticas
		$Database = 'Traces'
		
	
		
	 
	,#Para testes. Desabilita o tratamento do ExitCode
		#O tratamento de ExitCode é útil para para aplicações que depende do ExitCode para saber
		#se o script falhou ou  não, como o SQL Agent.
		#Este script retorna 0 se foi sucesso. Caso contrário, um valor diferente de zero é retornado.
		[switch]$NoExitCode

)

#Em caso de erros, encerrar a execução.
$ErrorActionPreference = "Stop";

#Carregando o módulo do SQLServer
import-module sqlps;

$ExitCode = 1;

try {

# Carrega as configurações da Storage Account
$AzureParams = & "$PsScriptRoot\AzureStorageParams.ps1";


# Preparando os parâmetros
$CompareAzureParams = @{
	#Conexão com a Storage account
	Token 		= $AzureParams.Token
	StorageAccount 	= $AzureParams.StorageAccount
	ContainerName 	= $AzureParams.ContainerName

	#Diretório onde o backup é gerado
	LocalDirectory  = 'E:\BACKUP'

	# Expressão regular para ajudar a trazer menos dados do Azure usado na comparação.
	# Esta expressão diz que as duas primeiras partes do caminho deverão ser usados para filtrar...
 	# Como o backup é criado em um diretório no formato SERVIDOR/DATA, estamos dizendo ao Azure que traga somente os arquivos do SERVIDOR/DATA que existem atualmente no LocalDirectory
	# Isto evita que o Azure traga todos os nomes de arquivos existentes, o que seria lento demais...
	PrefixRegex = '^([^/]+/){2}'  

	# Esta é a expressão que vamos mapear para o resumo das informações
	# A primeira parte é o nome do servidor, não queremos (por isso nõ está entre parênteses)
	# A segunda, é a data do backup. Estará mapeada no índice 1
	# A terceira, é o nome do Banco, no índice 2
	# A quarta é o índice 3, o tipo do backup
	SummaryRegex = '^[^/]+/([^/]+)/([^/]+)/([^/]+)/' 

	#Aqui é o mapeamento!
	# O script irá, para cada arquivo local, extrair as informações com base na SummaryRege, e criar um array de objetos com essas propriedades e valores extrapidos!
	#
	SummaryMap 	= @{ 
				BackupDate 	= '1:yyyyMMdd'
				Database 	= 2
				BackupType 	= 3   
			}


	# DICA: Para entender melhor esses dois últimos parâmetros, recomendo olhar o script CompareAzureStorage.ps1



}


#Agora vamos executar o script que vai identificar o que falta sincronizar e trazer um resumo!
$SyncStats 		= & "$PsScriptRoot\CompareAzureStorage.ps1" @CompareAzureParams 
$NaoEnviados	= $SyncStats.NotSyncSummary

$SQLcmd = 
@"
	IF OBJECT_ID('tempdb..#AzureSyncPendingDatabases') IS NOT NULL
		DROP TABLE #AzureSyncPendingDatabases;
	
	CREATE TABLE #AzureSyncPendingDatabases (
		 DatabaseName sysname
		,BackupDate date
		,BackupType varchar(10)
		,FileCount int
		,LastUpdate datetime
	)
	
"@

if($NaoEnviados){
	

	#Vamos guardar no SQL SErver...
	$Inserts = $NaoEnviados | %{
		$BackupDate = $_.BackupDate.ToString("yyyyMMdd");
		@(
			"INSERT INTO #AzureSyncPendingDatabases(DatabaseName,BackupDate,BackupType,FileCount,LastUpdate)"
			"VALUES('$($_.Database)','$BackupDate','$($_.BackupType)',$($_.Count),GETDATE())"
		) -Join ""
	}
	
	$SQLCmd += $Inserts -Join "`r`n";

}

$SqlCmd  += 
@"

	SET XACT_ABORT ON;
	BEGIN TRAN;
	
	
		TRUNCATE TABLE Traces.dbo.AzureSyncPendingDatabases;
		INSERT INTO Traces.dbo.AzureSyncPendingDatabases SELECT * FROM #AzureSyncPendingDatabases;
	
	COMMIT;


"@

Invoke-Sqlcmd -Database Traces -Query $Sqlcmd

#Calculando a data a partir de onde deletar os arquivos.
$CleanupStartDate = (Get-Date).addDays(-$CleanupDays)
write-host "Minimum date to keep files: $CleanupStartDate";

$Elegible  = $SyncStats.Sync | ? { $_.LastWriteTime -lt $CleanupStartDate }

#Se tem arquivos para deletar...
if($Elegible){
	write-host "Deleting $($Elegible.count) synced files"
	$Elegible  | %{
		#write-host "Can Cleanup: " $_.FullName;
		if($ExecuteCleanup){
			Remove-Item $_.FullName -Force;
		}
	}
	write-host "	Done"
}


#Exit Success
$ExitCode = 0;
} catch {
	#Exit error
	$ExitCode = 2;
	$LastEx = $_;
} finally {
	if($NoExitCode){
		if($ExitCode -eq 2){throw $LastEx};
	} else {
		if($ExitCode -eq 2){write-host $LastEx};
		exit $ExitCode;
	}
}
