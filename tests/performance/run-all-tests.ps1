# Script de tests Artillery - TerraCloud
# Compare les performances IaaS vs PaaS

Write-Host "=== TerraCloud - Tests de performance Artillery ===" -ForegroundColor Green
Write-Host ""

# Configuration
$IAAS_URL = "http://51.103.124.209"
$PAAS_URL = "https://terracloud-dev-wa.azurewebsites.net"

$resultsDir = "results"
New-Item -Path $resultsDir -ItemType Directory -Force | Out-Null

Write-Host "Configuration des tests:" -ForegroundColor Yellow
Write-Host "  IaaS URL: $IAAS_URL" -ForegroundColor Cyan
Write-Host "  PaaS URL: $PAAS_URL" -ForegroundColor Cyan
Write-Host ""

# Test 1: Charge normale IaaS
Write-Host "[Test 1/4] Charge normale IaaS (7 minutes)..." -ForegroundColor Blue
$env:TARGET_URL = $IAAS_URL
artillery run load-test.yml -o "$resultsDir/iaas-load.json"
Write-Host "[OK] Test IaaS charge normale termine" -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 30

# Test 2: Charge normale PaaS
Write-Host "[Test 2/4] Charge normale PaaS (7 minutes)..." -ForegroundColor Blue
$env:TARGET_URL = $PAAS_URL
artillery run load-test.yml -o "$resultsDir/paas-load.json"
Write-Host "[OK] Test PaaS charge normale termine" -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 30

# Test 3: Stress IaaS
Write-Host "[Test 3/4] Stress test IaaS (4 minutes)..." -ForegroundColor Red
$env:TARGET_URL = $IAAS_URL
artillery run stress-test.yml -o "$resultsDir/iaas-stress.json"
Write-Host "[OK] Test IaaS stress termine" -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 30

# Test 4: Stress PaaS
Write-Host "[Test 4/4] Stress test PaaS (4 minutes)..." -ForegroundColor Red
$env:TARGET_URL = $PAAS_URL
artillery run stress-test.yml -o "$resultsDir/paas-stress.json"
Write-Host "[OK] Test PaaS stress termine" -ForegroundColor Green
Write-Host ""

# Génération des rapports HTML
Write-Host "Generation des rapports HTML..." -ForegroundColor Yellow
artillery report "$resultsDir/iaas-load.json" --output "$resultsDir/iaas-load.html"
artillery report "$resultsDir/paas-load.json" --output "$resultsDir/paas-load.html"
artillery report "$resultsDir/iaas-stress.json" --output "$resultsDir/iaas-stress.html"
artillery report "$resultsDir/paas-stress.json" --output "$resultsDir/paas-stress.html"

Write-Host ""
Write-Host "=== TOUS LES TESTS TERMINES ===" -ForegroundColor Green
Write-Host ""
Write-Host "Resultats disponibles dans:" -ForegroundColor Yellow
Write-Host "  - $resultsDir/iaas-load.html" -ForegroundColor White
Write-Host "  - $resultsDir/paas-load.html" -ForegroundColor White
Write-Host "  - $resultsDir/iaas-stress.html" -ForegroundColor White
Write-Host "  - $resultsDir/paas-stress.html" -ForegroundColor White
Write-Host ""
Write-Host "Prochaine etape: Analyser les resultats et creer le rapport comparatif" -ForegroundColor Cyan