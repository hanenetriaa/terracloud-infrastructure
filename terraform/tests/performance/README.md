# TerraCloud Performance Tests

Tests de performance Artillery pour comparer IaaS vs PaaS sur Azure.

## 📁 Structure

```
performance/
├── scenarios/           # Scénarios de test
│   ├── normal-load.yml # Test de charge normale
│   ├── stress.yml      # Test de stress
│   └── spike.yml       # Test de pic
├── config/             # Configurations infrastructure
│   ├── iaas-config.yml # Config IaaS (Azure VM)
│   └── paas-config.yml # Config PaaS (App Service)
├── configs/            # Données de test
│   └── test-data.csv   # Données utilisateurs
├── processors/         # Fonctions personnalisées
│   └── custom-functions.js
└── reports/            # Rapports de tests (générés)
```

## 🚀 Installation

```bash
# Installer Artillery
npm install -g artillery@latest

# Vérifier l'installation
artillery version
```

## 🧪 Exécution des Tests

### Variables d'Environnement

```bash
# Définir les URLs
export IAAS_URL="http://[VM-IP-ADDRESS]"
export PAAS_URL="https://[APP-NAME].azurewebsites.net"
```

### Tests IaaS

```bash
cd terraform/tests/performance

# Test de charge normale
artillery run -e iaas scenarios/normal-load.yml

# Test de stress
artillery run -e iaas scenarios/stress.yml --output reports/iaas-stress.json

# Test de pic
artillery run -e iaas scenarios/spike.yml --output reports/iaas-spike.json
```

### Tests PaaS

```bash
# Test de charge normale
artillery run -e paas scenarios/normal-load.yml

# Test de stress
artillery run -e paas scenarios/stress.yml --output reports/paas-stress.json

# Test de pic
artillery run -e paas scenarios/spike.yml --output reports/paas-spike.json
```

### Génération de Rapports HTML

```bash
artillery report reports/iaas-stress.json
# Génère: reports/iaas-stress.json.html
```

## 📊 Scénarios de Test

### 1. Normal Load (Charge Normale)
- **Durée:** 10 minutes
- **Charge:** 2 → 10 utilisateurs/s
- **Objectif:** Performance de référence

### 2. Stress Test
- **Durée:** 15 minutes
- **Charge:** 5 → 50 utilisateurs/s
- **Objectif:** Identifier les limites

### 3. Spike Test
- **Durée:** 13 minutes
- **Charge:** 5 → 100 → 5 → 150 → 5
- **Objectif:** Tester la résilience

## 📈 Métriques Collectées

- Response Time (p50, p95, p99)
- Throughput (requests/sec)
- Error Rate
- Success Rate
- Status codes distribution

## 📝 Documentation

Voir `docs/TEST_STRATEGY.md` pour la stratégie complète.

## ✅ Checklist Avant Tests

- [ ] URLs IaaS et PaaS configurées
- [ ] Ressources Azure démarrées
- [ ] Artillery installé
- [ ] Monitoring Azure activé
- [ ] Équipe notifiée

## 🔧 Démarrage de l'Infrastructure

### PaaS (Azure App Service)

Avant de lancer les tests, **démarrez votre App Service** :

```bash
# Via Azure CLI
az webapp start --name terracloud-dev-wa --resource-group rg-nce_4

# Vérifier l'état
az webapp show --name terracloud-dev-wa --resource-group rg-nce_4 --query state
```

Via Azure Portal :
1. Accédez à https://portal.azure.com
2. Recherchez "terracloud-dev-wa"
3. Cliquez sur "Start" si le service est arrêté

**Test rapide de disponibilité :**
```bash
curl -I https://terracloud-dev-wa.azurewebsites.net
```

### IaaS (Machine Virtuelle)

⚠️ **L'infrastructure IaaS n'est pas encore créée.**

Pour la créer, il faudra :
1. Créer un fichier Terraform pour la VM (vm.tf)
2. Configurer le réseau (IP publique, NSG)
3. Installer et configurer le serveur web
4. Déployer l'application

## 🐛 Troubleshooting

### Erreur "Invalid URL - undefined"
**Cause :** Variable d'environnement non définie.
```bash
# Solution : définir la variable avant la commande
PAAS_URL="https://terracloud-dev-wa.azurewebsites.net" artillery run -e paas scenarios/normal-load.yml
```

### Erreur "ENOENT: no such file or directory"
**Cause :** Chemin incorrect.
```bash
# Solution : utilisez le chemin complet
cd terraform/tests/performance
artillery run -e paas scenarios/normal-load.yml
```

### Tous les tests échouent avec HTTP 403
**Cause :** App Service arrêté ou non configuré.
```bash
# Solution : démarrez l'App Service
az webapp start --name terracloud-dev-wa --resource-group rg-nce_4
```

### Erreurs ECONNRESET
**Cause :** Le service ne peut pas gérer la charge.
**Solutions :**
- Augmenter le SKU de l'App Service (B1 → B2 ou S1)
- Réduire l'arrivalRate dans les scénarios de test
- Vérifier les logs de l'application

### Test rapide de disponibilité

Utilisez le scénario `availability-check.yml` pour vérifier rapidement si le service répond :

```bash
PAAS_URL="https://terracloud-dev-wa.azurewebsites.net" artillery run -e paas scenarios/availability-check.yml
```

Ce test est plus court (~30s) et ne teste que la disponibilité basique.

## 📝 Notes importantes

- Les scénarios de test sont actuellement configurés pour tester uniquement la page d'accueil (`/`)
- Les endpoints API commentés dans les fichiers YAML peuvent être activés une fois l'application déployée
- Assurez-vous que l'application Laravel est correctement configurée avant les tests complets

---

**Responsable:** Syrine Ladhari
**Dernière mise à jour:** Novembre 2025
