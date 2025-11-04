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

---

**Responsable:** Syrine Ladhari  
**Dernière mise à jour:** Novembre 2025
