puts "- Création des slots de BADGEs"

game = Game.find_by!(name: "Boss Fighters")
cash = Currency.find_by!(name: "CASH")
flex = Currency.find_by!(name: "FLEX")

# Définition des slots avec leurs caractéristiques
slots = [
  # Slot de base gratuit (toujours débloqué)
  {
    currency: cash,
    game: game,
    unlockCurrencyNumber: 0,
    unlockPrice: 0,
    unlocked: true,
    totalCost: 0
  },
  # Slots standards (accessibles avec CASH)
  {
    currency: cash,
    game: game,
    unlockCurrencyNumber: 5_000,
    unlockPrice: 4.99,
    unlocked: false,
    totalCost: 4.99
  },
  {
    currency: cash,
    game: game,
    unlockCurrencyNumber: 15_000,
    unlockPrice: 12.99,
    unlocked: false,
    totalCost: 12.99
  },
  # Slots Premium (nécessitent du FLEX)
  {
    currency: flex,
    game: game,
    unlockCurrencyNumber: 500,
    unlockPrice: 4.99,
    unlocked: false,
    totalCost: 4.99
  },
  {
    currency: flex,
    game: game,
    unlockCurrencyNumber: 1_500,
    unlockPrice: 12.99,
    unlocked: false,
    totalCost: 12.99
  }
]

puts "  - Création de #{slots.length} slots (1 gratuit, 2 standards, 2 premium)"

# Création des slots
slots.each do |slot_data|
  Slot.create!(slot_data)
end

puts "✓ Slots créés avec succès"
