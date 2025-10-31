# Configuration Azure Monitor pour Tests de Performance

## Document Information
- **Projet**: TerraCloud Infrastructure Comparison
- **Tâche**: Configuration du monitoring pour tests de performance
- **Owner**: Syrine Ladhari
- **Version**: 1.0
- **Dernière mise à jour**: 2025-10-31

---

## Table des matières
1. [Vue d'ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Configuration IaaS (VMs)](#configuration-iaas-vms)
4. [Configuration PaaS (App Service)](#configuration-paas-app-service)
5. [Collecte des métriques](#collecte-des-métriques)
6. [Scripts de validation](#scripts-de-validation)
7. [Coordination équipe](#coordination-équipe)

---

## Vue d'ensemble

### Objectifs
- Monitorer les performances pendant les tests Artillery
- Collecter les métriques CPU, mémoire, réseau, requêtes
- Comparer les performances IaaS vs PaaS
- Identifier les goulots d'étranglement

### Métriques à surveiller

#### Pour IaaS (Virtual Machines)
- **CPU**: Pourcentage d'utilisation
- **Mémoire**: Utilisation RAM
- **Réseau**: Bytes in/out
- **Disque**: I/O operations
- **Requêtes HTTP**: Via Application Insights (optionnel)

#### Pour PaaS (App Service)
- **CPU**: Pourcentage d'utilisation
- **Mémoire**: Working set
- **Requêtes HTTP**: Count, temps de réponse
- **Erreurs HTTP**: 4xx, 5xx
- **Disponibilité**: Uptime

---

## Prérequis

### Accès Azure
```bash
# Vérifier l'accès Azure CLI
az login
az account show

# Vérifier les ressources disponibles
az resource list --output table
```

### Permissions requises
- Lecteur sur le groupe de ressources
- Contributeur de surveillance (Monitoring Contributor)
- Accès au portail Azure

### Outils nécessaires
- Azure CLI installé
- PowerShell (pour Windows)
- Navigateur web pour le portail Azure

---

## Configuration IaaS (VMs)

### Étape 1: Activer Azure Monitor pour les VMs

#### Via le portail Azure

1. **Naviguer vers votre VM**
   ```
   Portail Azure → Virtual Machines → [Votre VM]
   ```

2. **Activer Insights**
   - Cliquer sur "Insights" dans le menu gauche
   - Cliquer sur "Enable"
   - Sélectionner l'espace de travail Log Analytics
   - Attendre 5-10 minutes pour l'activation

3. **Vérifier l'activation**
   - Aller dans "Metrics"
   - Vérifier que les métriques s'affichent

#### Via Azure CLI

```bash
# Variables à configurer
RESOURCE_GROUP="terracloud-rg"
VM_NAME="terracloud-vm-01"
LOCATION="eastus"
WORKSPACE_NAME="terracloud-logs"

# Créer un Log Analytics Workspace (si non existant)
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME \
  --location $LOCATION

# Obtenir l'ID du workspace
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME \
  --query id -o tsv)

# Activer l'extension de monitoring sur la VM
az vm extension set \
  --resource-group $RESOURCE_GROUP \
  --vm-name $VM_NAME \
  --name AzureMonitorLinuxAgent \
  --publisher Microsoft.Azure.Monitor \
  --settings "{\"workspaceId\":\"$WORKSPACE_ID\"}"
```

### Étape 2: Configurer les alertes (optionnel)

```bash
# Alerte CPU > 80%
az monitor metrics alert create \
  --name "vm-high-cpu" \
  --resource-group $RESOURCE_GROUP \
  --scopes "/subscriptions/{subscription-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME" \
  --condition "avg Percentage CPU > 80" \
  --description "Alert when CPU exceeds 80%"
```

### Étape 3: Métriques à collecter pour IaaS

| Métrique | Nom Azure Monitor | Unité | Fréquence |
|----------|-------------------|-------|-----------|
| CPU | `Percentage CPU` | % | 1 minute |
| Mémoire | `Available Memory Bytes` | Bytes | 1 minute |
| Réseau In | `Network In Total` | Bytes | 1 minute |
| Réseau Out | `Network Out Total` | Bytes | 1 minute |
| Disque Read | `Disk Read Bytes` | Bytes/sec | 1 minute |
| Disque Write | `Disk Write Bytes` | Bytes/sec | 1 minute |

---

## Configuration PaaS (App Service)

### Étape 1: Activer Application Insights

#### Via le portail Azure

1. **Naviguer vers votre App Service**
   ```
   Portail Azure → App Services → [Votre App]
   ```

2. **Activer Application Insights**
   - Menu gauche → "Application Insights"
   - Cliquer sur "Turn on Application Insights"
   - Créer une nouvelle ressource ou sélectionner existante
   - Cliquer sur "Apply"

3. **Configuration recommandée**
   - Niveau de collecte: Standard
   - Profiler: Activé
   - Snapshot debugger: Activé (optionnel)

#### Via Azure CLI

```bash
# Variables
RESOURCE_GROUP="terracloud-rg"
APP_NAME="terracloud-paas"
LOCATION="eastus"
APPINSIGHTS_NAME="terracloud-appinsights"

# Créer Application Insights
az monitor app-insights component create \
  --app $APPINSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --application-type web

# Obtenir l'instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app $APPINSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv)

# Configurer l'App Service avec Application Insights
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY
```

### Étape 2: Métriques à collecter pour PaaS

| Métrique | Nom Azure Monitor | Unité | Fréquence |
|----------|-------------------|-------|-----------|
| CPU | `CpuPercentage` | % | 1 minute |
| Mémoire | `MemoryWorkingSet` | Bytes | 1 minute |
| Requêtes | `Requests` | Count | 1 minute |
| Temps réponse | `AverageResponseTime` | Seconds | 1 minute |
| HTTP 2xx | `Http2xx` | Count | 1 minute |
| HTTP 4xx | `Http4xx` | Count | 1 minute |
| HTTP 5xx | `Http5xx` | Count | 1 minute |

---

## Collecte des métriques

### Option 1: Via le portail Azure (Manuel)

#### Pendant le test

1. **Ouvrir le portail Azure**
2. **Naviguer vers la ressource** (VM ou App Service)
3. **Aller dans "Metrics"**
4. **Ajouter les métriques importantes**:
   - CPU
   - Mémoire
   - Requêtes HTTP

5. **Configurer la période**:
   - Début: Heure de début du test
   - Fin: Heure de fin du test
   - Granularité: 1 minute

#### Après le test

1. **Exporter les données**:
   - Cliquer sur "Download to Excel"
   - Sauvegarder le fichier avec nom descriptif
   - Format: `{resource}-{test-type}-{date}.xlsx`

### Option 2: Via Azure CLI (Automatisé)

#### Script de collecte de métriques IaaS

```bash
#!/bin/bash
# collect-iaas-metrics.sh

RESOURCE_GROUP="terracloud-rg"
VM_NAME="terracloud-vm-01"
START_TIME="2025-10-31T14:00:00Z"
END_TIME="2025-10-31T14:15:00Z"
OUTPUT_DIR="./metrics"

mkdir -p $OUTPUT_DIR

echo "Collecte des métriques pour $VM_NAME..."

# CPU
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME" \
  --metric "Percentage CPU" \
  --start-time $START_TIME \
  --end-time $END_TIME \
  --interval PT1M \
  --output json > "$OUTPUT_DIR/${VM_NAME}-cpu.json"

# Mémoire
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME" \
  --metric "Available Memory Bytes" \
  --start-time $START_TIME \
  --end-time $END_TIME \
  --interval PT1M \
  --output json > "$OUTPUT_DIR/${VM_NAME}-memory.json"

# Réseau
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME" \
  --metric "Network In Total" \
  --start-time $START_TIME \
  --end-time $END_TIME \
  --interval PT1M \
  --output json > "$OUTPUT_DIR/${VM_NAME}-network-in.json"

echo "✅ Métriques collectées dans $OUTPUT_DIR"
```

#### Script de collecte de métriques PaaS

```bash
#!/bin/bash
# collect-paas-metrics.sh

RESOURCE_GROUP="terracloud-rg"
APP_NAME="terracloud-paas"
START_TIME="2025-10-31T14:00:00Z"
END_TIME="2025-10-31T14:15:00Z"
OUTPUT_DIR="./metrics"

mkdir -p $OUTPUT_DIR

echo "Collecte des métriques pour $APP_NAME..."

# CPU
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
  --metric "CpuPercentage" \
  --start-time $START_TIME \
  --end-time $END_TIME \
  --interval PT1M \
  --output json > "$OUTPUT_DIR/${APP_NAME}-cpu.json"

# Requêtes HTTP
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
  --metric "Requests" \
  --start-time $START_TIME \
  --end-time $END_TIME \
  --interval PT1M \
  --output json > "$OUTPUT_DIR/${APP_NAME}-requests.json"

# Temps de réponse
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
  --metric "AverageResponseTime" \
  --start-time $START_TIME \
  --end-time $END_TIME \
  --interval PT1M \
  --output json > "$OUTPUT_DIR/${APP_NAME}-response-time.json"

echo "✅ Métriques collectées dans $OUTPUT_DIR"
```

### Option 3: Via PowerShell (Windows)

```powershell
# collect-metrics.ps1

$ResourceGroup = "terracloud-rg"
$VMName = "terracloud-vm-01"
$StartTime = (Get-Date).AddMinutes(-15)
$EndTime = Get-Date
$OutputDir = ".\metrics"

New-Item -ItemType Directory -Force -Path $OutputDir

Write-Host "Collecte des métriques pour $VMName..."

# CPU
Get-AzMetric `
  -ResourceId "/subscriptions/{sub-id}/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$VMName" `
  -MetricName "Percentage CPU" `
  -StartTime $StartTime `
  -EndTime $EndTime `
  -TimeGrain 00:01:00 |
  ConvertTo-Json |
  Out-File "$OutputDir\$VMName-cpu.json"

Write-Host "✅ Métriques collectées"
```

---

## Scripts de validation

### Script de vérification du monitoring

Créons un script pour vérifier que tout est bien configuré :

```bash
#!/bin/bash
# validate-monitoring.sh

echo "🔍 Validation de la configuration Azure Monitor..."

RESOURCE_GROUP="terracloud-rg"
VM_NAME="terracloud-vm-01"
APP_NAME="terracloud-paas"

# Vérifier la connexion Azure
echo "1. Vérification de la connexion Azure..."
if az account show &>/dev/null; then
    echo "   ✅ Connecté à Azure"
else
    echo "   ❌ Non connecté à Azure - Exécutez 'az login'"
    exit 1
fi

# Vérifier l'existence des ressources
echo "2. Vérification des ressources..."

if az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME &>/dev/null; then
    echo "   ✅ VM trouvée: $VM_NAME"
else
    echo "   ⚠️  VM non trouvée: $VM_NAME"
fi

if az webapp show --resource-group $RESOURCE_GROUP --name $APP_NAME &>/dev/null; then
    echo "   ✅ App Service trouvée: $APP_NAME"
else
    echo "   ⚠️  App Service non trouvée: $APP_NAME"
fi

# Vérifier les métriques disponibles
echo "3. Vérification des métriques disponibles..."

END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
START_TIME=$(date -u -d '5 minutes ago' +"%Y-%m-%dT%H:%M:%SZ")

METRICS=$(az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME" \
  --metric "Percentage CPU" \
  --start-time $START_TIME \
  --end-time $END_TIME \
  --interval PT1M 2>/dev/null)

if [ ! -z "$METRICS" ]; then
    echo "   ✅ Métriques CPU accessibles"
else
    echo "   ❌ Impossible d'accéder aux métriques"
fi

echo ""
echo "✅ Validation terminée"
```

---

## Coordination équipe

### Checklist avant les tests

#### Communication avec l'équipe

**Email/Message type**:
```
Objet: [TerraCloud] Configuration Azure Monitor pour tests de performance

Équipe,

Je vais configurer Azure Monitor pour les tests de performance.

Informations nécessaires:
- Nom du groupe de ressources: _______
- Nom de la VM IaaS: _______
- Nom de l'App Service PaaS: _______
- Subscription ID: _______
- Accès Azure: Monitoring Contributor requis

Actions requises:
1. Eloi Terrol: Vérifier que je peux accéder aux VMs
2. Axel Bacquet: Vérifier que je peux accéder à l'App Service
3. Hanene Triaa: Valider la configuration des alertes

Planning:
- Configuration: [DATE]
- Tests de validation: [DATE]
- Premiers tests réels: [DATE]

Merci,
Syrine
```

### Informations à collecter

| Information | Contact | Status |
|------------|---------|--------|
| Resource Group Name | Eloi / Axel | ⬜ |
| Subscription ID | Hanene | ⬜ |
| VM Names | Eloi | ⬜ |
| App Service Name | Axel | ⬜ |
| Load Balancer URL | Eloi | ⬜ |
| App Service URL | Axel | ⬜ |
| Permissions Azure | Hanene | ⬜ |

---

## Tests de validation

### Test 1: Vérifier l'accès aux métriques

```bash
# Remplacer les valeurs
RESOURCE_GROUP="votre-resource-group"
VM_NAME="votre-vm"

# Tester la collecte de métriques
az monitor metrics list \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Compute/virtualMachines" \
  --resource-name $VM_NAME \
  --metric "Percentage CPU" \
  --start-time $(date -u -d '10 minutes ago' +"%Y-%m-%dT%H:%M:%SZ") \
  --end-time $(date -u +"%Y-%m-%dT%H:%M:%SZ")
```

**Résultat attendu**: Liste de métriques avec valeurs

### Test 2: Vérifier la collecte en temps réel

1. Lancer un petit test Artillery (1 minute)
2. Pendant le test, vérifier le portail Azure
3. Les métriques doivent augmenter (CPU, requêtes)
4. Après le test, les métriques redescendent

### Test 3: Exporter les données

1. Aller dans Metrics sur le portail
2. Sélectionner une métrique
3. Cliquer sur "Download to Excel"
4. Vérifier que le fichier contient les données

---

## Troubleshooting

### Problème: Métriques non disponibles

**Symptômes**: Aucune donnée dans Azure Monitor

**Solutions**:
1. Vérifier que la ressource est bien démarrée
2. Attendre 5-10 minutes après activation
3. Vérifier les permissions Azure
4. Essayer de rafraîchir la page du portail

### Problème: Extension de monitoring échoue

**Symptômes**: Erreur lors de l'installation de l'agent

**Solutions**:
1. Vérifier que la VM est sous Linux/Windows supporté
2. Vérifier l'espace disque disponible
3. Redémarrer la VM
4. Réessayer l'installation

### Problème: Impossible d'exporter les données

**Symptômes**: Bouton "Download" grisé

**Solutions**:
1. Vérifier que la période sélectionnée contient des données
2. Réduire la période de temps
3. Utiliser Azure CLI pour exporter

---

## Templates de rapport

### Template de collecte de métriques

```markdown
# Métriques Azure Monitor - [TEST_NAME]

## Informations du test
- Date: YYYY-MM-DD
- Heure début: HH:MM
- Heure fin: HH:MM
- Type de test: Normal Load / Stress / Spike
- Infrastructure: IaaS / PaaS

## Métriques CPU
- Moyenne: ____%
- Maximum: ____%
- Minimum: ____%

## Métriques Mémoire
- Moyenne: ____ MB
- Maximum: ____ MB
- Minimum: ____ MB

## Métriques Requêtes (PaaS uniquement)
- Total requêtes: ____
- Requêtes/sec moyenne: ____
- Temps de réponse moyen: ____ ms

## Observations
- [Notes sur le comportement du système]
- [Pics observés]
- [Anomalies]

## Fichiers de données
- CPU: [lien vers fichier]
- Mémoire: [lien vers fichier]
- Réseau: [lien vers fichier]
```

---

## Ressources

### Documentation Azure
- [Azure Monitor Overview](https://docs.microsoft.com/azure/azure-monitor/)
- [VM Metrics](https://docs.microsoft.com/azure/virtual-machines/monitor-vm-reference)
- [App Service Metrics](https://docs.microsoft.com/azure/app-service/web-sites-monitor)
- [Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)

### Commandes utiles

```bash
# Lister toutes les métriques disponibles
az monitor metrics list-definitions \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Compute/virtualMachines" \
  --resource-name $VM_NAME

# Obtenir l'ID complet d'une ressource
az vm show \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --query id -o tsv

# Tester une query Log Analytics
az monitor log-analytics query \
  --workspace $WORKSPACE_ID \
  --analytics-query "Perf | where CounterName == '% Processor Time' | take 10"
```

---

## Checklist finale

Avant de démarrer les tests, vérifier:

- [ ] Azure CLI installé et configuré
- [ ] Connexion Azure établie (`az login`)
- [ ] Permissions de monitoring accordées
- [ ] Noms des ressources collectés
- [ ] Azure Monitor activé sur toutes les ressources
- [ ] Application Insights configuré (PaaS)
- [ ] Scripts de collecte testés
- [ ] Template de rapport préparé
- [ ] Équipe informée du planning
- [ ] Procédure de sauvegarde des données documentée

---

**Dernière mise à jour**: 2025-10-31
**Version**: 1.0
**Maintainer**: Syrine Ladhari
