#!/bin/bash
# validate-azure-monitor.sh
# Script de validation de la configuration Azure Monitor
# Author: Syrine Ladhari
# Version: 1.0

set -e

echo "🔍 Validation de la configuration Azure Monitor pour TerraCloud"
echo "================================================================"
echo ""

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration (à personnaliser)
RESOURCE_GROUP="${RESOURCE_GROUP:-terracloud-rg}"
VM_NAME="${VM_NAME:-terracloud-vm-01}"
APP_NAME="${APP_NAME:-terracloud-paas}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-}"

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0

# Fonction pour afficher le résultat
check_result() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ $1${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Test 1: Vérifier Azure CLI
echo "📋 Test 1: Vérification Azure CLI"
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
    echo "   Version Azure CLI: $AZ_VERSION"
    check_result "Azure CLI installé"
else
    check_result "Azure CLI installé"
fi

# Test 2: Vérifier la connexion Azure
echo ""
echo "📋 Test 2: Vérification connexion Azure"
if az account show &>/dev/null; then
    ACCOUNT_NAME=$(az account show --query name -o tsv)
    echo "   Compte: $ACCOUNT_NAME"
    check_result "Connecté à Azure"

    # Obtenir le Subscription ID si non fourni
    if [ -z "$SUBSCRIPTION_ID" ]; then
        SUBSCRIPTION_ID=$(az account show --query id -o tsv)
        echo "   Subscription ID: $SUBSCRIPTION_ID"
    fi
else
    check_result "Connecté à Azure"
    echo "   💡 Exécutez: az login"
    exit 1
fi

# Test 3: Vérifier le Resource Group
echo ""
echo "📋 Test 3: Vérification Resource Group"
if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
    RG_LOCATION=$(az group show --name "$RESOURCE_GROUP" --query location -o tsv)
    echo "   Location: $RG_LOCATION"
    check_result "Resource Group '$RESOURCE_GROUP' existe"
else
    check_result "Resource Group '$RESOURCE_GROUP' existe"
    warning "Resource Group non trouvé. Vérifiez le nom: $RESOURCE_GROUP"
fi

# Test 4: Vérifier la VM IaaS
echo ""
echo "📋 Test 4: Vérification VM IaaS"
if az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" &>/dev/null; then
    VM_STATUS=$(az vm get-instance-view --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" -o tsv)
    echo "   Status: $VM_STATUS"
    check_result "VM '$VM_NAME' trouvée"
else
    check_result "VM '$VM_NAME' trouvée"
    warning "VM non trouvée. Vérifiez le nom: $VM_NAME"
fi

# Test 5: Vérifier l'App Service PaaS
echo ""
echo "📋 Test 5: Vérification App Service PaaS"
if az webapp show --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" &>/dev/null; then
    APP_STATE=$(az webapp show --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" --query state -o tsv)
    APP_URL=$(az webapp show --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" --query defaultHostName -o tsv)
    echo "   Status: $APP_STATE"
    echo "   URL: https://$APP_URL"
    check_result "App Service '$APP_NAME' trouvée"
else
    check_result "App Service '$APP_NAME' trouvée"
    warning "App Service non trouvée. Vérifiez le nom: $APP_NAME"
fi

# Test 6: Vérifier l'accès aux métriques VM
echo ""
echo "📋 Test 6: Vérification accès métriques VM"
if [ $TESTS_FAILED -eq 0 ]; then
    VM_RESOURCE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME"

    END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    START_TIME=$(date -u -d '5 minutes ago' +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-5M +"%Y-%m-%dT%H:%M:%SZ")

    if az monitor metrics list \
        --resource "$VM_RESOURCE_ID" \
        --metric "Percentage CPU" \
        --start-time "$START_TIME" \
        --end-time "$END_TIME" \
        --interval PT1M &>/dev/null; then
        check_result "Accès aux métriques VM OK"
    else
        check_result "Accès aux métriques VM OK"
        warning "Impossible d'accéder aux métriques. Vérifiez les permissions."
    fi
else
    warning "Test sauté (dépendances échouées)"
fi

# Test 7: Vérifier l'accès aux métriques App Service
echo ""
echo "📋 Test 7: Vérification accès métriques App Service"
if [ $TESTS_FAILED -eq 0 ]; then
    APP_RESOURCE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME"

    if az monitor metrics list \
        --resource "$APP_RESOURCE_ID" \
        --metric "CpuPercentage" \
        --start-time "$START_TIME" \
        --end-time "$END_TIME" \
        --interval PT1M &>/dev/null; then
        check_result "Accès aux métriques App Service OK"
    else
        check_result "Accès aux métriques App Service OK"
        warning "Impossible d'accéder aux métriques. Vérifiez les permissions."
    fi
else
    warning "Test sauté (dépendances échouées)"
fi

# Test 8: Vérifier Log Analytics Workspace (optionnel)
echo ""
echo "📋 Test 8: Vérification Log Analytics (optionnel)"
WORKSPACES=$(az monitor log-analytics workspace list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv 2>/dev/null)
if [ ! -z "$WORKSPACES" ]; then
    echo "   Workspaces trouvés: $WORKSPACES"
    check_result "Log Analytics Workspace trouvé"
else
    warning "Aucun Log Analytics Workspace trouvé (optionnel)"
fi

# Test 9: Vérifier Application Insights (optionnel)
echo ""
echo "📋 Test 9: Vérification Application Insights (optionnel)"
APPINSIGHTS=$(az monitor app-insights component list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv 2>/dev/null)
if [ ! -z "$APPINSIGHTS" ]; then
    echo "   Application Insights: $APPINSIGHTS"
    check_result "Application Insights trouvé"
else
    warning "Aucun Application Insights trouvé (recommandé pour PaaS)"
fi

# Résumé
echo ""
echo "================================================================"
echo "📊 RÉSUMÉ DE LA VALIDATION"
echo "================================================================"
echo -e "Tests réussis: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests échoués: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Validation réussie ! Vous êtes prêt pour les tests de performance.${NC}"
    echo ""
    echo "📝 Prochaines étapes:"
    echo "   1. Configurer les variables d'environnement dans votre shell"
    echo "   2. Lancer un test Artillery: artillery run -e iaas scenarios/normal-load.yml"
    echo "   3. Surveiller Azure Monitor pendant le test"
    echo "   4. Collecter les métriques après le test"
    exit 0
else
    echo -e "${RED}❌ Validation échouée. Corrigez les erreurs ci-dessus.${NC}"
    echo ""
    echo "💡 Actions recommandées:"
    echo "   - Vérifiez les noms de ressources (RESOURCE_GROUP, VM_NAME, APP_NAME)"
    echo "   - Vérifiez vos permissions Azure (Monitoring Contributor requis)"
    echo "   - Contactez l'équipe pour les informations manquantes"
    exit 1
fi
