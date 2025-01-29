# Définition des badges avec les métriques essentielles
badges = [
  {
    name: "Rookie Badge",
    rarity_name: "Common",
    type_name: "Badge",
    efficiency: 0.1,
    supply: 200_000,
    floorPrice: 7.98
  },
  {
    name: "Initiate Badge",
    rarity_name: "Uncommon",
    type_name: "Badge",
    efficiency: 0.205,
    supply: 100_000,
    floorPrice: 26.00
  },
  {
    name: "Encore Badge",
    rarity_name: "Rare",
    type_name: "Badge",
    efficiency: 0.5,
    supply: 50_000,
    floorPrice: 119.00
  },
  {
    name: "Contender Badge",
    rarity_name: "Epic",
    type_name: "Badge",
    efficiency: 1.292,
    supply: 25_000,
    floorPrice: 404.00
  }
]

# Création des badges
badges.each do |badge_data|
  badge = Item.find_or_create_by(name: badge_data[:name]) do |b|
    b.rarity = Rarity.find_by!(name: badge_data[:rarity_name])
    b.type = Type.find_by!(name: badge_data[:type_name])
    b.efficiency = badge_data[:efficiency]
    b.supply = badge_data[:supply]
    b.floorPrice = badge_data[:floorPrice]
  end

  # Création des données de farming (nécessaire pour les calculs de ratio)
  ItemFarming.find_or_create_by(item: badge) do |farming|
    farming.ratio = 1.0
    farming.efficiency = badge.efficiency
    farming.in_game_time = 600 # 10 minutes par défaut
  end
end
