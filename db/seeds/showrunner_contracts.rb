showrunner_type = Type.find_by(name: 'Showrunner')
rarities = Rarity.all

contracts = [
  {
    name: "Rookie Showrunner",
    rarity_name: "Common",
    efficiency: 40, # Win rate requirement
    supply: 1000,
    floorPrice: 50, # Reward amount
    farming: {
      in_game_time: 5, # Required matches
      efficiency: 40,
      ratio: 1.0
    }
  },
  {
    name: "Veteran Showrunner",
    rarity_name: "Rare",
    efficiency: 55,
    supply: 500,
    floorPrice: 150,
    farming: {
      in_game_time: 10,
      efficiency: 55,
      ratio: 1.2
    }
  },
  {
    name: "Elite Showrunner",
    rarity_name: "Epic",
    efficiency: 65,
    supply: 200,
    floorPrice: 300,
    farming: {
      in_game_time: 15,
      efficiency: 65,
      ratio: 1.5
    }
  },
  {
    name: "Master Showrunner",
    rarity_name: "Legendary",
    efficiency: 75,
    supply: 50,
    floorPrice: 1000,
    farming: {
      in_game_time: 20,
      efficiency: 75,
      ratio: 2.0
    }
  }
]

contracts.each do |contract_data|
  rarity = Rarity.find_by(name: contract_data[:rarity_name])

  # Création du contrat (item de type Showrunner)
  contract = Item.find_or_create_by(name: contract_data[:name]) do |c|
    c.type = showrunner_type
    c.rarity = rarity
    c.efficiency = contract_data[:efficiency]
    c.supply = contract_data[:supply]
    c.floorPrice = contract_data[:floorPrice]
  end

  # Création des données de farming
  ItemFarming.find_or_create_by(item: contract) do |farming|
    farming_data = contract_data[:farming]
    farming.in_game_time = farming_data[:in_game_time]
    farming.efficiency = farming_data[:efficiency]
    farming.ratio = farming_data[:ratio]
  end
end
