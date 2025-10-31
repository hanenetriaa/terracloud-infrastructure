# Guide de Test Rapide - TerraCloud Performance Testing

## ✅ Validation complétée avec succès !

Tous les fichiers de configuration sont corrects et prêts à être utilisés.

---

## 🚀 Comment tester que ça fonctionne

### Option 1 : Test sur un site public (DEMO)

Pour vérifier que tout fonctionne, testons sur un site public :

```bash
cd tests/performance

# Test simple avec Artillery
artillery quick --count 10 --num 5 https://httpbin.org/get
```

### Option 2 : Test avec un de vos scénarios (VERSION MODIFIÉE)

1. **Définir une URL de test temporaire** :
   ```bash
   # Windows (PowerShell)
   $env:IAAS_URL="https://httpbin.org"

   # Windows (CMD)
   set IAAS_URL=https://httpbin.org
   ```

2. **Lancer un scénario de test** :
   ```bash
   artillery run -e iaas scenarios/normal-load.yml
   ```

---

## 📋 Checklist avant les vrais tests

### Étape 1 : Vérifier les prérequis
- [x] Node.js installé (v22.18.0 ✅)
- [x] Artillery installé (v2.0.25 ✅)
- [x] Tous les fichiers de config valides (7/7 ✅)
- [ ] URLs IaaS et PaaS disponibles
- [ ] Accès aux ressources Azure configuré

### Étape 2 : Configuration des URLs

Éditer les fichiers de configuration :

**Pour IaaS** (`configs/iaas-config.yml`) :
```yaml
environments:
  iaas:
    target: "http://your-iaas-loadbalancer.eastus.cloudapp.azure.com"
```

**Pour PaaS** (`configs/paas-config.yml`) :
```yaml
environments:
  paas:
    target: "https://terracloud-paas.azurewebsites.net"
```

### Étape 3 : Test de connectivité

Avant de lancer les tests, vérifier que les URLs sont accessibles :

```bash
# Tester l'URL IaaS
curl http://your-iaas-url.com

# Tester l'URL PaaS
curl https://your-paas-url.com
```

### Étape 4 : Premier test réel

```bash
# Test IaaS - charge normale (10 minutes)
artillery run -e iaas scenarios/normal-load.yml

# Attendre 30 minutes pour stabilisation
timeout /t 1800  # Windows CMD
# OU
Start-Sleep -Seconds 1800  # PowerShell

# Test PaaS - charge normale (10 minutes)
artillery run -e paas scenarios/normal-load.yml
```

---

## 🔧 Scripts NPM disponibles

Le package.json contient des scripts prêts à l'emploi :

```bash
# Vérifier la version d'Artillery
npm run version:check

# Tests IaaS
npm run test:iaas:normal   # Charge normale
npm run test:iaas:stress   # Stress test
npm run test:iaas:spike    # Spike test

# Tests PaaS
npm run test:paas:normal   # Charge normale
npm run test:paas:stress   # Stress test
npm run test:paas:spike    # Spike test
```

---

## 📊 Interpréter les résultats

### Résultat attendu pour un test réussi :

```
Summary report:
  scenarios.launched: 50
  scenarios.completed: 50
  http.codes.200: 200
  http.response_time:
    min: 45
    max: 350
    median: 120
    p95: 280
    p99: 320
```

**Indicateurs de succès** :
- ✅ `scenarios.completed` ≈ `scenarios.launched` (taux de complétion > 95%)
- ✅ `http.codes.200` dominant (> 95% de succès)
- ✅ `p95 < 1000ms` pour charge normale
- ✅ Peu ou pas de codes 5xx

### Résultat problématique :

```
Summary report:
  scenarios.launched: 50
  scenarios.completed: 20
  http.codes.503: 120
  http.response_time:
    p95: 5000
```

**Signaux d'alerte** :
- ❌ Beaucoup de scénarios échoués
- ❌ Codes 5xx fréquents
- ❌ Temps de réponse très élevés
- ❌ Timeouts

---

## 🐛 Dépannage rapide

### Erreur : "ECONNREFUSED"
```
Solution : L'URL n'est pas accessible
- Vérifier que l'application est déployée
- Tester avec curl ou un navigateur
- Vérifier les firewalls
```

### Erreur : "Target not configured"
```
Solution : Variable d'environnement manquante
- Définir IAAS_URL ou PAAS_URL
- Ou éditer directement les fichiers YAML
```

### Taux d'erreur élevé (> 10%)
```
Solution : Système surchargé
- Réduire la charge dans les scénarios
- Augmenter les ressources Azure
- Vérifier les logs applicatifs
```

---

## 📝 Prochaines étapes

1. **Obtenir les URLs** de l'équipe :
   - Eloi Terrol : URL IaaS (Load Balancer)
   - Axel Bacquet : URL PaaS (App Service)

2. **Configurer les variables d'environnement**

3. **Faire un test de smoke** (test rapide de 1 min)

4. **Lancer la suite complète** :
   - Normal load (baseline)
   - Stress test (limites)
   - Spike test (pics)

5. **Analyser et comparer les résultats**

---

## 📚 Ressources

- [Artillery Docs](https://www.artillery.io/docs)
- [Stratégie complète](../../docs/performance-plan/strategy.md)
- [README détaillé](./README.md)
- [Méthodologie de comparaison](../../docs/performance-plan/COMPARISON_METHODOLOGY.md)

---

**Date de création** : 2025-10-31
**Status** : ✅ Prêt pour les tests
**Validé par** : Script de validation automatique
