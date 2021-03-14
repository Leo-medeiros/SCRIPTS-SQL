param(
	#SAS Access token
	#If a file, read token from file!
	$Token
	
	,#Url container format https://[StorageAccount].blob.core.windows.net/[ContainerName]
	 $ContainerUrl
	
	,#Local directory to mirror
	 $LocalDirectory
	 
	,$AzCopy = $null
	
	,[switch]$NoExitCode
)
$ErrorActionPreference = "Stop";

try {

	if(!$AzCopy){
		$AzCopy = (Split-Path $PsScriptRoot)+"\azcopy.exe"
	}
	
	if(!$Token){
		throw "NO_TOKEN";
	}
	
	if(Test-Path $Token){
		$Token = Get-Content $Token -Raw;
	}


	if(-not(Test-Path $AzCopy)){
		throw "INVALID_AZCOPY: $AzCopy"
	}

	$FullURL = $ContainerUrl + $Token;

	write-host "Remote Azure URL: $ContainerUrl";
	write-host "Token: $Token";

	if(!$LocalDirectory -or -not(Test-Path $LocalDirectory)){
		throw "INVALID_LOCALDIRECTORY: $LocalDirectory"
	}

	write-host "Local directory: $LocalDirectory"

	& $AzCopy sync $LocalDirectory $FullURL
	$ExitCode = $LastExitCode

	if($ExitCode){
		throw "EXITCODE: $ExitCode. Check previous messages";
	}
} catch {
	$ExitCode = 1;
	throw;
} finally {
	if(!$NoExitCode){
		exit $ExitCode;
	}
}