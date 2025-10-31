# 📊 Status Configuration Azure Monitor - TerraCloud

**Date**: 2025-10-31
**Status global**: ✅ **DOCUMENTATION COMPLÈTE**

---

## ✅ Ce qui a été créé

### 1. Documentation

| Fichier | Description | Status |
|---------|-------------|--------|
| `AZURE_MONITOR_SETUP.md` | Guide complet de configuration | ✅ Créé |
| `MONITORING_STATUS.md` | Ce document - Status | ✅ Créé |
| `results/METRICS_REPORT_TEMPLATE.md` | Template de rapport métriques | ✅ Créé |

### 2. Scripts PowerShell (Windows)

| Script | Description | Status |
|--------|-------------|--------|
| `Validate-AzureMonitor.ps1` | Validation configuration | ✅ Créé |
| `Collect-Metrics.ps1` | Collecte métriques complète | ✅ Créé |

### 3. Scripts Bash (Linux/Mac)

| Script | Description | Status |
|--------|-------------|--------|
| `validate-azure-monitor.sh` | Validation configuration | ✅ Créé |
| `collect-iaas-metrics.sh` | Collecte métriques IaaS | ✅ Créé |
| `collect-paas-metrics.sh` | Collecte métriques PaaS | ✅ Créé |

### 4. Documentation scripts

| Fichier | Description | Status |
|---------|-------------|--------|
| `scripts/monitoring/README.md` | Guide d'utilisation scripts | ✅ Créé |

---

## 📋 Configuration Azure Monitor

### Métriques IaaS (Virtual Machines)

| Métrique | Nom Azure | Fréquence | Script |
|----------|-----------|-----------|--------|
| CPU | `Percentage CPU` | 1 min | ✅ |
| Mémoire | `Available Memory Bytes` | 1 min | ✅ |
| Réseau In | `Network In Total` | 1 min | ✅ |
| Réseau Out | `Network Out Total` | 1 min | ✅ |
| Disque Read | `Disk Read Bytes` | 1 min | ✅ |
| Disque Write | `Disk Write Bytes` | 1 min | ✅ |

### Métriques PaaS (App Service)

| Métrique | Nom Azure | Fréquence | Script |
|----------|-----------|-----------|--------|
| CPU | `CpuPercentage` | 1 min | ✅ |
| Mémoire | `MemoryWorkingSet` | 1 min | ✅ |
| Requêtes | `Requests` | 1 min | ✅ |
| Temps réponse | `AverageResponseTime` | 1 min | ✅ |
| HTTP 2xx | `Http2xx` | 1 min | ✅ |
| HTTP 4xx | `Http4xx` | 1 min | ✅ |
| HTTP 5xx | `Http5xx` | 1 min | ✅ |
| Bytes In | `BytesReceived` | 1 min | ✅ |
| Bytes Out | `BytesSent` | 1 min | ✅ |

---

## 🚀 Comment utiliser

### Workflow recommandé

```
1. Validation
   └─> Validate-AzureMonitor.ps1
       └─> ✅ Vérifier que tout fonctionne

2. Test de performance
   └─> artillery run -e iaas scenarios/normal-load.yml
       └─> Noter heure début/fin

3. Collecte métriques (attendre 2-3 min après le test)
   └─> Collect-Metrics.ps1 -Type IaaS
       └─> Fichiers JSON dans ./metrics/

4. Analyse
   └─> Utiliser METRICS_REPORT_TEMPLATE.md
       └─> Remplir avec les données collectées

5. Comparaison IaaS vs PaaS
   └─> Répéter 2-4 pour PaaS
       └─> Comparer les résultats
```

### Quick Start (Windows)

```powershell
# 1. Installation
Install-Module -Name Az -Scope CurrentUser
Connect-AzAccount

# 2. Validation
cd C:\Users\ladhe\Desktop\terracloud-infrastructure
.\scripts\monitoring\Validate-AzureMonitor.ps1 `
    -ResourceGroup "votre-rg" `
    -VMName "votre-vm" `
    -AppName "votre-app"

# 3. Après un test Artillery
.\scripts\monitoring\Collect-Metrics.ps1 `
    -Type IaaS `
    -ResourceGroup "votre-rg" `
    -VMName "votre-vm" `
    -DurationMinutes 15
```

---

## 📖 Documentation disponible

### Guides principaux

1. **[AZURE_MONITOR_SETUP.md](./AZURE_MONITOR_SETUP.md)**
   - Configuration complète Azure Monitor
   - Instructions détaillées IaaS et PaaS
   - Exemples de commandes
   - Troubleshooting complet

2. **[scripts/monitoring/README.md](../../scripts/monitoring/README.md)**
   - Guide d'utilisation des scripts
   - Workflow complet
   - Exemples d'analyse
   - FAQ

3. **[METRICS_REPORT_TEMPLATE.md](./results/METRICS_REPORT_TEMPLATE.md)**
   - Template de rapport structuré
   - Toutes les métriques à documenter
   - Critères de succès
   - Recommandations

### Autres ressources

- [Strategy.md](./strategy.md) - Stratégie globale tests
- [COMPARISON_METHODOLOGY.md](./COMPARISON_METHODOLOGY.md) - Méthodologie comparaison
- [tests/performance/README.md](../../tests/performance/README.md) - Guide Artillery

---

## ✅ Checklist de préparation

### Avant le premier test

- [ ] Azure CLI ou PowerShell Az installé
- [ ] Connexion Azure établie (`Connect-AzAccount` ou `az login`)
- [ ] Validation exécutée avec succès
- [ ] Informations ressources collectées:
  - [ ] Subscription ID
  - [ ] Resource Group name
  - [ ] VM name (IaaS)
  - [ ] App Service name (PaaS)
  - [ ] Load Balancer URL (IaaS)
  - [ ] App Service URL (PaaS)
- [ ] Permissions vérifiées (Monitoring Contributor)
- [ ] Scripts testés sur une ressource de test
- [ ] Template de rapport téléchargé et prêt

### Avant chaque test

- [ ] Ressources Azure en cours d'exécution
- [ ] Scripts de collecte prêts
- [ ] Dossier `metrics/` créé
- [ ] Heure de début notée
- [ ] Équipe notifiée du test en cours

### Après chaque test

- [ ] Attendre 2-3 minutes
- [ ] Collecter les métriques avec le bon intervalle
- [ ] Vérifier que les fichiers JSON sont créés
- [ ] Renommer les fichiers de façon descriptive
- [ ] Remplir le template de rapport
- [ ] Sauvegarder dans `docs/performance-plan/results/`

---

## 🎯 Métriques clés à surveiller

### Critères de succès pour tests normaux

| Métrique | Seuil IaaS | Seuil PaaS | Importance |
|----------|------------|------------|------------|
| CPU moyen | < 70% | < 70% | 🔴 Critique |
| CPU max | < 85% | < 85% | 🟠 Important |
| Mémoire stable | Oui | Oui | 🔴 Critique |
| Temps réponse p95 | < 1000ms | < 500ms | 🔴 Critique |
| Taux d'erreur | < 1% | < 1% | 🔴 Critique |
| HTTP 5xx | < 0.1% | < 0.1% | 🟠 Important |

### Indicateurs de problème

⚠️ **Signes d'alerte**:
- CPU > 85% de façon soutenue
- Mémoire en croissance continue (fuite)
- Temps de réponse > 2000ms
- Taux d'erreur > 5%
- Nombreuses erreurs 5xx

🚨 **Signes critiques**:
- CPU > 95%
- Mémoire saturée
- Système ne répond plus
- Taux d'erreur > 10%
- Downtime

---

## 💡 Conseils pratiques

### Timing optimal

```
Test Artillery: 10-15 minutes
     ↓
Attente: 2-3 minutes (métriques Azure se stabilisent)
     ↓
Collecte: Spécifier durée = durée_test + 5 minutes
     ↓
Analyse: Immédiate (données fraîches en mémoire)
```

### Nommage des fichiers

```
Bonne pratique:
metrics/
├── iaas/
│   ├── iaas-normal-load-20251031-140000/
│   │   ├── cpu.json
│   │   ├── memory.json
│   │   └── network.json
│   └── iaas-stress-test-20251031-150000/
│       └── ...
└── paas/
    └── ...
```

### Sauvegarde des données

```powershell
# Après chaque test, créer une archive
$TestName = "iaas-normal-load-20251031"
Compress-Archive `
    -Path ".\metrics\iaas\$TestName*" `
    -DestinationPath ".\archives\$TestName.zip"
```

---

## 🔄 Intégration avec Artillery

### Synchronisation des timestamps

```powershell
# Avant le test Artillery
$TestStart = Get-Date
Write-Host "Test start: $($TestStart.ToString('yyyy-MM-dd HH:mm:ss'))"

# Lancer Artillery
artillery run -e iaas scenarios/normal-load.yml

# Après le test
$TestEnd = Get-Date
$Duration = [math]::Ceiling(($TestEnd - $TestStart).TotalMinutes)

# Collecter avec la bonne période
.\scripts\monitoring\Collect-Metrics.ps1 `
    -Type IaaS `
    -DurationMinutes ($Duration + 2)
```

### Corrélation des données

```
Artillery JSON + Azure Monitor JSON = Analyse complète

Exemple:
- Artillery dit: "p95 = 450ms, 2% erreurs"
- Azure dit: "CPU = 65%, HTTP 5xx = 15 requêtes"
- Conclusion: Performance acceptable, erreurs liées à [cause]
```

---

## 📊 Exemples d'analyse

### Exemple 1: Test réussi

```
Métriques:
- CPU moyen: 55%, max: 72%
- Mémoire stable: 2.1GB - 2.3GB
- Temps réponse p95: 380ms
- Taux d'erreur: 0.2%

✅ Conclusion: Performance excellente, système bien dimensionné
```

### Exemple 2: Goulot CPU

```
Métriques:
- CPU moyen: 82%, max: 98%
- Mémoire stable: 1.8GB
- Temps réponse p95: 1850ms
- Taux d'erreur: 4.5%

⚠️ Conclusion: CPU surchargé, recommandation: scale up VM
```

### Exemple 3: Fuite mémoire

```
Métriques:
- CPU moyen: 45%
- Mémoire: 1.2GB → 3.5GB (croissance continue)
- Temps réponse p95: 950ms (augmente avec le temps)
- Taux d'erreur: 1.2%

🔴 Conclusion: Fuite mémoire détectée, investigation code requise
```

---

## 🛠️ Maintenance

### Nettoyage des métriques

```powershell
# Supprimer les métriques de plus de 30 jours
Get-ChildItem .\metrics\ -Recurse -Filter "*.json" |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Remove-Item
```

### Archivage

```powershell
# Créer une archive mensuelle
$Month = (Get-Date).ToString("yyyy-MM")
Compress-Archive `
    -Path ".\metrics\*" `
    -DestinationPath ".\archives\metrics-$Month.zip"
```

---

## 📞 Support et contacts

### Équipe TerraCloud

| Rôle | Contact | Responsabilité |
|------|---------|----------------|
| Performance Testing | Syrine Ladhari | Tests et métriques |
| Infrastructure IaaS | Eloi Terrol | Configuration VMs |
| Déploiement PaaS | Axel Bacquet | App Services |
| Coordination | Hanene Triaa | Validation globale |

### Ressources externes

- [Documentation Azure Monitor](https://docs.microsoft.com/azure/azure-monitor/)
- [PowerShell Az.Monitor](https://docs.microsoft.com/powershell/module/az.monitor/)
- [Azure CLI Monitor](https://docs.microsoft.com/cli/azure/monitor)

---

## 🎉 Prêt à l'emploi

**Tout est en place pour**:
- ✅ Valider la configuration Azure Monitor
- ✅ Collecter automatiquement les métriques
- ✅ Analyser les performances IaaS et PaaS
- ✅ Comparer les résultats
- ✅ Générer des rapports professionnels

**Prochaine étape**: Obtenir les informations des ressources Azure auprès de l'équipe et lancer la validation !

---

**Dernière mise à jour**: 2025-10-31
**Version**: 1.0
**Status**: ✅ Production Ready
**Maintainer**: Syrine Ladhari
