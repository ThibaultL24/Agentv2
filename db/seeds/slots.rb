puts "- Création des slots de BADGEs"

game = Game.find_by!(name: "Boss Fighters")
flex = Currency.find_by!(name: "FLEX")

# Définition des slots avec leurs caractéristiques
slots = [
  # Slot de base gratuit (toujours débloqué)
  {
    currency: flex,
    game: game,
    unlocked: true,
    unlockCurrencyNumber: 0,
    unlockPrice: 0
  },
  # Premier slot payant
  {
    currency: flex,
    game: game,
    unlocked: false,
    unlockCurrencyNumber: 7_000,
    unlockPrice: 51.98
  },
  # Deuxième slot
  {
    currency: flex,
    game: game,
    unlocked: false,
    unlockCurrencyNumber: 20_000,
    unlockPrice: 148.52
  },
  # Troisième slot
  {
    currency: flex,
    game: game,
    unlocked: false,
    unlockCurrencyNumber: 40_000,
    unlockPrice: 297.04
  },
  # Quatrième slot
  {
    currency: flex,
    game: game,
    unlocked: false,
    unlockCurrencyNumber: 66_000,
    unlockPrice: 490.11
  }
]

puts "  - Création de #{slots.length} slots (1 gratuit, 4 payants)"

# Création des slots
slots.each do |slot_data|
  Slot.create!(slot_data)
end

puts "✓ Slots créés avec succès"
