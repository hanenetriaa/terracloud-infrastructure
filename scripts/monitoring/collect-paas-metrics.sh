#!/bin/bash
# collect-paas-metrics.sh
# Script de collecte des métriques PaaS (App Service)
# Author: Syrine Ladhari
# Version: 1.0

set -e

echo "📊 Collecte des métriques PaaS Azure Monitor"
echo "============================================="
echo ""

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-terracloud-rg}"
APP_NAME="${APP_NAME:-terracloud-paas}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-}"
OUTPUT_DIR="${OUTPUT_DIR:-./metrics/paas}"
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

# Resource ID de l'App Service
APP_RESOURCE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME"

# Timestamp pour les fichiers
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

echo "Configuration:"
echo "  App Service: $APP_NAME"
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
        --resource "$APP_RESOURCE_ID" \
        --metric "$METRIC_NAME" \
        --start-time "$START_TIME" \
        --end-time "$END_TIME" \
        --interval PT1M \
        --output json > "$OUTPUT_FILE" 2>/dev/null

    if [ $? -eq 0 ]; then
        # Calculer des statistiques basiques
        local VALUES=$(cat "$OUTPUT_FILE" | grep -o '"average": [0-9.]*\|"total": [0-9.]*' | grep -o '[0-9.]*' || echo "")
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
collect_metric "CpuPercentage" \
    "$OUTPUT_DIR/${APP_NAME}-cpu-${TIMESTAMP}.json" \
    "CPU Percentage"

# Collecter Mémoire
collect_metric "MemoryWorkingSet" \
    "$OUTPUT_DIR/${APP_NAME}-memory-${TIMESTAMP}.json" \
    "Memory Working Set"

# Collecter Requêtes HTTP
collect_metric "Requests" \
    "$OUTPUT_DIR/${APP_NAME}-requests-${TIMESTAMP}.json" \
    "HTTP Requests"

# Collecter Temps de réponse
collect_metric "AverageResponseTime" \
    "$OUTPUT_DIR/${APP_NAME}-response-time-${TIMESTAMP}.json" \
    "Average Response Time"

# Collecter HTTP 2xx
collect_metric "Http2xx" \
    "$OUTPUT_DIR/${APP_NAME}-http2xx-${TIMESTAMP}.json" \
    "HTTP 2xx Responses"

# Collecter HTTP 4xx
collect_metric "Http4xx" \
    "$OUTPUT_DIR/${APP_NAME}-http4xx-${TIMESTAMP}.json" \
    "HTTP 4xx Errors"

# Collecter HTTP 5xx
collect_metric "Http5xx" \
    "$OUTPUT_DIR/${APP_NAME}-http5xx-${TIMESTAMP}.json" \
    "HTTP 5xx Errors"

# Collecter Bytes reçus
collect_metric "BytesReceived" \
    "$OUTPUT_DIR/${APP_NAME}-bytes-received-${TIMESTAMP}.json" \
    "Bytes Received"

# Collecter Bytes envoyés
collect_metric "BytesSent" \
    "$OUTPUT_DIR/${APP_NAME}-bytes-sent-${TIMESTAMP}.json" \
    "Bytes Sent"

echo ""
echo "============================================="
echo "✅ Collecte terminée !"
echo ""
echo "📁 Fichiers créés:"
ls -lh "$OUTPUT_DIR"/*${TIMESTAMP}.json | awk '{print "   " $9 " (" $5 ")"}'
echo ""
echo "📝 Pour analyser les données:"
echo "   cat $OUTPUT_DIR/${APP_NAME}-cpu-${TIMESTAMP}.json | jq '.value[0].timeseries[0].data'"
echo ""
echo "💡 Pour exporter en CSV, utilisez le script Python fourni:"
echo "   python3 scripts/monitoring/export-metrics-csv.py $OUTPUT_DIR/${APP_NAME}-cpu-${TIMESTAMP}.json"
