# Définition des badges avec les métriques essentielles
badges = [
  {
    name: "Rookie",
    rarity_name: "Common",
    type_name: "Badge",
    efficiency: 0.1,
    ratio: 1,
    supply: 200_000,
    floorPrice: 7.50,
    max_energy: 1,
    time_to_charge: "8h00",
    sbft_per_minute: 15,
    sbft_per_charge: 800,
    sbft_value_per_charge: 9.00
  },
  {
    name: "Initiate",
    rarity_name: "Uncommon",
    type_name: "Badge",
    efficiency: 0.205,
    ratio: 2.05,
    supply: 100_000,
    floorPrice: 28.50,
    max_energy: 2,
    time_to_charge: "7h45",
    sbft_per_minute: 50,
    sbft_per_charge: 6_000,
    sbft_value_per_charge: 490.00
  },
  {
    name: "Contender",
    rarity_name: "Epic",
    type_name: "Badge",
    efficiency: 1.292,
    ratio: 8.72,
    supply: 25_000,
    floorPrice: 410.00,
    max_energy: 4,
    time_to_charge: "7h15",
    sbft_per_minute: 350,
    sbft_per_charge: 84_000,
    sbft_value_per_charge: 8445.00
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
    b.max_energy = badge_data[:max_energy]
    b.time_to_charge = badge_data[:time_to_charge]
    b.sbft_per_minute = badge_data[:sbft_per_minute]
    b.sbft_per_charge = badge_data[:sbft_per_charge]
    b.sbft_value_per_charge = badge_data[:sbft_value_per_charge]
    b.ratio = badge_data[:ratio]
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
