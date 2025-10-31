# Collect-Metrics.ps1
# Script de collecte des métriques Azure Monitor (IaaS et PaaS)
# Author: Syrine Ladhari
# Version: 1.0

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("IaaS", "PaaS", "Both")]
    [string]$Type,

    [string]$ResourceGroup = "terracloud-rg",
    [string]$VMName = "terracloud-vm-01",
    [string]$AppName = "terracloud-paas",
    [string]$OutputDir = ".\metrics",
    [int]$DurationMinutes = 15
)

Write-Host "📊 Collecte des métriques Azure Monitor - $Type" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$EndTime = Get-Date
$StartTime = $EndTime.AddMinutes(-$DurationMinutes)
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Obtenir le contexte Azure
try {
    $Context = Get-AzContext -ErrorAction Stop
    $SubscriptionId = $Context.Subscription.Id
    Write-Host "Subscription: $($Context.Subscription.Name)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Pas de connexion Azure. Exécutez: Connect-AzAccount" -ForegroundColor Red
    exit 1
}

Write-Host "Période: $($StartTime.ToString('yyyy-MM-dd HH:mm')) à $($EndTime.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor Gray
Write-Host ""

# Fonction pour collecter une métrique
function Collect-Metric {
    param(
        [string]$ResourceId,
        [string]$MetricName,
        [string]$OutputFile,
        [string]$DisplayName
    )

    Write-Host "📥 Collecte: $DisplayName..." -NoNewline

    try {
        $Metrics = Get-AzMetric `
            -ResourceId $ResourceId `
            -MetricName $MetricName `
            -StartTime $StartTime `
            -EndTime $EndTime `
            -TimeGrain 00:01:00 `
            -ErrorAction Stop

        # Sauvegarder en JSON
        $Metrics | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8

        # Compter les points de données
        $DataPoints = ($Metrics.Data | Measure-Object).Count
        Write-Host " ✅ $DataPoints points" -ForegroundColor Green

        return $Metrics
    } catch {
        Write-Host " ❌ Erreur" -ForegroundColor Red
        Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Fonction pour calculer des statistiques
function Get-MetricStats {
    param($Metrics, [string]$Property = "Average")

    $Values = $Metrics.Data.$Property | Where-Object { $_ -ne $null }

    if ($Values) {
        $Stats = $Values | Measure-Object -Average -Maximum -Minimum
        return @{
            Count = $Stats.Count
            Average = [math]::Round($Stats.Average, 2)
            Min = [math]::Round($Stats.Minimum, 2)
            Max = [math]::Round($Stats.Maximum, 2)
        }
    }
    return $null
}

# Collecter métriques IaaS
if ($Type -eq "IaaS" -or $Type -eq "Both") {
    Write-Host "═══ Métriques IaaS (VM: $VMName) ═══" -ForegroundColor Cyan
    Write-Host ""

    $IaaSDir = Join-Path $OutputDir "iaas"
    New-Item -ItemType Directory -Force -Path $IaaSDir | Out-Null

    $VMResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$VMName"

    # CPU
    $CpuMetrics = Collect-Metric `
        -ResourceId $VMResourceId `
        -MetricName "Percentage CPU" `
        -OutputFile (Join-Path $IaaSDir "$VMName-cpu-$Timestamp.json") `
        -DisplayName "CPU Percentage"

    if ($CpuMetrics) {
        $Stats = Get-MetricStats $CpuMetrics
        Write-Host "   📊 Moyenne: $($Stats.Average)% | Min: $($Stats.Min)% | Max: $($Stats.Max)%" -ForegroundColor Gray
    }

    # Mémoire
    Collect-Metric `
        -ResourceId $VMResourceId `
        -MetricName "Available Memory Bytes" `
        -OutputFile (Join-Path $IaaSDir "$VMName-memory-$Timestamp.json") `
        -DisplayName "Available Memory" | Out-Null

    # Réseau In
    Collect-Metric `
        -ResourceId $VMResourceId `
        -MetricName "Network In Total" `
        -OutputFile (Join-Path $IaaSDir "$VMName-network-in-$Timestamp.json") `
        -DisplayName "Network In" | Out-Null

    # Réseau Out
    Collect-Metric `
        -ResourceId $VMResourceId `
        -MetricName "Network Out Total" `
        -OutputFile (Join-Path $IaaSDir "$VMName-network-out-$Timestamp.json") `
        -DisplayName "Network Out" | Out-Null

    # Disque Read
    Collect-Metric `
        -ResourceId $VMResourceId `
        -MetricName "Disk Read Bytes" `
        -OutputFile (Join-Path $IaaSDir "$VMName-disk-read-$Timestamp.json") `
        -DisplayName "Disk Read" | Out-Null

    # Disque Write
    Collect-Metric `
        -ResourceId $VMResourceId `
        -MetricName "Disk Write Bytes" `
        -OutputFile (Join-Path $IaaSDir "$VMName-disk-write-$Timestamp.json") `
        -DisplayName "Disk Write" | Out-Null

    Write-Host ""
}

# Collecter métriques PaaS
if ($Type -eq "PaaS" -or $Type -eq "Both") {
    Write-Host "═══ Métriques PaaS (App: $AppName) ═══" -ForegroundColor Cyan
    Write-Host ""

    $PaaSDir = Join-Path $OutputDir "paas"
    New-Item -ItemType Directory -Force -Path $PaaSDir | Out-Null

    $AppResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Web/sites/$AppName"

    # CPU
    $CpuMetrics = Collect-Metric `
        -ResourceId $AppResourceId `
        -MetricName "CpuPercentage" `
        -OutputFile (Join-Path $PaaSDir "$AppName-cpu-$Timestamp.json") `
        -DisplayName "CPU Percentage"

    if ($CpuMetrics) {
        $Stats = Get-MetricStats $CpuMetrics
        Write-Host "   📊 Moyenne: $($Stats.Average)% | Min: $($Stats.Min)% | Max: $($Stats.Max)%" -ForegroundColor Gray
    }

    # Mémoire
    Collect-Metric `
        -ResourceId $AppResourceId `
        -MetricName "MemoryWorkingSet" `
        -OutputFile (Join-Path $PaaSDir "$AppName-memory-$Timestamp.json") `
        -DisplayName "Memory Working Set" | Out-Null

    # Requêtes
    $RequestsMetrics = Collect-Metric `
        -ResourceId $AppResourceId `
        -MetricName "Requests" `
        -OutputFile (Join-Path $PaaSDir "$AppName-requests-$Timestamp.json") `
        -DisplayName "HTTP Requests"

    if ($RequestsMetrics) {
        $Stats = Get-MetricStats $RequestsMetrics "Total"
        Write-Host "   📊 Total requêtes: $($Stats.Average)" -ForegroundColor Gray
    }

    # Temps de réponse
    $ResponseMetrics = Collect-Metric `
        -ResourceId $AppResourceId `
        -MetricName "AverageResponseTime" `
        -OutputFile (Join-Path $PaaSDir "$AppName-response-time-$Timestamp.json") `
        -DisplayName "Response Time"

    if ($ResponseMetrics) {
        $Stats = Get-MetricStats $ResponseMetrics
        Write-Host "   📊 Temps réponse moyen: $($Stats.Average)s" -ForegroundColor Gray
    }

    # HTTP 2xx
    Collect-Metric `
        -ResourceId $AppResourceId `
        -MetricName "Http2xx" `
        -OutputFile (Join-Path $PaaSDir "$AppName-http2xx-$Timestamp.json") `
        -DisplayName "HTTP 2xx" | Out-Null

    # HTTP 4xx
    Collect-Metric `
        -ResourceId $AppResourceId `
        -MetricName "Http4xx" `
        -OutputFile (Join-Path $PaaSDir "$AppName-http4xx-$Timestamp.json") `
        -DisplayName "HTTP 4xx" | Out-Null

    # HTTP 5xx
    Collect-Metric `
        -ResourceId $AppResourceId `
        -MetricName "Http5xx" `
        -OutputFile (Join-Path $PaaSDir "$AppName-http5xx-$Timestamp.json") `
        -DisplayName "HTTP 5xx" | Out-Null

    # Bytes reçus
    Collect-Metric `
        -ResourceId $AppResourceId `
        -MetricName "BytesReceived" `
        -OutputFile (Join-Path $PaaSDir "$AppName-bytes-received-$Timestamp.json") `
        -DisplayName "Bytes Received" | Out-Null

    # Bytes envoyés
    Collect-Metric `
        -ResourceId $AppResourceId `
        -MetricName "BytesSent" `
        -OutputFile (Join-Path $PaaSDir "$AppName-bytes-sent-$Timestamp.json") `
        -DisplayName "Bytes Sent" | Out-Null

    Write-Host ""
}

# Résumé
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ Collecte terminée !" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Fichiers créés dans: $OutputDir" -ForegroundColor Cyan

if ($Type -eq "IaaS" -or $Type -eq "Both") {
    $IaaSFiles = Get-ChildItem -Path (Join-Path $OutputDir "iaas") -Filter "*$Timestamp.json"
    Write-Host "   IaaS: $($IaaSFiles.Count) fichiers" -ForegroundColor Gray
}

if ($Type -eq "PaaS" -or $Type -eq "Both") {
    $PaaSFiles = Get-ChildItem -Path (Join-Path $OutputDir "paas") -Filter "*$Timestamp.json"
    Write-Host "   PaaS: $($PaaSFiles.Count) fichiers" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📝 Pour analyser les données:"
Write-Host "   Get-Content .\metrics\iaas\*-cpu-$Timestamp.json | ConvertFrom-Json" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Prochaine étape: Comparer les métriques avec les résultats Artillery" -ForegroundColor Cyan
