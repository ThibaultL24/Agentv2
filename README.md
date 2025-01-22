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

git clone [(https://github.com/ThibaultL24/Agentv2)]

cd agent

### 2. Install dependencies

bundle install

### 3. Set up the database

rails db:create

rails db:migrate

## 🧪 Tests

### Run the RSpec test suite

bundle exec rspec

## 📊 Database Structure

### Main Tables
- **Users**: User authentication and profiles
- **Matches**: Match history
- **Items**: Item management and inventory
- **Currencies**: Management of various currencies
- **Transactions**: Payment tracking
- **PlayerCycles**: Gameplay cycle management

## 🤝 Contribution

### 1. Fork the project

### 2. Create a branch for your feature

git checkout -b feature/AmazingFeature

### 3. Commit your changes

git commit -m 'Add: AmazingFeature'

### 4. Push to the branch

git push origin feature/AmazingFeature

## 📝 Testing and Code Quality

- Unit and integration testing with RSpec
- Security analysis with Brakeman
- Code styling with RuboCop Rails Omakase

## 🔧 Development Tools

- **Debugging**: `debug` gem
- **Testing**: RSpec, FactoryBot, Faker
- **Security**: Brakeman
- **Style**: RuboCop Rails Omakase

## 📦 Deployment

Deployment is handled via Kamal with Docker support.

## 📫 Contact

[To be defined]

## 📄 License

[To be defined]

---

<p align="center">
  Made with ❤️ for the Boss Fighters community
</p>
