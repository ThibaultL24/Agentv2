# Agent - Optimization Platform for Boss Fighters

## 📝 Description
Agent is an open-source platform designed to optimize the experience of Boss Fighters players. It provides analytical and management tools, enabling players, streamers, and investors to make informed in-game decisions.

## 🛠️ Technologies
- **Backend**: Ruby on Rails 8.0
- **Database**: PostgreSQL
- **Authentication**: Devise with JWT
- **Payments**: Stripe
- **Emails**: Mailjet

## ✨ Key Features

### 1. Match Management
- Performance tracking
- Rewards analysis
- Badge usage evaluation

### 2. Build Management
- Build creation and optimization
- Performance analysis
- Metric tracking (profit, efficiency)

### 3. Item Management
- Item catalog with metrics
- Farming analysis
- Crafting system
- Recharge management

### 4. Economy
- Currency tracking (Cash, FLEX, $BFT)
- Slot management
- ROI analysis

## 🚀 Installation

### Prerequisites
- Ruby 3.x
- PostgreSQL
- Node.js & Yarn

## Configuration

### 1. Clone the repository

``sh
git clone https://github.com/ThibaultL24/Agentv2
cd agent``

2. Install dependencies

``sh
bundle install``

4. Set up the database

sh
rails db:create

``sh
rails db:migrate``

🧪 Tests
Run the RSpec test suite

``sh
bundle exec rspec``

# Entity Relationship Diagram (ERD)

## Database Schema

### Users 👤
- `id`: bigint, primary key
- `openLootID`: string
- `isPremium`: boolean
- `level`: integer
- `experience`: float
- `assetType`: string
- `asset`: string
- `slotUnlockedId`: integer
- `maxRarity`: string
- `email`: string, unique, default: ""
- `encrypted_password`: string, default: ""
- Timestamps: `created_at`, `updated_at`
- Authentication fields: `reset_password_token`, `reset_password_sent_at`, `remember_created_at`

### Matches 🎮
- `id`: bigint, primary key
- `user_id`: bigint, foreign key
- `build`: string
- `date`: datetime
- `map`: string
- `totalFee`: integer
- `feeCost`: float
- `slots`: integer
- `luckrate`: float
- `time`: integer
- `energyUsed`: integer
- `energyCost`: float
- `totalToken`: integer
- `tokenValue`: float
- `totalPremiumCurrency`: integer
- `premiumCurrencyValue`: float
- `profit`: float
- `bonusMultiplier`: float
- `perksMultiplier`: float
- Timestamps: `created_at`, `updated_at`

### Items 🎁
- `id`: bigint, primary key
- `rarity`: string
- `type`: string
- `name`: string
- `efficiency`: float
- `nfts`: integer
- `supply`: integer
- `floorPrice`: float
- `type_id`: bigint, foreign key
- `rarity_id`: bigint, foreign key
- Timestamps: `created_at`, `updated_at`

### Currencies 💰
- `id`: bigint, primary key
- `name`: string
- `gameName`: string
- `onChain`: boolean
- `price`: float
- `game_id`: bigint, foreign key
- Timestamps: `created_at`, `updated_at`

### Games 🎲
- `id`: bigint, primary key
- `name`: string
- Timestamps: `created_at`, `updated_at`

### Transactions 💳
- `id`: bigint, primary key
- `user_id`: bigint, foreign key
- `payment_method_id`: bigint, foreign key
- `amount`: decimal(18,8)
- `currency`: string
- `status`: string
- `external_id`: string
- `metadata`: jsonb, default: {}
- Timestamps: `created_at`, `updated_at`

### Player Cycles 🔄
- `id`: bigint, primary key
- `user_id`: bigint, foreign key
- `playerCycleType`: integer
- `cycleName`: string
- `nbBadge`: integer
- `minimumBadgeRarity`: string
- `startDate`: datetime
- `endDate`: datetime
- `nbDateRepeat`: integer
- Timestamps: `created_at`, `updated_at`

## Relationships

### User Relationships
- Has many Matches
- Has many Player Cycles
- Has many Transactions
- Has many User Builds
- Has many User Recharges
- Has many User Slots

### Item Relationships
- Belongs to Type
- Belongs to Rarity
- Has many Item Craftings
- Has many Item Farmings
- Has many Item Recharges

### Game Relationships
- Has many Currencies
- Has many Slots

### Currency Relationships
- Belongs to Game
- Has many Currency Packs
- Has many Slots

## Indexes
- `badge_useds_on_match_id`
- `badge_useds_on_nftId`
- `currencies_on_game_id`
- `currency_packs_on_currency_id`
- `items_on_rarity_id`
- `items_on_type_id`
- `jwt_denylist_on_jti`
- `matches_on_user_id`
- `nfts_on_itemId`
- `payment_methods_on_provider`
- `player_cycles_on_user_id`
- `transactions_on_external_id`
- `transactions_on_status`
- `users_on_email`
- `users_on_reset_password_token`

## 🤝 Contribution

1. Fork the project
2. Create a branche for your feature

``sh
git checkout -b feature/AmazingFeature``

5. Commit your changes
``sh
git commit -m 'Add: AmazingFeature'``

6. Push to the branch
``sh
git push origin feature/AmazingFeature``

5. Ouvrir une Pull Request

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















