# 📊 Comment voir les résultats - Guide complet

Ce guide te montre toutes les façons de voir les résultats de tes tests de performance.

---

## 🎯 Méthode 1: Résultats Artillery (pendant le test)

### Pendant l'exécution

Quand tu lances un test Artillery, les résultats s'affichent EN DIRECT dans le terminal :

```bash
cd tests/performance
artillery run -e iaas scenarios/normal-load.yml
```

**Tu verras** :

```
Test run id: abc123...
Phase started: ramp-up (duration: 120s)

--------------------------------------
Metrics for period to: 14:05:30
--------------------------------------

http.codes.200: ................... 145
http.request_rate: ................ 24/sec
http.response_time:
  min: ............................ 120
  max: ............................ 850
  median: ......................... 245
  p95: ............................ 680
  p99: ............................ 820

vusers.created: ................... 50
vusers.completed: ................. 48
```

### À la fin du test

```
--------------------------------
Summary report @ 14:15:30
--------------------------------

http.codes.200: ................... 2850
http.codes.500: ................... 15
http.request_rate: ................ 47/sec
http.requests: .................... 2865
http.response_time:
  min: ............................ 95
  max: ............................ 2150
  median: ......................... 320
  p95: ............................ 850
  p99: ............................ 1200

vusers.completed: ................. 590
vusers.failed: .................... 10
```

---

## 🎯 Méthode 2: Sauvegarder les résultats Artillery

### Avec fichier de sortie

```powershell
# Sauvegarder les résultats dans un fichier JSON
artillery run -e iaas scenarios/normal-load.yml --output results/test-$(Get-Date -Format 'yyyyMMdd-HHmmss').json
```

### Voir le fichier JSON

```powershell
# Lire le fichier
Get-Content .\results\test-20251031-140530.json | ConvertFrom-Json

# Voir un résumé
$results = Get-Content .\results\test-20251031-140530.json | ConvertFrom-Json
$results.aggregate | Format-List

# Afficher les métriques HTTP
$results.aggregate.counters
$results.aggregate.rates
$results.aggregate.summaries
```

### Générer un rapport HTML

```bash
# Artillery génère automatiquement un rapport HTML
artillery report results/test-20251031-140530.json

# Ouvre : results/test-20251031-140530.json.html
```

---

## 🎯 Méthode 3: Métriques Azure Monitor (PowerShell)

### Étape 1: Collecter les métriques

```powershell
# Se connecter à Azure (une seule fois)
Connect-AzAccount

# Collecter les métriques IaaS
cd C:\Users\ladhe\Desktop\terracloud-infrastructure
.\scripts\monitoring\Collect-Metrics.ps1 `
    -Type IaaS `
    -ResourceGroup "votre-rg" `
    -VMName "votre-vm" `
    -DurationMinutes 15
```

**Tu verras** :

```
📊 Collecte des métriques Azure Monitor - IaaS
================================================

Subscription: TerraCloud-Subscription
Période: 2025-10-31 14:00 à 2025-10-31 14:15

═══ Métriques IaaS (VM: terracloud-vm-01) ═══

📥 Collecte: CPU Percentage... ✅ 15 points
   📊 Moyenne: 52.3% | Min: 45.1% | Max: 68.5%
📥 Collecte: Available Memory... ✅ 15 points
📥 Collecte: Network In... ✅ 15 points
📥 Collecte: Network Out... ✅ 15 points
📥 Collecte: Disk Read... ✅ 15 points
📥 Collecte: Disk Write... ✅ 15 points

================================================
✅ Collecte terminée !

📁 Fichiers créés dans: .\metrics
   IaaS: 6 fichiers
```

### Étape 2: Voir les métriques collectées

```powershell
# Lister les fichiers créés
Get-ChildItem .\metrics\iaas\

# Voir le contenu d'un fichier CPU
$cpu = Get-Content .\metrics\iaas\*-cpu-*.json | ConvertFrom-Json

# Afficher les statistiques
$cpu.Data | Measure-Object -Property Average -Average -Maximum -Minimum

# Afficher sous forme de tableau
$cpu.Data | Format-Table TimeStamp, Average, Minimum, Maximum -AutoSize
```

**Tu verras** :

```
TimeStamp                Average  Minimum  Maximum
---------                -------  -------  -------
2025-10-31 14:00:00      45.2     42.1     48.5
2025-10-31 14:01:00      52.1     48.9     55.7
2025-10-31 14:02:00      48.5     46.2     52.1
...
```

### Étape 3: Analyser les données

```powershell
# Calculer la moyenne CPU
$cpuData = Get-Content .\metrics\iaas\*-cpu-*.json | ConvertFrom-Json
$avgCpu = ($cpuData.Data.Average | Measure-Object -Average).Average
Write-Host "CPU moyen: $([math]::Round($avgCpu, 2))%"

# Trouver le pic maximum
$maxCpu = ($cpuData.Data.Maximum | Measure-Object -Maximum).Maximum
Write-Host "CPU max: $maxCpu%"

# Compter les points au-dessus de 70%
$highCpu = ($cpuData.Data.Average | Where-Object { $_ -gt 70 }).Count
Write-Host "Points > 70%: $highCpu"
```

---

## 🎯 Méthode 4: Portail Azure (Interface graphique)

### Option la plus visuelle !

1. **Ouvrir le portail Azure**
   ```
   https://portal.azure.com
   ```

2. **Naviguer vers ta ressource**
   - Pour IaaS : `Virtual Machines` → Sélectionner ta VM
   - Pour PaaS : `App Services` → Sélectionner ton App Service

3. **Cliquer sur "Metrics"** (dans le menu gauche)

4. **Configurer le graphique**
   - **Metric** : Sélectionner "Percentage CPU"
   - **Time range** : Sélectionner l'heure de ton test
   - **Time granularity** : 1 minute

5. **Ajouter d'autres métriques**
   - Cliquer sur "Add metric"
   - Sélectionner "Available Memory Bytes", "Network In", etc.

6. **Exporter les données**
   - Cliquer sur "Download to Excel"
   - Fichier Excel téléchargé avec toutes les données

### Capture d'écran

Tu verras un graphique comme ça :
```
CPU (%)
100 |
 80 |                    ╱╲
 60 |         ╱╲    ╱╲  /  \
 40 |    ╱╲  /  \  /  \/    \
 20 | __/  \/    \/
  0 |_________________________
    14:00 14:05 14:10 14:15
```

---

## 🎯 Méthode 5: Script d'analyse automatique

Je vais te créer un script pour analyser automatiquement !

### Utiliser le script d'analyse

```powershell
# À venir : script pour comparer IaaS vs PaaS automatiquement
.\scripts\monitoring\Analyze-Results.ps1 `
    -ArtilleryFile "results/iaas-test.json" `
    -AzureMetricsDir "metrics/iaas"
```

---

## 📊 Comparaison IaaS vs PaaS

### Tableau de comparaison

```powershell
# Charger les deux ensembles de métriques
$iaasCpu = Get-Content .\metrics\iaas\*-cpu-*.json | ConvertFrom-Json
$paasCpu = Get-Content .\metrics\paas\*-cpu-*.json | ConvertFrom-Json

# Calculer les moyennes
$iaasAvg = ($iaasCpu.Data.Average | Measure-Object -Average).Average
$paasAvg = ($paasCpu.Data.Average | Measure-Object -Average).Average

# Afficher la comparaison
Write-Host ""
Write-Host "═══════════════════════════════" -ForegroundColor Cyan
Write-Host "  COMPARAISON IaaS vs PaaS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "CPU IaaS moyen : $([math]::Round($iaasAvg, 2))%" -ForegroundColor Yellow
Write-Host "CPU PaaS moyen : $([math]::Round($paasAvg, 2))%" -ForegroundColor Yellow
Write-Host "Différence     : $([math]::Round($iaasAvg - $paasAvg, 2))%" -ForegroundColor $(if ($iaasAvg -lt $paasAvg) { "Green" } else { "Red" })
Write-Host ""

$winner = if ($iaasAvg -lt $paasAvg) { "IaaS" } else { "PaaS" }
Write-Host "🏆 Gagnant: $winner (CPU plus faible = meilleur)" -ForegroundColor Green
```

---

## 🎯 Exemple complet de bout en bout

### Workflow complet

```powershell
# 1. Lancer le test Artillery
cd tests\performance
artillery run -e iaas scenarios\normal-load.yml --output ..\results\iaas-test.json

# 2. Attendre 2-3 minutes
Start-Sleep -Seconds 180

# 3. Collecter les métriques Azure
cd ..\..
.\scripts\monitoring\Collect-Metrics.ps1 -Type IaaS -DurationMinutes 15

# 4. Voir les résultats Artillery
$artillery = Get-Content .\results\iaas-test.json | ConvertFrom-Json
Write-Host "Total requêtes: $($artillery.aggregate.counters.'http.requests')"
Write-Host "Temps réponse p95: $($artillery.aggregate.summaries.'http.response_time'.p95) ms"
Write-Host "Taux erreur: $($artillery.aggregate.counters.'vusers.failed' / $artillery.aggregate.counters.'vusers.created' * 100)%"

# 5. Voir les métriques Azure
$cpu = Get-Content .\metrics\iaas\*-cpu-*.json | ConvertFrom-Json
$avgCpu = ($cpu.Data.Average | Measure-Object -Average).Average
Write-Host "CPU moyen Azure: $([math]::Round($avgCpu, 2))%"

# 6. Générer un rapport HTML Artillery
artillery report .\results\iaas-test.json
Start-Process .\results\iaas-test.json.html
```

---

## 🔍 Commandes rapides utiles

### Voir rapidement les résultats

```powershell
# Derniers résultats Artillery
Get-Content (Get-ChildItem .\results\*.json | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName | ConvertFrom-Json | Select-Object -ExpandProperty aggregate

# Dernières métriques CPU
Get-Content (Get-ChildItem .\metrics\iaas\*-cpu-*.json | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName | ConvertFrom-Json | Select-Object -ExpandProperty Data | Measure-Object -Property Average -Average -Maximum -Minimum

# Ouvrir le portail Azure
Start-Process "https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Compute%2FVirtualMachines"
```

---

## 💡 Conseils pratiques

### Pendant le test
- Garde le terminal ouvert pour voir les métriques en temps réel
- Ouvre le portail Azure dans un navigateur en parallèle
- Note l'heure exacte de début et fin

### Après le test
- Attends 2-3 minutes avant de collecter les métriques Azure
- Sauvegarde TOUJOURS les résultats Artillery avec `--output`
- Renomme les fichiers de façon claire : `iaas-normal-load-20251031.json`

### Pour l'analyse
- Compare toujours les mêmes périodes de temps
- Vérifie que les métriques Artillery et Azure sont cohérentes
- Documente tout dans le template de rapport

---

## 📁 Structure des résultats

```
terracloud-infrastructure/
├── results/                    # Résultats Artillery
│   ├── iaas-normal-20251031.json
│   ├── iaas-normal-20251031.json.html
│   ├── paas-normal-20251031.json
│   └── paas-normal-20251031.json.html
├── metrics/                    # Métriques Azure
│   ├── iaas/
│   │   ├── vm-cpu-20251031-140530.json
│   │   ├── vm-memory-20251031-140530.json
│   │   └── ...
│   └── paas/
│       ├── app-cpu-20251031-150530.json
│       └── ...
└── docs/
    └── performance-plan/
        └── results/           # Rapports finaux
            ├── iaas-normal-load-report.md
            └── paas-normal-load-report.md
```

---

## 🎓 En résumé

**Pour voir les résultats, tu as 5 options** :

1. ✅ **Terminal** : Résultats en direct pendant le test
2. ✅ **Fichiers JSON** : Artillery sauvegarde tout
3. ✅ **Rapports HTML** : Artillery génère des graphiques
4. ✅ **Scripts PowerShell** : Analyse automatique des métriques Azure
5. ✅ **Portail Azure** : Interface graphique avec graphiques interactifs

**Le plus simple pour commencer** :
1. Lance Artillery et regarde le terminal
2. Génère le rapport HTML : `artillery report results/test.json`
3. Ouvre le fichier HTML dans ton navigateur

**Le plus complet** :
1. Artillery avec `--output`
2. Collect-Metrics.ps1
3. Template de rapport rempli manuellement
4. Portail Azure pour vérifier

---

**Prêt à tester ?** Essaie d'abord le script de démo :

```powershell
.\scripts\monitoring\View-Metrics-Demo.ps1
```

Puis quand tu as Azure configuré, lance un vrai test ! 🚀
