markdown# 📚 Guide de Démarrage - Projet TerraCloud
Date : 12/09/2025
Par : Hanene Triaa

## 🚀 Démarrage Rapide

### 1. Cloner le repository
```bash
git clone https://github.com/hanenetriaa/terracloud-infrastructure.git
cd terracloud-infrastructure
2. Accès aux ressources

Azure Portal : https://portal.azure.com
Resource Group : rg-nce_4
Jira : https://projetcia.atlassian.net/jira/software/projects/TER/boards

📋 Répartition des Tâches (Semaine 1)
✅ Complétées (Hanene)

[TER-XX] Configuration Azure Resource Group
[TER-XX] Repository GitHub avec structure

🔄 À faire cette semaine
Eloi Terrol - Infrastructure Terraform
Tâche : Installation Terraform et Backend
bash# Dans terraform/backend/
# Créer main.tf avec la config backend fournie
# Initialiser : terraform init
Fichiers à créer :

terraform/versions.tf
terraform/variables.tf
terraform/outputs.tf
terraform/environments/dev/terraform.tfvars

Axel Bacquet - Docker
Tâche : Dockerfile Application

Télécharger l'app depuis le lien EPITECH
Analyser les dépendances
Créer docker/app/Dockerfile multi-stage
Créer docker-compose.yml
Tester le build localement

Syrine Ladhari - Tests & Documentation
Tâche : Plan de Tests

Créer docs/TEST_STRATEGY.md
Installer JMeter et K6
Créer scripts de base dans tests/performance/
Définir métriques de comparaison IaaS vs PaaS

🔑 Configuration Backend Terraform
hclterraform {
  backend "azurerm" {
    resource_group_name  = "rg-nce_4"
    storage_account_name = "tfstatencea2024"
    container_name      = "tfstate"
    key                 = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
📁 Structure du Projet
terracloud-infrastructure/
├── terraform/
│   ├── modules/        # Eloi : créer modules VM et WebApp
│   ├── environments/   # Config par environnement
│   └── backend/        # Config backend (fait)
├── ansible/
│   ├── playbooks/      # Axel : playbooks semaine 2
│   └── roles/          # Roles Ansible
├── docker/
│   └── app/           # Axel : Dockerfile cette semaine
├── docs/
│   └── TEST_STRATEGY.md # Syrine : plan de tests
└── tests/
    └── performance/    # Syrine : scripts JMeter/K6
📅 Planning Semaine 1
JourTâcheResponsableStatusLunSetup Azure + GitHubHanene✅MarTerraform init + backendEloi🔄MerDockerfile créationAxel🔄JeuPlan tests + JMeterSyrine🔄VenReview + mergeTous📅
🔐 Secrets et Accès
⚠️ NE JAMAIS COMMIT LES SECRETS
Créez .env.local (non versionné) :
envARM_SUBSCRIPTION_ID=xxx
ARM_TENANT_ID=xxx
ARM_CLIENT_ID=xxx
ARM_CLIENT_SECRET=xxx
STORAGE_ACCOUNT_KEY=xxx  # Demander à Hanene
📝 Workflow Git
bash# Créer une branche pour votre tâche
git checkout -b feature/nom-tache

# Travailler et commit
git add .
git commit -m "[TER-XX] Description"

# Push et créer Pull Request
git push origin feature/nom-tache
🏃 Daily Standup
Chaque jour à 9h sur Discord/Teams :

Qu'est-ce que j'ai fait hier ?
Qu'est-ce que je fais aujourd'hui ?
Y a-t-il des blocages ?

📊 Critères de Validation Semaine 1

 Terraform peut initialiser avec le backend Azure
 Dockerfile build sans erreur
 Plan de tests documenté
 Structure de projet complète
 Tous les fichiers de base créés

🆘 Support

Hanene : Azure, GitHub, Coordination
Canal Discord : [Créer un canal équipe]
Documentation Azure : https://docs.microsoft.com/azure

🎯 Objectif Fin de Semaine
Avoir une base solide pour commencer le déploiement IaaS/PaaS en semaine 2.

💡 Rappel : Éteignez les ressources Azure chaque soir pour économiser !