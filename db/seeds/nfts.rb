puts "\nCréation des NFTs..."

# Fonction pour générer un prix d'achat aléatoire basé sur le prix plancher
def generate_purchase_price(floor_price)
  variation = rand(0.8..1.2)
  (floor_price * variation).round(2)
end

# Fonction pour générer un ID unique pour chaque NFT
def generate_issue_id(user_id, item_id, index)
  "#{user_id}-#{item_id}-#{index + 1}"
end

User.find_each do |user|
  puts "\n- Création des NFTs pour #{user.username || user.email}"

  # Distribution des NFTs par type et rareté
  ["Badge", "Contract"].each do |type_name|
    puts "  - Type: #{type_name}"

    # Sélectionner les items disponibles pour l'utilisateur en fonction de sa rareté maximale
    available_items = Item.joins(:rarity, :type)
                         .where(types: { name: type_name })
                         .where("rarities.name <= ?", user.maxRarity)
                         .order("RANDOM()")

    # Nombre de NFTs à créer par type (ajuster selon vos besoins)
    nft_count = type_name == "Badge" ? rand(2..4) : rand(1..2)

    available_items.limit(nft_count).each_with_index do |item, index|
      puts "    - Création NFT: #{item.name}"

      Nft.find_or_create_by(
        issueId: generate_issue_id(user.id, item.id, index),
        itemId: item.id,
        owner: user.id.to_s
      ) do |nft|
        nft.purchasePrice = generate_purchase_price(item.floorPrice)
      end
    end
  end
end

puts "\n✓ NFTs créés avec succès"
