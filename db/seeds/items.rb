puts "\nCréation des items..."

# Définition des items avec leurs caractéristiques
items = [
  # Badges
  {
    name: "Rookie Badge",
    type_name: "Badge",
    rarity_name: "Common",
    efficiency: 0.1,
    supply: 200_000,
    floorPrice: 7.98,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Initiate Badge",
    type_name: "Badge",
    rarity_name: "Uncommon",
    efficiency: 0.205,
    supply: 100_000,
    floorPrice: 26.00,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Encore Badge",
    type_name: "Badge",
    rarity_name: "Rare",
    efficiency: 0.5,
    supply: 50_000,
    floorPrice: 119.00,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Contender Badge",
    type_name: "Badge",
    rarity_name: "Epic",
    efficiency: 1.292,
    supply: 25_000,
    floorPrice: 404.00,
    farming: { ratio: 1.0, in_game_time: 600 }
  },

  # Contracts
  {
    name: "Rookie Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Common",
    efficiency: 0.1,
    supply: 50_000,
    floorPrice: 32.30,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Initiate Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Uncommon",
    efficiency: 0.205,
    supply: 35_000,
    floorPrice: 51.00,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Encore Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Rare",
    efficiency: 0.5,
    supply: 20_000,
    floorPrice: 129.00,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Contender Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Epic",
    efficiency: 1.292,
    supply: 10_000,
    floorPrice: 324.00,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Champion Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Exalted",
    efficiency: 2.5,
    supply: 1_000,
    floorPrice: 4_500.00,
    farming: { ratio: 1.0, in_game_time: 600 }
  },
  {
    name: "Challenger Showrunner Contract",
    type_name: "Contract",
    rarity_name: "Legendary",
    efficiency: 5.0,
    supply: 5_000,
    floorPrice: 498.00,
    farming: { ratio: 1.0, in_game_time: 600 }
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
