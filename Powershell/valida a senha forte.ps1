$correct_senha = "[^a-zA-Z0-9]” 


$senha = Read-Host "Digite sua senha"
 

if($senha -notmatch $correct_senha)
{
    Write-Host Senha fraca, deve contér caracteres especiais, maisculas, minusculas e numeros!
    exit
}

Write-Host Senha FORTE.