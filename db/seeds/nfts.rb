# Création d'instances de badges (NFTs) pour chaque utilisateur
User.find_each do |user|
  # Sélectionner des badges disponibles pour l'utilisateur en fonction de sa rareté maximale
  available_badges = Item.joins(:rarity, :type)
                        .where("rarities.name <= ?", user.maxRarity)
                        .where.not(types: { name: 'Showrunner' }) # Exclure les contrats
                        .order("RANDOM()")
                        .limit(3)

  available_badges.each_with_index do |badge, index|
    # Création d'une instance unique du badge pour l'utilisateur
    Nft.find_or_create_by(
      issueId: "#{user.id}-#{badge.id}-#{index + 1}", # ID unique pour chaque instance
      itemId: badge.id,                               # Référence au badge (item)
      owner: user.id.to_s                            # Propriétaire du NFT
    ) do |nft|
      # Prix d'achat aléatoire autour du prix plancher du badge
      nft.purchasePrice = badge.floorPrice * rand(0.8..1.2)
    end
  end
end
