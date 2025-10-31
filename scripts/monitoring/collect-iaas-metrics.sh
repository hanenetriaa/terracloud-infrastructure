#!/bin/bash
# collect-iaas-metrics.sh
# Script de collecte des métriques IaaS (VMs)
# Author: Syrine Ladhari
# Version: 1.0

set -e

echo "📊 Collecte des métriques IaaS Azure Monitor"
echo "============================================="
echo ""

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-terracloud-rg}"
VM_NAME="${VM_NAME:-terracloud-vm-01}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-}"
OUTPUT_DIR="${OUTPUT_DIR:-./metrics/iaas}"
START_TIME="${START_TIME:-}"
END_TIME="${END_TIME:-}"

# Si les temps ne sont pas fournis, utiliser les 15 dernières minutes
if [ -z "$START_TIME" ]; then
    START_TIME=$(date -u -d '15 minutes ago' +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-15M +"%Y-%m-%dT%H:%M:%SZ")
fi

if [ -z "$END_TIME" ]; then
    END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
fi

# Obtenir le Subscription ID
if [ -z "$SUBSCRIPTION_ID" ]; then
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
fi

# Créer le dossier de sortie
mkdir -p "$OUTPUT_DIR"

# Resource ID de la VM
VM_RESOURCE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME"

# Timestamp pour les fichiers
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

echo "Configuration:"
echo "  VM: $VM_NAME"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Période: $START_TIME à $END_TIME"
echo "  Sortie: $OUTPUT_DIR"
echo ""

# Fonction pour collecter une métrique
collect_metric() {
    local METRIC_NAME=$1
    local OUTPUT_FILE=$2
    local DISPLAY_NAME=$3

    echo "📥 Collecte: $DISPLAY_NAME..."

    az monitor metrics list \
        --resource "$VM_RESOURCE_ID" \
        --metric "$METRIC_NAME" \
        --start-time "$START_TIME" \
        --end-time "$END_TIME" \
        --interval PT1M \
        --output json > "$OUTPUT_FILE" 2>/dev/null

    if [ $? -eq 0 ]; then
        # Calculer des statistiques basiques
        local VALUES=$(cat "$OUTPUT_FILE" | grep -o '"average": [0-9.]*' | grep -o '[0-9.]*' || echo "")
        if [ ! -z "$VALUES" ]; then
            local COUNT=$(echo "$VALUES" | wc -l)
            echo "   ✅ $COUNT points de données collectés"
        else
            echo "   ⚠️  Aucune donnée disponible"
        fi
    else
        echo "   ❌ Erreur lors de la collecte"
    fi
}

# Collecter CPU
collect_metric "Percentage CPU" \
    "$OUTPUT_DIR/${VM_NAME}-cpu-${TIMESTAMP}.json" \
    "CPU Percentage"

# Collecter Mémoire disponible
collect_metric "Available Memory Bytes" \
    "$OUTPUT_DIR/${VM_NAME}-memory-${TIMESTAMP}.json" \
    "Available Memory"

# Collecter Réseau In
collect_metric "Network In Total" \
    "$OUTPUT_DIR/${VM_NAME}-network-in-${TIMESTAMP}.json" \
    "Network In"

# Collecter Réseau Out
collect_metric "Network Out Total" \
    "$OUTPUT_DIR/${VM_NAME}-network-out-${TIMESTAMP}.json" \
    "Network Out"

# Collecter Disk Read
collect_metric "Disk Read Bytes" \
    "$OUTPUT_DIR/${VM_NAME}-disk-read-${TIMESTAMP}.json" \
    "Disk Read"

# Collecter Disk Write
collect_metric "Disk Write Bytes" \
    "$OUTPUT_DIR/${VM_NAME}-disk-write-${TIMESTAMP}.json" \
    "Disk Write"

echo ""
echo "============================================="
echo "✅ Collecte terminée !"
echo ""
echo "📁 Fichiers créés:"
ls -lh "$OUTPUT_DIR"/*${TIMESTAMP}.json | awk '{print "   " $9 " (" $5 ")"}'
echo ""
echo "📝 Pour analyser les données:"
echo "   cat $OUTPUT_DIR/${VM_NAME}-cpu-${TIMESTAMP}.json | jq '.value[0].timeseries[0].data'"
echo ""
echo "💡 Pour exporter en CSV, utilisez le script Python fourni:"
echo "   python3 scripts/monitoring/export-metrics-csv.py $OUTPUT_DIR/${VM_NAME}-cpu-${TIMESTAMP}.json"
