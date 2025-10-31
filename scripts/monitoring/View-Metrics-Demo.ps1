# View-Metrics-Demo.ps1
# Demonstration simple de visualisation de metriques

Write-Host "Demo: Comment voir les resultats des metriques" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Simuler des donnees
$DemoData = @{
    ResourceName = "terracloud-vm-01"
    MetricName = "CPU Percentage"
    Timespan = "15 minutes"
    DataPoints = @(
        @{Time = "14:00"; Value = 45.2}
        @{Time = "14:01"; Value = 47.8}
        @{Time = "14:02"; Value = 52.1}
        @{Time = "14:03"; Value = 48.5}
        @{Time = "14:04"; Value = 46.3}
        @{Time = "14:05"; Value = 50.7}
        @{Time = "14:06"; Value = 55.2}
        @{Time = "14:07"; Value = 53.8}
        @{Time = "14:08"; Value = 49.2}
        @{Time = "14:09"; Value = 47.5}
    )
}

# Afficher les informations
Write-Host "Ressource: $($DemoData.ResourceName)" -ForegroundColor Yellow
Write-Host "Metrique: $($DemoData.MetricName)" -ForegroundColor Yellow
Write-Host "Periode: $($DemoData.Timespan)" -ForegroundColor Yellow
Write-Host ""

# Calculer les stats
$Values = $DemoData.DataPoints.Value
$Avg = ($Values | Measure-Object -Average).Average
$Min = ($Values | Measure-Object -Minimum).Minimum
$Max = ($Values | Measure-Object -Maximum).Maximum

Write-Host "STATISTIQUES:" -ForegroundColor Green
Write-Host "  Moyenne: $([math]::Round($Avg, 2))%" -ForegroundColor White
Write-Host "  Minimum: $Min%" -ForegroundColor White
Write-Host "  Maximum: $Max%" -ForegroundColor White
Write-Host "  Points de donnees: $($Values.Count)" -ForegroundColor White
Write-Host ""

# Afficher les valeurs
Write-Host "VALEURS DANS LE TEMPS:" -ForegroundColor Green
foreach ($point in $DemoData.DataPoints) {
    $color = if ($point.Value -gt 50) { "Red" } else { "Green" }
    Write-Host "  $($point.Time) : $($point.Value)%" -ForegroundColor $color
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Avec Azure, tu verras les vraies donnees !" -ForegroundColor Yellow
Write-Host ""
Write-Host "Commandes utiles:" -ForegroundColor Cyan
Write-Host "  1. Collecter: .\Collect-Metrics.ps1 -Type IaaS" -ForegroundColor Gray
Write-Host "  2. Lire JSON: Get-Content .\metrics\iaas\*.json | ConvertFrom-Json" -ForegroundColor Gray
Write-Host "  3. Voir tableau: ... | Select-Object -ExpandProperty Data | Format-Table" -ForegroundColor Gray
