# Test-Example.ps1
# Script de démonstration pour voir comment les métriques sont affichées
# Ne nécessite PAS de connexion Azure

Write-Host "📊 Simulation de collecte de métriques" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Simuler des métriques
$FakeMetrics = @{
    Name = "Percentage CPU"
    Data = @(
        @{ TimeStamp = (Get-Date).AddMinutes(-15); Average = 45.2; Minimum = 42.1; Maximum = 48.5 }
        @{ TimeStamp = (Get-Date).AddMinutes(-14); Average = 47.8; Minimum = 45.2; Maximum = 51.3 }
        @{ TimeStamp = (Get-Date).AddMinutes(-13); Average = 52.1; Minimum = 48.9; Maximum = 55.7 }
        @{ TimeStamp = (Get-Date).AddMinutes(-12); Average = 48.5; Minimum = 46.2; Maximum = 52.1 }
        @{ TimeStamp = (Get-Date).AddMinutes(-11); Average = 46.3; Minimum = 44.1; Maximum = 49.8 }
        @{ TimeStamp = (Get-Date).AddMinutes(-10); Average = 50.7; Minimum = 47.5; Maximum = 54.2 }
        @{ TimeStamp = (Get-Date).AddMinutes(-9); Average = 55.2; Minimum = 52.1; Maximum = 58.9 }
        @{ TimeStamp = (Get-Date).AddMinutes(-8); Average = 53.8; Minimum = 50.7; Maximum = 57.3 }
        @{ TimeStamp = (Get-Date).AddMinutes(-7); Average = 49.2; Minimum = 46.8; Maximum = 52.5 }
        @{ TimeStamp = (Get-Date).AddMinutes(-6); Average = 47.5; Minimum = 45.1; Maximum = 50.8 }
    )
}

# Afficher comme le ferait le vrai script
Write-Host "📥 Collecte: CPU Percentage... ✅ 10 points" -ForegroundColor Green

# Calculer les statistiques
$CpuValues = $FakeMetrics.Data.Average
$Stats = $CpuValues | Measure-Object -Average -Maximum -Minimum

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 RÉSULTATS MÉTRIQUES CPU" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Statistiques:" -ForegroundColor Yellow
Write-Host "  Points de données : $($Stats.Count)" -ForegroundColor White
Write-Host "  Moyenne           : $([math]::Round($Stats.Average, 2))%" -ForegroundColor White
Write-Host "  Minimum           : $([math]::Round($Stats.Minimum, 2))%" -ForegroundColor White
Write-Host "  Maximum           : $([math]::Round($Stats.Maximum, 2))%" -ForegroundColor White
Write-Host ""

# Afficher les valeurs dans le temps
Write-Host "Évolution dans le temps:" -ForegroundColor Yellow
Write-Host ("  " + "{0,-20} {1,10} {2,10} {3,10}" -f "Heure", "Moyenne", "Min", "Max") -ForegroundColor Gray

foreach ($point in $FakeMetrics.Data) {
    $color = if ($point.Average -gt 50) { "Red" } elseif ($point.Average -gt 45) { "Yellow" } else { "Green" }
    $bar = "█" * [math]::Floor($point.Average / 10)
    Write-Host ("  " + "{0,-20} {1,10:N1}% {2,10:N1}% {3,10:N1}% {4}" -f
        $point.TimeStamp.ToString("HH:mm:ss"),
        $point.Average,
        $point.Minimum,
        $point.Maximum,
        $bar) -ForegroundColor $color
}

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Simulation de sauvegarde
$OutputDir = ".\metrics\demo"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$OutputFile = Join-Path $OutputDir "demo-cpu-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

$FakeMetrics | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "✅ Fichier sauvegardé: $OutputFile" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Pour voir le fichier JSON:" -ForegroundColor Cyan
Write-Host "   Get-Content '$OutputFile' | ConvertFrom-Json" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Pour analyser les données:" -ForegroundColor Cyan
Write-Host "   `$data = Get-Content '$OutputFile' | ConvertFrom-Json" -ForegroundColor Yellow
Write-Host "   `$data.Data | Format-Table TimeStamp, Average, Minimum, Maximum" -ForegroundColor Yellow
