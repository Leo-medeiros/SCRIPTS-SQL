$Params = @{
		ContainerUrl 	= "https://"
		LocalDirectory 	= "C:\DbFiles\Backup_Azure"
		Token 		= ""
		AzCopy		= "C:\DbFiles\Backup_Azure\Azure\azcopy.exe"
	}

try {
	& "$PsScriptRoot\SyncAzureStorage.ps1" @Params -NoExitCode
	$ExitCode = 0
} catch {
	$ExitCode = 1
	$_ | out-string
} finally {
	exit $ExitCode
}