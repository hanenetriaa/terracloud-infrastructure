# Scripts de Monitoring Azure Monitor

Ce dossier contient les scripts pour valider et collecter les métriques Azure Monitor pour les tests de performance TerraCloud.

## 📁 Structure

```
scripts/monitoring/
├── README.md                           # Ce fichier
├── Validate-AzureMonitor.ps1           # Validation (PowerShell) ⭐ Windows
├── Collect-Metrics.ps1                 # Collecte métriques (PowerShell) ⭐ Windows
├── validate-azure-monitor.sh           # Validation (Bash)
├── collect-iaas-metrics.sh             # Collecte IaaS (Bash)
└── collect-paas-metrics.sh             # Collecte PaaS (Bash)
```

---

## 🚀 Quick Start (Windows)

### 1. Validation de la configuration

```powershell
# Se connecter à Azure
Connect-AzAccount

# Valider la configuration
cd scripts\monitoring
.\Validate-AzureMonitor.ps1 `
    -ResourceGroup "votre-resource-group" `
    -VMName "votre-vm" `
    -AppName "votre-app-service"
```

### 2. Collecter les métriques

```powershell
# Après un test Artillery, collecter les métriques des 15 dernières minutes

# Pour IaaS uniquement
.\Collect-Metrics.ps1 `
    -Type IaaS `
    -ResourceGroup "votre-resource-group" `
    -VMName "votre-vm" `
    -DurationMinutes 15

# Pour PaaS uniquement
.\Collect-Metrics.ps1 `
    -Type PaaS `
    -ResourceGroup "votre-resource-group" `
    -AppName "votre-app-service" `
    -DurationMinutes 15

# Pour les deux
.\Collect-Metrics.ps1 `
    -Type Both `
    -ResourceGroup "votre-resource-group" `
    -VMName "votre-vm" `
    -AppName "votre-app-service" `
    -DurationMinutes 15
```

---

## 📋 Prérequis

### Pour Windows (PowerShell)

```powershell
# Installer le module Az PowerShell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

# Vérifier l'installation
Get-Module -ListAvailable -Name Az

# Se connecter à Azure
Connect-AzAccount
```

### Pour Linux/Mac (Bash)

```bash
# Installer Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Se connecter à Azure
az login

# Rendre les scripts exécutables
chmod +x scripts/monitoring/*.sh
```

---

## 📖 Guide détaillé

### Script 1: Validate-AzureMonitor.ps1 (Windows)

**Objectif**: Vérifier que tout est configuré correctement avant de lancer les tests.

**Tests effectués**:
1. ✅ Module Az PowerShell installé
2. ✅ Connexion Azure active
3. ✅ Resource Group existe
4. ✅ VM IaaS trouvée et en cours d'exécution
5. ✅ App Service PaaS trouvé et en cours d'exécution
6. ✅ Accès aux métriques VM fonctionnel
7. ✅ Accès aux métriques App Service fonctionnel
8. ℹ️ Log Analytics Workspace (optionnel)
9. ℹ️ Application Insights (optionnel)

**Utilisation**:

```powershell
# Utilisation basique
.\Validate-AzureMonitor.ps1

# Avec paramètres personnalisés
.\Validate-AzureMonitor.ps1 `
    -ResourceGroup "mon-resource-group" `
    -VMName "ma-vm" `
    -AppName "mon-app-service"
```

**Sortie attendue**:

```
🔍 Validation de la configuration Azure Monitor pour TerraCloud
================================================================

📋 Test 1: Vérification module Az PowerShell
   Version: 11.0.0
✅ Module Az installé

📋 Test 2: Vérification connexion Azure
   Compte: syrine@epitech.eu
   Subscription: TerraCloud-Subscription
✅ Connecté à Azure

...

================================================================
📊 RÉSUMÉ DE LA VALIDATION
================================================================
Tests réussis: 7
Tests échoués: 0

✅ Validation réussie ! Vous êtes prêt pour les tests de performance.
```

---

### Script 2: Collect-Metrics.ps1 (Windows)

**Objectif**: Collecter automatiquement toutes les métriques importantes après un test Artillery.

**Métriques IaaS collectées**:
- CPU Percentage
- Available Memory
- Network In/Out
- Disk Read/Write

**Métriques PaaS collectées**:
- CPU Percentage
- Memory Working Set
- HTTP Requests (total)
- Response Time (average)
- HTTP 2xx/4xx/5xx
- Bytes Received/Sent

**Utilisation**:

```powershell
# Collecter les métriques IaaS des 15 dernières minutes
.\Collect-Metrics.ps1 -Type IaaS

# Collecter les métriques PaaS des 30 dernières minutes
.\Collect-Metrics.ps1 -Type PaaS -DurationMinutes 30

# Collecter IaaS et PaaS avec paramètres personnalisés
.\Collect-Metrics.ps1 `
    -Type Both `
    -ResourceGroup "terracloud-rg" `
    -VMName "terracloud-vm-01" `
    -AppName "terracloud-paas" `
    -OutputDir ".\metrics" `
    -DurationMinutes 15
```

**Structure de sortie**:

```
metrics/
├── iaas/
│   ├── terracloud-vm-01-cpu-20251031-143022.json
│   ├── terracloud-vm-01-memory-20251031-143022.json
│   ├── terracloud-vm-01-network-in-20251031-143022.json
│   └── ...
└── paas/
    ├── terracloud-paas-cpu-20251031-143022.json
    ├── terracloud-paas-requests-20251031-143022.json
    ├── terracloud-paas-response-time-20251031-143022.json
    └── ...
```

---

### Script 3: validate-azure-monitor.sh (Linux/Mac)

**Équivalent Bash du script PowerShell de validation**.

**Utilisation**:

```bash
# Définir les variables d'environnement
export RESOURCE_GROUP="terracloud-rg"
export VM_NAME="terracloud-vm-01"
export APP_NAME="terracloud-paas"

# Lancer la validation
./scripts/monitoring/validate-azure-monitor.sh
```

---

### Script 4: collect-iaas-metrics.sh (Linux/Mac)

**Collecte des métriques IaaS (VMs)**.

**Utilisation**:

```bash
# Configuration
export RESOURCE_GROUP="terracloud-rg"
export VM_NAME="terracloud-vm-01"
export OUTPUT_DIR="./metrics/iaas"
export START_TIME="2025-10-31T14:00:00Z"
export END_TIME="2025-10-31T14:15:00Z"

# Collecter
./scripts/monitoring/collect-iaas-metrics.sh

# Ou en une ligne (15 dernières minutes par défaut)
RESOURCE_GROUP="terracloud-rg" VM_NAME="terracloud-vm-01" \
  ./scripts/monitoring/collect-iaas-metrics.sh
```

---

### Script 5: collect-paas-metrics.sh (Linux/Mac)

**Collecte des métriques PaaS (App Service)**.

**Utilisation**:

```bash
# Configuration
export RESOURCE_GROUP="terracloud-rg"
export APP_NAME="terracloud-paas"
export OUTPUT_DIR="./metrics/paas"
export START_TIME="2025-10-31T14:00:00Z"
export END_TIME="2025-10-31T14:15:00Z"

# Collecter
./scripts/monitoring/collect-paas-metrics.sh
```

---

## 🔄 Workflow complet

### Avant le test

```powershell
# 1. Valider la configuration
.\scripts\monitoring\Validate-AzureMonitor.ps1 `
    -ResourceGroup "terracloud-rg" `
    -VMName "terracloud-vm-01" `
    -AppName "terracloud-paas"

# 2. Noter l'heure de début
$StartTime = Get-Date
Write-Host "Début du test: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))"
```

### Pendant le test

```powershell
# 3. Lancer le test Artillery
cd tests\performance
artillery run -e iaas scenarios\normal-load.yml

# 4. (Optionnel) Surveiller en temps réel dans le portail Azure
Start-Process "https://portal.azure.com"
```

### Après le test

```powershell
# 5. Noter l'heure de fin
$EndTime = Get-Date
$Duration = ($EndTime - $StartTime).TotalMinutes
Write-Host "Fin du test: $($EndTime.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Host "Durée: $([math]::Ceiling($Duration)) minutes"

# 6. Attendre 2-3 minutes pour que les métriques soient disponibles
Start-Sleep -Seconds 180

# 7. Collecter les métriques
cd ..\..  # Retour à la racine du projet
.\scripts\monitoring\Collect-Metrics.ps1 `
    -Type IaaS `
    -ResourceGroup "terracloud-rg" `
    -VMName "terracloud-vm-01" `
    -DurationMinutes ([math]::Ceiling($Duration) + 5)

# 8. Analyser les résultats
Get-ChildItem .\metrics\iaas\*cpu*.json | ForEach-Object {
    Write-Host "Fichier: $($_.Name)"
    $Data = Get-Content $_.FullName | ConvertFrom-Json
    $CpuValues = $Data.Data.Average | Where-Object { $_ -ne $null }
    $CpuAvg = ($CpuValues | Measure-Object -Average).Average
    Write-Host "CPU Moyenne: $([math]::Round($CpuAvg, 2))%"
}
```

---

## 📊 Analyse des résultats

### Lire les fichiers JSON

```powershell
# Charger un fichier de métriques
$Metrics = Get-Content .\metrics\iaas\terracloud-vm-01-cpu-20251031-143022.json | ConvertFrom-Json

# Afficher les valeurs
$Metrics.Data | Format-Table TimeStamp, Average, Minimum, Maximum

# Calculer des statistiques
$CpuValues = $Metrics.Data.Average | Where-Object { $_ -ne $null }
$Stats = $CpuValues | Measure-Object -Average -Maximum -Minimum
Write-Host "Moyenne: $($Stats.Average)%"
Write-Host "Max: $($Stats.Maximum)%"
Write-Host "Min: $($Stats.Minimum)%"
```

### Comparer IaaS vs PaaS

```powershell
# Charger les métriques CPU des deux infrastructures
$IaasCpu = Get-Content .\metrics\iaas\*-cpu-*.json | ConvertFrom-Json
$PaasCpu = Get-Content .\metrics\paas\*-cpu-*.json | ConvertFrom-Json

# Calculer les moyennes
$IaasAvg = ($IaasCpu.Data.Average | Measure-Object -Average).Average
$PaasAvg = ($PaasCpu.Data.Average | Measure-Object -Average).Average

Write-Host "CPU IaaS moyen: $([math]::Round($IaasAvg, 2))%"
Write-Host "CPU PaaS moyen: $([math]::Round($PaasAvg, 2))%"
Write-Host "Différence: $([math]::Round($IaasAvg - $PaasAvg, 2))%"
```

---

## 🛠️ Troubleshooting

### Problème: "Connect-AzAccount not recognized"

**Solution**: Installer le module Az PowerShell

```powershell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Import-Module Az
```

### Problème: "Execution policy restriction"

**Solution**: Autoriser l'exécution de scripts PowerShell

```powershell
# Pour la session courante uniquement
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Permanent (nécessite droits admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problème: "No metrics data available"

**Causes possibles**:
1. Période de temps incorrecte (métriques pas encore disponibles)
2. Ressource non active pendant la période
3. Permissions insuffisantes

**Solutions**:
```powershell
# Vérifier les permissions
Get-AzRoleAssignment | Where-Object { $_.Scope -like "*terracloud*" }

# Attendre 2-3 minutes après le test
Start-Sleep -Seconds 180

# Vérifier que la ressource était active
Get-AzVM -ResourceGroupName "terracloud-rg" -Name "terracloud-vm-01" -Status
```

### Problème: "Resource not found"

**Solution**: Vérifier les noms de ressources

```powershell
# Lister toutes les ressources du groupe
Get-AzResource -ResourceGroupName "terracloud-rg" | Format-Table Name, ResourceType

# Lister tous les resource groups
Get-AzResourceGroup | Format-Table ResourceGroupName, Location
```

---

## 📚 Ressources

### Documentation

- [Guide complet Azure Monitor](../../docs/performance-plan/AZURE_MONITOR_SETUP.md)
- [Stratégie de tests](../../docs/performance-plan/strategy.md)
- [Tests Artillery](../../tests/performance/README.md)

### Liens externes

- [Azure Monitor PowerShell](https://docs.microsoft.com/powershell/module/az.monitor/)
- [Azure CLI Monitor](https://docs.microsoft.com/cli/azure/monitor)
- [VM Metrics Reference](https://docs.microsoft.com/azure/virtual-machines/monitor-vm-reference)
- [App Service Metrics](https://docs.microsoft.com/azure/app-service/web-sites-monitor)

---

## 🎯 Checklist rapide

Avant de lancer les tests:

- [ ] PowerShell ou Azure CLI installé
- [ ] Module Az installé (PowerShell) ou az login (CLI)
- [ ] Connexion Azure établie
- [ ] Script de validation exécuté avec succès
- [ ] Noms des ressources notés (ResourceGroup, VM, AppService)
- [ ] Variables d'environnement configurées
- [ ] Dossier de sortie créé

Après chaque test:

- [ ] Attendre 2-3 minutes après la fin du test
- [ ] Collecter les métriques avec le bon intervalle de temps
- [ ] Vérifier que les fichiers JSON sont créés
- [ ] Analyser rapidement les statistiques
- [ ] Sauvegarder les fichiers avec un nom descriptif
- [ ] Documenter dans le rapport de test

---

**Dernière mise à jour**: 2025-10-31
**Version**: 1.0
**Maintainer**: Syrine Ladhari
