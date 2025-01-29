rarities = Rarity.all

# Définition des contrats showrunner avec les métriques essentielles
contracts = [
  {
    name: "Rookie Showrunner Contract",
    rarity_name: "Common",
    type_name: "Contract",
    efficiency: 0.1,
    supply: 50_000,
    floorPrice: 32.30
  },
  {
    name: "Initiate Showrunner Contract",
    rarity_name: "Uncommon",
    type_name: "Contract",
    efficiency: 0.205,
    supply: 35_000,
    floorPrice: 51.00
  },
  {
    name: "Encore Showrunner Contract",
    rarity_name: "Rare",
    type_name: "Contract",
    efficiency: 0.5,
    supply: 20_000,
    floorPrice: 129.00
  },
  {
    name: "Contender Showrunner Contract",
    rarity_name: "Epic",
    type_name: "Contract",
    efficiency: 1.292,
    supply: 10_000,
    floorPrice: 324.00
  },
  {
    name: "Champion Showrunner Contract",
    rarity_name: "Exalted",
    type_name: "Contract",
    efficiency: 2.5,
    supply: 1_000,
    floorPrice: 4_500.00
  },
  {
    name: "Challenger Showrunner Contract",
    rarity_name: "Legendary",
    type_name: "Contract",
    efficiency: 5.0,
    supply: 5_000,
    floorPrice: 498.00
  }
]

puts "\nCréation des contrats de showrunner..."
contracts.each do |contract_data|
  rarity = Rarity.find_by!(name: contract_data[:rarity_name])
  puts "- Création du contrat #{contract_data[:name]} (#{contract_data[:rarity_name]})"

  # Création du contrat
  contract = Item.find_or_create_by!(name: contract_data[:name]) do |c|
    c.type = Type.find_by!(name: contract_data[:type_name])
    c.rarity = rarity
    c.efficiency = contract_data[:efficiency]
    c.supply = contract_data[:supply]
    c.floorPrice = contract_data[:floorPrice]
  end

  # Création des données de farming
  ItemFarming.find_or_create_by!(item: contract) do |farming|
    farming.ratio = 1.0
    farming.efficiency = contract.efficiency
    farming.in_game_time = 600 # 10 minutes par défaut
  end
end
puts "✓ Contrats de showrunner créés avec succès"
