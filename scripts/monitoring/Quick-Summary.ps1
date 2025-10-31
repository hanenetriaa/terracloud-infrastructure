# Quick-Summary.ps1
# Script rapide pour afficher un resume des resultats
# Usage: .\Quick-Summary.ps1 -MetricsDir ".\metrics\iaas" -ArtilleryFile ".\results\test.json"

param(
    [string]$MetricsDir,
    [string]$ArtilleryFile
)

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   RESUME RAPIDE DES RESULTATS DE TEST     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Si aucun parametre, essayer de trouver les derniers fichiers
if (-not $MetricsDir -and -not $ArtilleryFile) {
    Write-Host "Recherche des derniers resultats..." -ForegroundColor Yellow
    Write-Host ""

    # Trouver le dernier fichier Artillery
    $latestArtillery = Get-ChildItem -Path ".\results" -Filter "*.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notlike "*.html" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($latestArtillery) {
        $ArtilleryFile = $latestArtillery.FullName
        Write-Host "✓ Trouve Artillery: $($latestArtillery.Name)" -ForegroundColor Green
    }

    # Trouver le dernier dossier de metriques
    if (Test-Path ".\metrics\iaas") {
        $MetricsDir = ".\metrics\iaas"
        Write-Host "✓ Trouve metriques IaaS" -ForegroundColor Green
    }
    elseif (Test-Path ".\metrics\paas") {
        $MetricsDir = ".\metrics\paas"
        Write-Host "✓ Trouve metriques PaaS" -ForegroundColor Green
    }

    Write-Host ""
}

# Analyser les resultats Artillery
if ($ArtilleryFile -and (Test-Path $ArtilleryFile)) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  RESULTATS ARTILLERY" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    try {
        $artillery = Get-Content $ArtilleryFile | ConvertFrom-Json
        $counters = $artillery.aggregate.counters
        $summaries = $artillery.aggregate.summaries

        # Calculs
        $totalRequests = $counters.'http.requests'
        $successRequests = $counters.'http.codes.200'
        $errors = $counters.'vusers.failed'
        $completed = $counters.'vusers.completed'
        $created = $counters.'vusers.created'

        if ($totalRequests) {
            $successRate = [math]::Round(($successRequests / $totalRequests) * 100, 2)
            $errorRate = [math]::Round((($totalRequests - $successRequests) / $totalRequests) * 100, 2)
        } else {
            $successRate = 0
            $errorRate = 0
        }

        # Affichage
        Write-Host "Requetes totales : $totalRequests" -ForegroundColor White
        Write-Host "Requetes reussies: $successRequests ($successRate%)" -ForegroundColor Green
        Write-Host "Taux d'erreur    : $errorRate%" -ForegroundColor $(if ($errorRate -gt 5) { "Red" } elseif ($errorRate -gt 1) { "Yellow" } else { "Green" })
        Write-Host ""

        if ($summaries.'http.response_time') {
            $rt = $summaries.'http.response_time'
            Write-Host "Temps de reponse:" -ForegroundColor Yellow
            Write-Host "  Min    : $($rt.min) ms" -ForegroundColor White
            Write-Host "  Median : $($rt.median) ms" -ForegroundColor White
            Write-Host "  p95    : $($rt.p95) ms" -ForegroundColor $(if ($rt.p95 -gt 1000) { "Red" } elseif ($rt.p95 -gt 500) { "Yellow" } else { "Green" })
            Write-Host "  p99    : $($rt.p99) ms" -ForegroundColor $(if ($rt.p99 -gt 2000) { "Red" } elseif ($rt.p99 -gt 1000) { "Yellow" } else { "Green" })
            Write-Host "  Max    : $($rt.max) ms" -ForegroundColor White
        }

        Write-Host ""
        Write-Host "Utilisateurs virtuels:" -ForegroundColor Yellow
        Write-Host "  Crees    : $created" -ForegroundColor White
        Write-Host "  Completes: $completed" -ForegroundColor Green
        Write-Host "  Echecs   : $errors" -ForegroundColor $(if ($errors -gt 10) { "Red" } else { "Yellow" })

    } catch {
        Write-Host "Erreur lecture fichier Artillery" -ForegroundColor Red
    }

    Write-Host ""
}

# Analyser les metriques Azure
if ($MetricsDir -and (Test-Path $MetricsDir)) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  METRIQUES AZURE MONITOR" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    # CPU
    $cpuFile = Get-ChildItem -Path $MetricsDir -Filter "*cpu*.json" | Select-Object -First 1
    if ($cpuFile) {
        try {
            $cpu = Get-Content $cpuFile.FullName | ConvertFrom-Json
            $cpuValues = $cpu.Data.Average | Where-Object { $_ -ne $null }

            if ($cpuValues) {
                $stats = $cpuValues | Measure-Object -Average -Maximum -Minimum

                Write-Host "CPU:" -ForegroundColor Yellow
                Write-Host "  Moyenne: $([math]::Round($stats.Average, 2))%" -ForegroundColor $(if ($stats.Average -gt 70) { "Red" } elseif ($stats.Average -gt 50) { "Yellow" } else { "Green" })
                Write-Host "  Min    : $([math]::Round($stats.Minimum, 2))%" -ForegroundColor White
                Write-Host "  Max    : $([math]::Round($stats.Maximum, 2))%" -ForegroundColor $(if ($stats.Maximum -gt 85) { "Red" } elseif ($stats.Maximum -gt 70) { "Yellow" } else { "Green" })
                Write-Host ""
            }
        } catch {
            Write-Host "Erreur lecture metriques CPU" -ForegroundColor Red
        }
    }

    # Memoire
    $memFile = Get-ChildItem -Path $MetricsDir -Filter "*memory*.json" | Select-Object -First 1
    if ($memFile) {
        try {
            $mem = Get-Content $memFile.FullName | ConvertFrom-Json
            $memValues = $mem.Data.Average | Where-Object { $_ -ne $null }

            if ($memValues) {
                $stats = $memValues | Measure-Object -Average -Maximum -Minimum

                Write-Host "Memoire (Available):" -ForegroundColor Yellow
                Write-Host "  Moyenne: $([math]::Round($stats.Average / 1MB, 2)) MB" -ForegroundColor White
                Write-Host "  Min    : $([math]::Round($stats.Minimum / 1MB, 2)) MB" -ForegroundColor White
                Write-Host "  Max    : $([math]::Round($stats.Maximum / 1MB, 2)) MB" -ForegroundColor White
                Write-Host ""
            }
        } catch {
            Write-Host "Erreur lecture metriques memoire" -ForegroundColor Red
        }
    }

    # Requetes HTTP (PaaS)
    $reqFile = Get-ChildItem -Path $MetricsDir -Filter "*requests*.json" | Select-Object -First 1
    if ($reqFile) {
        try {
            $req = Get-Content $reqFile.FullName | ConvertFrom-Json
            $reqValues = $req.Data.Total | Where-Object { $_ -ne $null }

            if ($reqValues) {
                $total = ($reqValues | Measure-Object -Sum).Sum

                Write-Host "Requetes HTTP (Azure):" -ForegroundColor Yellow
                Write-Host "  Total: $total" -ForegroundColor White
                Write-Host ""
            }
        } catch {}
    }
}

# Evaluation globale
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  EVALUATION" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$issues = @()
$warnings = @()
$success = @()

# Verifications
if ($artillery) {
    if ($errorRate -gt 5) {
        $issues += "Taux d'erreur eleve ($errorRate%)"
    } elseif ($errorRate -gt 1) {
        $warnings += "Taux d'erreur moyen ($errorRate%)"
    } else {
        $success += "Taux d'erreur faible ($errorRate%)"
    }

    if ($summaries.'http.response_time'.p95 -gt 1000) {
        $issues += "Temps de reponse p95 > 1000ms"
    } elseif ($summaries.'http.response_time'.p95 -gt 500) {
        $warnings += "Temps de reponse p95 > 500ms"
    } else {
        $success += "Temps de reponse acceptable"
    }
}

if ($cpuValues) {
    $avgCpu = ($cpuValues | Measure-Object -Average).Average
    $maxCpu = ($cpuValues | Measure-Object -Maximum).Maximum

    if ($maxCpu -gt 85) {
        $issues += "CPU max > 85% ($([math]::Round($maxCpu, 2))%)"
    } elseif ($avgCpu -gt 70) {
        $warnings += "CPU moyen > 70% ($([math]::Round($avgCpu, 2))%)"
    } else {
        $success += "CPU dans les normes"
    }
}

# Affichage
if ($issues.Count -gt 0) {
    Write-Host "PROBLEMES:" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "  ✗ $issue" -ForegroundColor Red
    }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "AVERTISSEMENTS:" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  ! $warning" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($success.Count -gt 0) {
    Write-Host "SUCCES:" -ForegroundColor Green
    foreach ($s in $success) {
        Write-Host "  ✓ $s" -ForegroundColor Green
    }
    Write-Host ""
}

# Conclusion
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
if ($issues.Count -eq 0) {
    Write-Host "  RESULTAT: TEST REUSSI ✓" -ForegroundColor Green
} elseif ($issues.Count -le 2) {
    Write-Host "  RESULTAT: TEST PARTIEL ~" -ForegroundColor Yellow
} else {
    Write-Host "  RESULTAT: TEST ECHOUE ✗" -ForegroundColor Red
}
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Suggestions
Write-Host "Pour plus de details:" -ForegroundColor Gray
if ($ArtilleryFile) {
    Write-Host "  artillery report '$ArtilleryFile'" -ForegroundColor Gray
}
if ($MetricsDir) {
    Write-Host "  Get-ChildItem '$MetricsDir'" -ForegroundColor Gray
}
Write-Host ""
