# Validate-AzureMonitor.ps1
# Script de validation de la configuration Azure Monitor (PowerShell)
# Author: Syrine Ladhari
# Version: 1.0

param(
    [string]$ResourceGroup = "terracloud-rg",
    [string]$VMName = "terracloud-vm-01",
    [string]$AppName = "terracloud-paas"
)

Write-Host "🔍 Validation de la configuration Azure Monitor pour TerraCloud" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$TestsPassed = 0
$TestsFailed = 0

function Test-Step {
    param(
        [string]$Message,
        [bool]$Success
    )
    if ($Success) {
        Write-Host "✅ $Message" -ForegroundColor Green
        $script:TestsPassed++
    } else {
        Write-Host "❌ $Message" -ForegroundColor Red
        $script:TestsFailed++
    }
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

# Test 1: Vérifier le module Az PowerShell
Write-Host "📋 Test 1: Vérification module Az PowerShell"
try {
    $AzModule = Get-Module -ListAvailable -Name Az.Accounts | Select-Object -First 1
    if ($AzModule) {
        Write-Host "   Version: $($AzModule.Version)"
        Test-Step "Module Az installé" $true
    } else {
        Test-Step "Module Az installé" $false
        Write-Warning "Installez le module Az: Install-Module -Name Az -Scope CurrentUser"
    }
} catch {
    Test-Step "Module Az installé" $false
}

# Test 2: Vérifier la connexion Azure
Write-Host ""
Write-Host "📋 Test 2: Vérification connexion Azure"
try {
    $Context = Get-AzContext -ErrorAction Stop
    if ($Context) {
        Write-Host "   Compte: $($Context.Account)"
        Write-Host "   Subscription: $($Context.Subscription.Name)"
        Test-Step "Connecté à Azure" $true
        $SubscriptionId = $Context.Subscription.Id
    } else {
        throw "Pas de contexte"
    }
} catch {
    Test-Step "Connecté à Azure" $false
    Write-Warning "Connectez-vous: Connect-AzAccount"
    exit 1
}

# Test 3: Vérifier le Resource Group
Write-Host ""
Write-Host "📋 Test 3: Vérification Resource Group"
try {
    $RG = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction Stop
    Write-Host "   Location: $($RG.Location)"
    Test-Step "Resource Group '$ResourceGroup' existe" $true
} catch {
    Test-Step "Resource Group '$ResourceGroup' existe" $false
    Write-Warning "Resource Group non trouvé: $ResourceGroup"
}

# Test 4: Vérifier la VM IaaS
Write-Host ""
Write-Host "📋 Test 4: Vérification VM IaaS"
try {
    $VM = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -ErrorAction Stop
    $VMStatus = (Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -Status).Statuses | Where-Object { $_.Code -like "PowerState/*" }
    Write-Host "   Status: $($VMStatus.DisplayStatus)"
    Write-Host "   Size: $($VM.HardwareProfile.VmSize)"
    Test-Step "VM '$VMName' trouvée" $true
} catch {
    Test-Step "VM '$VMName' trouvée" $false
    Write-Warning "VM non trouvée: $VMName"
}

# Test 5: Vérifier l'App Service PaaS
Write-Host ""
Write-Host "📋 Test 5: Vérification App Service PaaS"
try {
    $WebApp = Get-AzWebApp -ResourceGroupName $ResourceGroup -Name $AppName -ErrorAction Stop
    Write-Host "   Status: $($WebApp.State)"
    Write-Host "   URL: https://$($WebApp.DefaultHostName)"
    Test-Step "App Service '$AppName' trouvée" $true
} catch {
    Test-Step "App Service '$AppName' trouvée" $false
    Write-Warning "App Service non trouvée: $AppName"
}

# Test 6: Vérifier l'accès aux métriques VM
Write-Host ""
Write-Host "📋 Test 6: Vérification accès métriques VM"
if ($TestsFailed -eq 0) {
    try {
        $EndTime = Get-Date
        $StartTime = $EndTime.AddMinutes(-5)

        $Metrics = Get-AzMetric `
            -ResourceId "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$VMName" `
            -MetricName "Percentage CPU" `
            -StartTime $StartTime `
            -EndTime $EndTime `
            -TimeGrain 00:01:00 `
            -ErrorAction Stop

        if ($Metrics) {
            Test-Step "Accès aux métriques VM OK" $true
        } else {
            Test-Step "Accès aux métriques VM OK" $false
        }
    } catch {
        Test-Step "Accès aux métriques VM OK" $false
        Write-Warning "Erreur: $($_.Exception.Message)"
    }
} else {
    Write-Warning "Test sauté (dépendances échouées)"
}

# Test 7: Vérifier l'accès aux métriques App Service
Write-Host ""
Write-Host "📋 Test 7: Vérification accès métriques App Service"
if ($TestsFailed -eq 0) {
    try {
        $Metrics = Get-AzMetric `
            -ResourceId "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Web/sites/$AppName" `
            -MetricName "CpuPercentage" `
            -StartTime $StartTime `
            -EndTime $EndTime `
            -TimeGrain 00:01:00 `
            -ErrorAction Stop

        if ($Metrics) {
            Test-Step "Accès aux métriques App Service OK" $true
        } else {
            Test-Step "Accès aux métriques App Service OK" $false
        }
    } catch {
        Test-Step "Accès aux métriques App Service OK" $false
        Write-Warning "Erreur: $($_.Exception.Message)"
    }
} else {
    Write-Warning "Test sauté (dépendances échouées)"
}

# Test 8: Vérifier Log Analytics Workspace
Write-Host ""
Write-Host "📋 Test 8: Vérification Log Analytics (optionnel)"
try {
    $Workspaces = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue
    if ($Workspaces) {
        Write-Host "   Workspaces: $($Workspaces.Name -join ', ')"
        Test-Step "Log Analytics Workspace trouvé" $true
    } else {
        Write-Warning "Aucun Log Analytics Workspace trouvé (optionnel)"
    }
} catch {
    Write-Warning "Aucun Log Analytics Workspace trouvé (optionnel)"
}

# Test 9: Vérifier Application Insights
Write-Host ""
Write-Host "📋 Test 9: Vérification Application Insights (optionnel)"
try {
    $AppInsights = Get-AzApplicationInsights -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue
    if ($AppInsights) {
        Write-Host "   Application Insights: $($AppInsights.Name -join ', ')"
        Test-Step "Application Insights trouvé" $true
    } else {
        Write-Warning "Aucun Application Insights trouvé (recommandé pour PaaS)"
    }
} catch {
    Write-Warning "Aucun Application Insights trouvé (recommandé pour PaaS)"
}

# Résumé
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "📊 RÉSUMÉ DE LA VALIDATION" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Tests réussis: $TestsPassed" -ForegroundColor Green
Write-Host "Tests échoués: $TestsFailed" -ForegroundColor Red
Write-Host ""

if ($TestsFailed -eq 0) {
    Write-Host "✅ Validation réussie ! Vous êtes prêt pour les tests de performance." -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Prochaines étapes:"
    Write-Host "   1. Configurer les variables d'environnement:"
    Write-Host "      `$env:IAAS_URL='http://votre-url-iaas.com'"
    Write-Host "      `$env:PAAS_URL='https://votre-url-paas.com'"
    Write-Host "   2. Lancer un test Artillery: artillery run -e iaas scenarios/normal-load.yml"
    Write-Host "   3. Collecter les métriques: .\scripts\monitoring\Collect-IaaSMetrics.ps1"
    exit 0
} else {
    Write-Host "❌ Validation échouée. Corrigez les erreurs ci-dessus." -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Actions recommandées:"
    Write-Host "   - Vérifiez les noms de ressources (ResourceGroup, VMName, AppName)"
    Write-Host "   - Vérifiez vos permissions Azure (Monitoring Contributor requis)"
    Write-Host "   - Installez le module Az: Install-Module -Name Az -Scope CurrentUser"
    Write-Host "   - Connectez-vous: Connect-AzAccount"
    exit 1
}
