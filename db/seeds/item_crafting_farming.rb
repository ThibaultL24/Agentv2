puts "\nCréation des données de crafting et farming..."

# Récupérer tous les items
items = Item.all

items.each do |item|
  # Création des données de crafting
  puts "- Création des données de crafting pour #{item.name}"
  ItemCrafting.find_or_create_by!(item: item) do |crafting|
    case item.rarity.name
    when "Common"
      crafting.unit_to_craft = 1
      crafting.flex_craft = 1300
      crafting.sponsor_mark_craft = 0
      crafting.nb_lower_badge_to_craft = 0
    when "Uncommon"
      crafting.unit_to_craft = 2
      crafting.flex_craft = 2900
      crafting.sponsor_mark_craft = 2430
      crafting.nb_lower_badge_to_craft = 2
    when "Rare"
      crafting.unit_to_craft = 3
      crafting.flex_craft = 1400
      crafting.sponsor_mark_craft = 4053
      crafting.nb_lower_badge_to_craft = 3
    when "Epic"
      crafting.unit_to_craft = 4
      crafting.flex_craft = 6300
      crafting.sponsor_mark_craft = 10142
      crafting.nb_lower_badge_to_craft = 4
    when "Legendary"
      crafting.unit_to_craft = 5
      crafting.flex_craft = 25900
      crafting.sponsor_mark_craft = 16919
      crafting.nb_lower_badge_to_craft = 5
    else
      crafting.unit_to_craft = 6
      crafting.flex_craft = 92700
      crafting.sponsor_mark_craft = 28222
      crafting.nb_lower_badge_to_craft = 6
    end
  end

  # Création des données de farming
  puts "- Création des données de farming pour #{item.name}"
  ItemFarming.find_or_create_by!(item: item) do |farming|
    case item.rarity.name
    when "Common"
      farming.efficiency = 1.0
      farming.ratio = 1.0
    when "Uncommon"
      farming.efficiency = 2.05
      farming.ratio = 2.05
    when "Rare"
      farming.efficiency = 4.20
      farming.ratio = 2.15
    when "Epic"
      farming.efficiency = 12.92
      farming.ratio = 8.72
    when "Legendary"
      farming.efficiency = 39.74
      farming.ratio = 26.82
    else
      farming.efficiency = 122.19
      farming.ratio = 82.45
    end
    farming.in_game_time = 600 # 10 minutes par défaut
  end
end

puts "✓ Données de crafting et farming créées avec succès"
