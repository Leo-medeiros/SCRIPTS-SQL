param(
	 $NomeConexao
	 ,[string[]]$Ips = @()
	 ,[switch]$ClearCache
	 ,[switch]$UseRouteExe
	 ,[switch]$ReuseCache
)

$ErrorActionPreference = "Stop";

if(!$NomeConexao){
	throw "DEVE INFORMAR UM NOME DE CONEXAO (-NomeConexao)"
}

if($ClearCache){
	$Global:__PWT_IP_CACHE = $null;
}

if($ReuseCache){
	$Ips = $Global:__PWT_IP_CACHE 
}

if(!$Ips){

	$TempFile = [Io.Path]::GetTempFileName();
	
	$IpCache = $Global:__PWT_IP_CACHE;

	$FileInstrunction = @(
		"#Informe a lista de ips no notepad que irá se abrir logo abaixo"
		"#Você pode separar por linha ou por virgulas"
		"#Linhas inciadas com # serão ignoradas!!"
		""
		""
	)
	
	if($IpCache){
		$FileInstrunction += @(
			"#Os ips que você tento adicionar na execucao anterior foram incluidos aqui automaticamente"
			$IpCache
		)
	} else {
		$FileInstrunction += @(
				"#Exemplo (lembre de apagar o exemplo)"
				"10.231.5.40,10.20.40.80"
				"1.2.3.4"
			)
	}
	
	$FileInstrunction >> $TempFile;

	$p = Start-Process notepad -ArgumentList $TempFile -PassThru
	
	write-host "Esperando você fechar o notepad";
	$p.WaitForExit();
	
	
	$Ips = @(Get-Content $TempFile | ? {  $_ -and $_ -match '^[^#]' } | %{ $_ -split ',|\s' });
	Remove-Item -Force $TempFile  -EA SilentlyContinue;
}

$Global:__PWT_IP_CACHE = $Ips;
write-host "Total Ips: $($Ips.count)";

if($UseRouteExe){
	$TryRouteExe = $true;
} else {
	$TryRouteExe = $false;
	try {
		write-host "Tentando usar o metodo pra Windows 10...";
		import-module VpnClient;
		
		if(-not(Get-Command Add-VpnConnectionRoute -EA SilentlyContinue)){
			$TryRouteExe = $true;	
			throw "Add-VpnConnectionRoute nao encontrado"
		}
		
		#Validando se a conexao existe...
		$VpnConn = Get-VpnConnection -Name $NomeConexao -ErrorAction "SilentlyContinue"
		
		if(!$VpnConn){
			throw "CONEXAO NAO EXISTE: $NomeConexao"
		}
			
		$Ips | %{
			$Destination = "$_/32";
			
			try {
				write-host "Adicionando $Destination";
				Add-VpnConnectionRoute -ConnectionName $NomeConexao  -DestinationPrefix $Destination -RouteMetric 1
				write-host " Sucesso!"
			} catch {
				wite-host "	Falha ao inclur ip: $_";
			}
			
		}
		
		

		write-host "Se a inclusao foi feita com sucesso, desconecte e conecte novamente a conexão VPN e tentar se conectar com o IP desejado"
		write-host "Caso tenha problemas, verifique se todos os ips solicitados foram incluidos com sucesso"
		write-host "Utilize o comando route print para analisar as rotas"

	} catch {
		write-host "Falha ao tentar metodo Wind10: $_";
	}
}



if($TryRouteExe){
	write-host "Tentando usar route.exe";
	write-host "Conecte-se na VPN $NomeConexao"
	
	
	$timeout = 120;
	
	$StartTime = (Get-Date);
	
	while($true){
		
		$SlsResult = ipconfig | ? { $_ } | sls $NomeConexao -Context 10;
		
		if($SlsResult){
			$PostCtx = $SlsResult.Context.PostContext 
			$CtxIp = @($PostCtx | ? { $_ -match 'Address[^\d]+(\d+\.\d+\.\d+\.\d+)' } | %{ $matches[1] })
			
			$ConnIp = $CtxIp[0]
			
			write-host "Encontrado conexao: $($SlsResult.Line)"
			write-host "IP identificado: $ConnIp"
			
			write-host "Incluindo rotas"
			$Ips | %{				
				write-host "Incluindo rota para $_";
				route add $_ mask 255.255.255.255 $ConnIp  metric 1;
			}
			
			break;
		}
		
		
		$ElapsedTime = (Get-Date) - $StartTime;
		if($ElapsedTime.TotalSeconds -gt $timeout){
			throw "Nenhuma conexao com o nome $NomeConexao foi identificada em $timeout segundos";
		}
		
		write-progress -Activity "Inicie a Conexao $NomeConexao" -Status "Aguardando iniciar $NomeConexao" -SecondsRemaining ($timeout - $ElapsedTime.TotalSeconds);
		Start-sleep -s 1;
	}
	
	
	write-host "As rotas foram adicionadas. Tentem se conectar com o IP desejado."
	write-host "Caso tenha problemas, verifique se todos os ips solicitados foram incluidos com sucesso analisanod mensagens anteriores"
	write-host "Utilize o comando route print para analisar as rotas"
	
}


write-host "Caso ainda tenha dificuldades de conectar procure alguem mais experiente para apoio"







