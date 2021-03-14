$domain = "^LMDS"



Write-Host "***VALIDA USUARIOS COM DOMINIO***"

$login =  Read-Host Digite seu usuario

if($login -notmatch $domain)
{

    Write-Host "USER NOT FOUND: Seu usuario para ser valido deve ter o DOMINIO LMDS"
   exit

}
Write-Host USUARIO VALIDO

