# Agent - Plateforme d'Optimisation pour Boss Fighters

## 📝 Description
Agent est une plateforme open source conçue pour optimiser l'expérience des joueurs de Boss Fighters. Elle fournit des outils d'analyse et de gestion permettant aux joueurs, streamers et investisseurs de prendre des décisions éclairées dans le jeu.

## 🛠️ Technologies
- **Backend**: Ruby on Rails 8.0
- **Base de données**: PostgreSQL
- **Authentification**: Devise avec JWT
- **Paiements**: Stripe
- **Emails**: Mailjet

## ✨ Fonctionnalités Principales

### 1. Gestion des Matches
- Suivi des performances
- Analyse des récompenses
- Évaluation de l'utilisation des badges

### 2. Gestion des Builds
- Création et optimisation de builds
- Analyse des performances
- Suivi des métriques (profit, efficacité)

### 3. Gestion des Items
- Catalogue d'items avec métriques
- Analyse du farming
- Système de crafting
- Gestion des recharges

### 4. Économie
- Suivi des devises (Cash, FLEX, $BFT)
- Gestion des slots
- Analyse ROI

## 🚀 Installation

### Prérequis
- Ruby 3.x
- PostgreSQL
- Node.js & Yarn

### Configuration

# 1.  Cloner le repository

git clone [(https://github.com/ThibaultL24/Agentv2)]

cd agent

# 4.  Installer les dépendances

bundle install

# 5. Configurer la base de données

rails db:create

rails db:migrate

## 🧪 Tests

# Lancer la suite de tests RSpec

bundle exec rspec


## 📊 Structure de la Base de Données

### Tables Principales
- **Users**: Authentification et profils utilisateurs
- **Matches**: Historique des parties
- **Items**: Gestion des items et inventaire
- **Currencies**: Gestion des différentes devises
- **Transactions**: Suivi des paiements
- **PlayerCycles**: Gestion des cycles de jeu

## 🤝 Contribution

# 1. Fork le projet

# 2. Créer une branche pour votre fonctionnalité

git checkout -b feature/AmazingFeature

# 3. Commit vos changements

git commit -m 'Add: AmazingFeature'

# 4. Push vers la branche

git push origin feature/AmazingFeature


## 📝 Tests et Qualité du Code

- Tests unitaires et d'intégration avec RSpec
- Analyse de sécurité avec Brakeman
- Style de code avec RuboCop Rails Omakase

## 🔧 Outils de Développement

- **Debugging**: `debug` gem
- **Tests**: RSpec, FactoryBot, Faker
- **Sécurité**: Brakeman
- **Style**: RuboCop Rails Omakase

## 📦 Déploiement

Le déploiement est géré via Kamal avec support Docker.

## 📫 Contact

[À définir]

## 📄 License

[À définir]

---

<p align="center">
  Fait avec ❤️ pour la communauté Boss Fighters
</p>
