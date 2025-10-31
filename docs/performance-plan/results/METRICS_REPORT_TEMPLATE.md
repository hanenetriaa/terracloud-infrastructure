# Rapport de Métriques Azure Monitor - [NOM DU TEST]

## Informations du test

| Paramètre | Valeur |
|-----------|--------|
| **Date** | YYYY-MM-DD |
| **Heure début** | HH:MM:SS (UTC+1) |
| **Heure fin** | HH:MM:SS (UTC+1) |
| **Durée totale** | XX minutes |
| **Type de test** | Normal Load / Stress Test / Spike Test |
| **Infrastructure** | IaaS / PaaS |
| **Resource Group** | terracloud-rg |
| **Ressource** | [nom de la VM ou App Service] |
| **ID Test Artillery** | [ID du run Artillery] |

---

## 📊 Métriques CPU

### Statistiques

| Métrique | Valeur | Seuil | Status |
|----------|--------|-------|--------|
| **Moyenne** | ___%| < 70% | ✅ / ⚠️ / ❌ |
| **Maximum** | ___%| < 85% | ✅ / ⚠️ / ❌ |
| **Minimum** | ___%| - | - |
| **P95** | ___%| < 80% | ✅ / ⚠️ / ❌ |

### Observations

```
[Décrire le comportement du CPU pendant le test]
- Pics observés à [HH:MM]
- Stabilité : [Stable / Variable / Instable]
- Tendance : [Croissante / Stable / Décroissante]
```

### Graphique (si disponible)

```
[Insérer capture d'écran ou description du graphique CPU]
```

---

## 💾 Métriques Mémoire

### Statistiques

| Métrique | Valeur IaaS | Valeur PaaS | Unité |
|----------|-------------|-------------|-------|
| **Mémoire disponible moyenne** | ____ MB | - | MB |
| **Working Set moyen** | - | ____ MB | MB |
| **Mémoire max utilisée** | ____ MB | ____ MB | MB |
| **Mémoire min disponible** | ____ MB | - | MB |

### Observations

```
[Décrire le comportement de la mémoire pendant le test]
- Fuites mémoire détectées : [Oui / Non]
- Stabilité : [Stable / Variable / Instable]
- Garbage collection observé : [Oui / Non / N/A]
```

---

## 🌐 Métriques Réseau

### IaaS (Virtual Machine)

| Métrique | Valeur | Unité |
|----------|--------|-------|
| **Network In Total** | ____ MB | MB |
| **Network Out Total** | ____ MB | MB |
| **Débit moyen In** | ____ MB/s | MB/s |
| **Débit moyen Out** | ____ MB/s | MB/s |

### PaaS (App Service)

| Métrique | Valeur | Unité |
|----------|--------|-------|
| **Bytes Received** | ____ MB | MB |
| **Bytes Sent** | ____ MB | MB |
| **Débit moyen In** | ____ MB/s | MB/s |
| **Débit moyen Out** | ____ MB/s | MB/s |

### Observations

```
[Décrire le comportement réseau pendant le test]
- Saturation réseau : [Oui / Non]
- Latence observée : [Basse / Moyenne / Élevée]
```

---

## 💿 Métriques Disque (IaaS uniquement)

| Métrique | Valeur | Unité |
|----------|--------|-------|
| **Disk Read Bytes Total** | ____ MB | MB |
| **Disk Write Bytes Total** | ____ MB | MB |
| **IOPS Read moyen** | ____ | ops/s |
| **IOPS Write moyen** | ____ | ops/s |

### Observations

```
[Décrire le comportement du disque pendant le test]
- Goulot d'étranglement I/O : [Oui / Non]
- Latence disque : [Basse / Moyenne / Élevée]
```

---

## 🌍 Métriques HTTP (PaaS uniquement)

### Requêtes HTTP

| Métrique | Valeur | Seuil | Status |
|----------|--------|-------|--------|
| **Total requêtes** | ____ | - | - |
| **Requêtes/sec moyen** | ____ | - | - |
| **HTTP 2xx** | ____ | > 95% | ✅ / ⚠️ / ❌ |
| **HTTP 4xx** | ____ | < 2% | ✅ / ⚠️ / ❌ |
| **HTTP 5xx** | ____ | < 1% | ✅ / ⚠️ / ❌ |
| **Taux d'erreur** | ___% | < 1% | ✅ / ⚠️ / ❌ |

### Temps de réponse

| Métrique | Valeur | Seuil | Status |
|----------|--------|-------|--------|
| **Moyenne** | ____ ms | < 500ms | ✅ / ⚠️ / ❌ |
| **Maximum** | ____ ms | < 2000ms | ✅ / ⚠️ / ❌ |
| **Minimum** | ____ ms | - | - |

### Observations

```
[Décrire le comportement des requêtes HTTP]
- Pattern des erreurs : [Sporadique / Concentré / Continu]
- Corrélation avec la charge : [Oui / Non]
```

---

## 📈 Corrélation avec Artillery

### Métriques Artillery (rappel)

| Métrique Artillery | Valeur |
|-------------------|--------|
| **Scénarios lancés** | ____ |
| **Scénarios complétés** | ____ |
| **Taux de succès** | ___% |
| **Requêtes/sec moyen** | ____ |
| **Temps réponse p95** | ____ ms |
| **Temps réponse p99** | ____ ms |

### Analyse croisée

| Observation | Détails |
|-------------|---------|
| **Cohérence Artillery vs Azure** | [Les métriques sont cohérentes / Écarts observés] |
| **Corrélation charge-CPU** | [Forte / Moyenne / Faible] |
| **Corrélation charge-mémoire** | [Forte / Moyenne / Faible] |
| **Goulots d'étranglement identifiés** | [CPU / Mémoire / Réseau / Disque / Aucun] |

---

## 🔍 Événements notables

### Timeline

| Heure | Événement | Impact | Métriques affectées |
|-------|-----------|--------|---------------------|
| HH:MM | [Description] | [Élevé / Moyen / Faible] | [CPU / Mémoire / etc.] |
| HH:MM | [Description] | [Élevé / Moyen / Faible] | [CPU / Mémoire / etc.] |

### Pics de charge

```
[Décrire les pics observés]
- Pic 1 : [HH:MM] - CPU: __%, Cause: [...]
- Pic 2 : [HH:MM] - Mémoire: __MB, Cause: [...]
```

### Anomalies

```
[Lister toute anomalie observée]
- Anomalie 1: [Description et impact]
- Anomalie 2: [Description et impact]
```

---

## 💰 Métriques de coût (estimation)

| Période | Durée | Coût estimé | Détails |
|---------|-------|-------------|---------|
| **Test** | XX minutes | $X.XX | [VM size / App Service tier] |
| **Monitoring** | XX minutes | $0.0X | Azure Monitor |
| **Total** | XX minutes | $X.XX | - |

### Coût par requête

```
Total requêtes : ____
Coût total : $____
Coût par 1000 requêtes : $____
```

---

## ✅ Critères de succès

| Critère | Seuil | Résultat | Status |
|---------|-------|----------|--------|
| CPU moyen | < 70% | ___% | ✅ / ❌ |
| CPU max | < 85% | ___% | ✅ / ❌ |
| Mémoire stable | Oui | [Oui / Non] | ✅ / ❌ |
| Taux d'erreur | < 1% | ___% | ✅ / ❌ |
| Temps réponse p95 | < 1000ms | ___ ms | ✅ / ❌ |
| Disponibilité | > 99% | ___% | ✅ / ❌ |

**Résultat global** : ✅ SUCCÈS / ⚠️ PARTIEL / ❌ ÉCHEC

---

## 📝 Observations et recommandations

### Points forts

```
1. [Point fort 1]
2. [Point fort 2]
3. [Point fort 3]
```

### Points d'amélioration

```
1. [Point à améliorer 1] - Recommandation: [...]
2. [Point à améliorer 2] - Recommandation: [...]
3. [Point à améliorer 3] - Recommandation: [...]
```

### Recommandations de scaling

```
[Recommandations pour améliorer les performances]
- Scaling vertical : [Augmenter / Maintenir / Diminuer] la taille
- Scaling horizontal : [Ajouter / Maintenir / Retirer] des instances
- Configuration : [Ajustements suggérés]
```

---

## 📎 Annexes

### Fichiers de données

| Type | Fichier | Taille | Chemin |
|------|---------|--------|--------|
| CPU | [nom-fichier].json | XX KB | metrics/iaas/... |
| Mémoire | [nom-fichier].json | XX KB | metrics/iaas/... |
| Réseau | [nom-fichier].json | XX KB | metrics/iaas/... |
| Artillery | [nom-fichier].json | XX KB | results/... |

### Captures d'écran

```
1. [Description capture 1] - Voir: screenshots/...
2. [Description capture 2] - Voir: screenshots/...
```

### Commandes utilisées

```powershell
# Collecte des métriques
.\Collect-Metrics.ps1 -Type IaaS -DurationMinutes 15

# Analyse
Get-Content metrics\iaas\*-cpu-*.json | ConvertFrom-Json
```

---

## 🔄 Prochaines étapes

- [ ] Comparer avec les résultats PaaS (si applicable)
- [ ] Intégrer au rapport de comparaison global
- [ ] Partager les résultats avec l'équipe
- [ ] Planifier les optimisations identifiées
- [ ] Archiver les données de test

---

**Rapport généré par** : [Votre nom]
**Date de génération** : YYYY-MM-DD
**Version** : 1.0
**Status** : ✅ Finalisé / 🚧 En cours / 📝 Brouillon
