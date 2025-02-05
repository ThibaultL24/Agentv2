puts "- Création des currencies"

game = Game.find_by!(name: "Boss Fighters")

# Définition des currencies
currencies = [
  {
    name: "Gold",
    onChain: false,
    price: 1.0,
    game: game
  },
  {
    name: "Gems",
    onChain: true,
    price: 10.0,
    game: game
  }
]

# Création des currencies
currencies.each do |currency_data|
  Currency.find_or_create_by!(name: currency_data[:name]) do |c|
    c.onChain = currency_data[:onChain]
    c.price = currency_data[:price]
    c.game = currency_data[:game]
  end
end

puts "✓ Currencies créées avec succès"
