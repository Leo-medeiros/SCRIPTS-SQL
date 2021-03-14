# Script básico leo
# Variaveis
clear-host
Write-Host "********************************************************"

Write-Host "Script Cria pasta"

Write-Host "********************************************************"

$path = Read-Host "Coloque o caminho onde deseja criar o novo diretorio"
$pasta = Read-Host "Digite o nome da Pasta"

#acessa o caminho informado
sleep 1 
cd $path
# cria a pasta desejada no caminho definido
mkdir $pasta

#fim