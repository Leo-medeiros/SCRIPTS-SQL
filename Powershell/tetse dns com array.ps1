# script com array
Clear-Host
$GoogleDNS =  @("8.8.8.8","8.8.4.4")
$totalDNS = $GoogleDNS.Count()

Write-Host Pingando todos os  $totalDNS DNS do Google
Test-Connection $GoogleDNS -Count 1

