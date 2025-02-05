puts "- Création des slots de BADGEs"

game = Game.find_by!(name: "Boss Fighters")
gold = Currency.find_by!(name: "Gold")
gems = Currency.find_by!(name: "Gems")

# Définition des slots avec leurs caractéristiques
slots = [
  # Slot de base gratuit (toujours débloqué)
  {
    currency: gold,
    game: game,
    unlockCurrencyNumber: 0,
    unlockPrice: 0,
    unlocked: true,
    totalCost: 0
  },
  # Slots Gold (accessibles avec la monnaie de base)
  {
    currency: gold,
    game: game,
    unlockCurrencyNumber: 1000,
    unlockPrice: 9.99,
    unlocked: false,
    totalCost: 9.99
  },
  {
    currency: gold,
    game: game,
    unlockCurrencyNumber: 2500,
    unlockPrice: 24.99,
    unlocked: false,
    totalCost: 24.99
  },
  # Slots Premium (nécessitent des Gems)
  {
    currency: gems,
    game: game,
    unlockCurrencyNumber: 100,
    unlockPrice: 99.99,
    unlocked: false,
    totalCost: 99.99
  },
  {
    currency: gems,
    game: game,
    unlockCurrencyNumber: 250,
    unlockPrice: 249.99,
    unlocked: false,
    totalCost: 249.99
  }
]

puts "  - Création de #{slots.length} slots (1 gratuit, 2 Gold, 2 Premium)"

# Création des slots
slots.each do |slot_data|
  Slot.create!(slot_data)
end
