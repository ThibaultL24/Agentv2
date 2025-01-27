# Définition des badges (qui sont des items spéciaux)
badges = [
  {
    name: "Sword Master",
    rarity_name: "Legendary",
    type_name: "Weapon",
    efficiency: 95.5,
    supply: 100,
    floorPrice: 1000.0,
    farming: {
      efficiency: 95.5,
      ratio: 2.0,
      in_game_time: 600 # 10 minutes
    },
    crafting: {
      unit_to_craft: 1,
      flex_craft: 800.0,      # 80% du floorPrice
      sponsor_mark_craft: 100.0, # 10% du floorPrice
      nb_lower_badge_to_craft: 2
    },
    recharge: {
      max_energy_recharge: 100,
      time_to_charge: 3600,    # 1 heure
      flex_charge: 50.0,       # 5% du floorPrice
      sponsor_mark_charge: 10.0, # 1% du floorPrice
      unit_charge_cost: 20.0,   # 2% du floorPrice
      max_charge_cost: 100.0    # 10% du floorPrice
    }
  },
  {
    name: "Dragon Knight",
    rarity_name: "Epic",
    type_name: "Armor",
    efficiency: 85.0,
    supply: 200,
    floorPrice: 750.0,
    farming: {
      efficiency: 85.0,
      ratio: 1.8,
      in_game_time: 600
    },
    crafting: {
      unit_to_craft: 1,
      flex_craft: 600.0,
      sponsor_mark_craft: 75.0,
      nb_lower_badge_to_craft: 2
    },
    recharge: {
      max_energy_recharge: 90,
      time_to_charge: 3600,
      flex_charge: 37.5,
      sponsor_mark_charge: 7.5,
      unit_charge_cost: 15.0,
      max_charge_cost: 75.0
    }
  },
  {
    name: "Fortune Seeker",
    rarity_name: "Rare",
    type_name: "Accessory",
    efficiency: 75.0,
    supply: 500,
    floorPrice: 500.0,
    farming: {
      efficiency: 75.0,
      ratio: 1.6,
      in_game_time: 600
    },
    crafting: {
      unit_to_craft: 1,
      flex_craft: 400.0,
      sponsor_mark_craft: 50.0,
      nb_lower_badge_to_craft: 2
    },
    recharge: {
      max_energy_recharge: 80,
      time_to_charge: 3600,
      flex_charge: 25.0,
      sponsor_mark_charge: 5.0,
      unit_charge_cost: 10.0,
      max_charge_cost: 50.0
    }
  },
  {
    name: "Resource Gatherer",
    rarity_name: "Uncommon",
    type_name: "Tool",
    efficiency: 65.0,
    supply: 1000,
    floorPrice: 250.0,
    farming: {
      efficiency: 65.0,
      ratio: 1.4,
      in_game_time: 600
    },
    crafting: {
      unit_to_craft: 1,
      flex_craft: 200.0,
      sponsor_mark_craft: 25.0,
      nb_lower_badge_to_craft: 1
    },
    recharge: {
      max_energy_recharge: 70,
      time_to_charge: 3600,
      flex_charge: 12.5,
      sponsor_mark_charge: 2.5,
      unit_charge_cost: 5.0,
      max_charge_cost: 25.0
    }
  }
]

# Création des badges
badges.each do |badge_data|
  # Création de l'item (badge)
  badge = Item.find_or_create_by(name: badge_data[:name]) do |b|
    b.rarity = Rarity.find_by!(name: badge_data[:rarity_name])
    b.type = Type.find_by!(name: badge_data[:type_name])
    b.efficiency = badge_data[:efficiency]
    b.supply = badge_data[:supply]
    b.floorPrice = badge_data[:floorPrice]
  end

  # Création des données de farming
  ItemFarming.find_or_create_by(item: badge) do |farming|
    farming_data = badge_data[:farming]
    farming.efficiency = farming_data[:efficiency]
    farming.ratio = farming_data[:ratio]
    farming.in_game_time = farming_data[:in_game_time]
  end

  # Création des données de crafting
  ItemCrafting.find_or_create_by(item: badge) do |crafting|
    crafting_data = badge_data[:crafting]
    crafting.unit_to_craft = crafting_data[:unit_to_craft]
    crafting.flex_craft = crafting_data[:flex_craft]
    crafting.sponsor_mark_craft = crafting_data[:sponsor_mark_craft]
    crafting.nb_lower_badge_to_craft = crafting_data[:nb_lower_badge_to_craft]
  end

  # Création des données de recharge
  ItemRecharge.find_or_create_by(item: badge) do |recharge|
    recharge_data = badge_data[:recharge]
    recharge.max_energy_recharge = recharge_data[:max_energy_recharge]
    recharge.time_to_charge = recharge_data[:time_to_charge]
    recharge.flex_charge = recharge_data[:flex_charge]
    recharge.sponsor_mark_charge = recharge_data[:sponsor_mark_charge]
    recharge.unit_charge_cost = recharge_data[:unit_charge_cost]
    recharge.max_charge_cost = recharge_data[:max_charge_cost]
  end
end
