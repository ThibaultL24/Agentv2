puts "\nCréation des items..."

# Définition des items avec leurs caractéristiques
items = [
  # Badges
  {
    name: "Rookie Badge",
    type_name: "Badge",
    rarity_name: "Common",
    efficiency: 1.0,
    supply: 200_000,
    floorPrice: 7.98,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Initiate Badge",
    type_name: "Badge",
    rarity_name: "Uncommon",
    efficiency: 2.05,
    supply: 100_000,
    floorPrice: 34.00,
    farming: { ratio: 2.05, in_game_time: 600 }
  },
  {
    name: "Encore Badge",
    type_name: "Badge",
    rarity_name: "Rare",
    efficiency: 4.20,
    supply: 50_000,
    floorPrice: 95.00,
    farming: { ratio: 2.15, in_game_time: 600 }
  },
  {
    name: "Contender Badge",
    type_name: "Badge",
    rarity_name: "Epic",
    efficiency: 12.92,
    supply: 25_000,
    floorPrice: 409.00,
    farming: { ratio: 8.72, in_game_time: 600 }
  },
  {
    name: "Challenger Badge",
    type_name: "Badge",
    rarity_name: "Legendary",
    efficiency: 39.74,
    supply: 10_000,
    floorPrice: 2_900.00,
    farming: { ratio: 26.82, in_game_time: 600 }
  },

  # Contracts
  {
    name: "Rookie Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Common",
    efficiency: 1.0,
    supply: 50_000,
    floorPrice: 23.00,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Initiate Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Uncommon",
    efficiency: 2.05,
    supply: 35_000,
    floorPrice: 40.99,
    farming: { ratio: 2.05, in_game_time: 600 }
  },
  {
    name: "Encore Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Rare",
    efficiency: 4.20,
    supply: 20_000,
    floorPrice: 91.90,
    farming: { ratio: 2.15, in_game_time: 600 }
  },
  {
    name: "Contender Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Epic",
    efficiency: 12.92,
    supply: 10_000,
    floorPrice: 295.00,
    farming: { ratio: 8.72, in_game_time: 600 }
  },
  {
    name: "Champion Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Exalted",
    efficiency: 39.74,
    supply: 1_000,
    floorPrice: 100_000.00,
    farming: { ratio: 26.82, in_game_time: 600 }
  },
  {
    name: "Challenger Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Legendary",
    efficiency: 39.74,
    supply: 5_000,
    floorPrice: 398.00,
    farming: { ratio: 26.82, in_game_time: 600 }
  }
]

# Création des items
items.each do |item_data|
  puts "- Création de l'item: #{item_data[:name]} (#{item_data[:type_name]} - #{item_data[:rarity_name]})"

  item = Item.find_or_create_by!(name: item_data[:name]) do |i|
    i.type = Type.find_by!(name: item_data[:type_name])
    i.rarity = Rarity.find_by!(name: item_data[:rarity_name])
    i.efficiency = item_data[:efficiency]
    i.supply = item_data[:supply]
    i.floorPrice = item_data[:floorPrice]
  end

  # Création des données de farming
  if item_data[:farming]
    ItemFarming.find_or_create_by!(item: item) do |farming|
      farming.ratio = item_data[:farming][:ratio]
      farming.efficiency = item.efficiency
      farming.in_game_time = item_data[:farming][:in_game_time]
    end
  end
end

puts "✓ Items créés avec succès"
