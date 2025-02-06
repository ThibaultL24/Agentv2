# Création de différents profils d'utilisateurs
users = [
  {
    email: "new_player@example.com",
    password: "password123",
    username: "newbie",
    isPremium: false,
    level: 1,
    experience: 0,
    maxRarity: "Common",
    items: [], # Nouveau joueur sans items
    currencies: {
      "CASH" => 5_000,     # Pack de départ
      "FLEX" => 500,       # Pack de départ
      "$BFT" => 0,       # Rien au début
      "Sponsor Marks" => 0,
      "Fame Points" => 0
    },
    slots: ["free"] # Uniquement le slot gratuit
  },
  {
    email: "casual@example.com",
    password: "password123",
    username: "casual_gamer",
    isPremium: false,
    level: 5,
    experience: 1000,
    maxRarity: "Uncommon",
    items: ["Rookie Badge", "Rookie Showrunner Contract"],
    currencies: {
      "CASH" => 15_000,
      "FLEX" => 1_500,
      "$BFT" => 100,
      "Sponsor Marks" => 1_000,
      "Fame Points" => 100
    },
    slots: ["free", "slot_1"] # Slot gratuit + premier slot
  },
  {
    email: "regular@example.com",
    password: "password123",
    username: "regular_player",
    isPremium: true,
    level: 15,
    experience: 5000,
    maxRarity: "Rare",
    items: ["Initiate Badge", "Encore Badge", "Initiate Showrunner Contract"],
    currencies: {
      "CASH" => 50_000,
      "FLEX" => 5_000,
      "$BFT" => 500,
      "Sponsor Marks" => 5_000,
      "Fame Points" => 500
    },
    slots: ["free", "slot_1", "slot_2"] # Tous les slots standards débloqués
  },
  {
    email: "collector@example.com",
    password: "password123",
    username: "nft_collector",
    isPremium: true,
    level: 20,
    experience: 8000,
    maxRarity: "Epic",
    items: ["Rookie Badge", "Initiate Badge", "Encore Badge", "Contender Badge"],
    currencies: {
      "CASH" => 100_000,
      "FLEX" => 10_000,
      "$BFT" => 1_000,
      "Sponsor Marks" => 10_000,
      "Fame Points" => 1_000
    },
    slots: ["free", "slot_1", "slot_2", "premium_1"] # Premier slot premium débloqué
  },
  {
    email: "pro@example.com",
    password: "password123",
    username: "pro_gamer",
    isPremium: true,
    level: 25,
    experience: 12000,
    maxRarity: "Exalted",
    items: ["Contender Badge", "Champion Showrunner Contract", "Contender Showrunner Contract"],
    currencies: {
      "CASH" => 250_000,
      "FLEX" => 25_000,
      "$BFT" => 2_500,
      "Sponsor Marks" => 25_000,
      "Fame Points" => 2_500
    },
    slots: ["free", "slot_1", "slot_2", "premium_1", "premium_2"] # Tous les slots débloqués
  },
  {
    email: "whale@example.com",
    password: "password123",
    username: "crypto_whale",
    isPremium: true,
    level: 30,
    experience: 20000,
    maxRarity: "Legendary",
    items: ["Contender Badge", "Challenger Showrunner Contract", "Champion Showrunner Contract", "Encore Badge"],
    currencies: {
      "CASH" => 500_000,
      "FLEX" => 50_000,
      "$BFT" => 5_000,
      "Sponsor Marks" => 50_000,
      "Fame Points" => 5_000
    },
    slots: ["free", "slot_1", "slot_2", "premium_1", "premium_2"] # Tous les slots débloqués
  }
]

puts "\nCréation des utilisateurs..."
users.each do |user_data|
  puts "- Création de l'utilisateur #{user_data[:username]} (#{user_data[:maxRarity]})"

  # Création de l'utilisateur
  user = User.find_or_create_by(email: user_data[:email]) do |u|
    u.password = user_data[:password]
    u.username = user_data[:username]
    u.isPremium = user_data[:isPremium]
    u.level = user_data[:level]
    u.experience = user_data[:experience]
    u.maxRarity = user_data[:maxRarity]
  end

  # Attribution des currencies à l'utilisateur
  user_data[:currencies].each do |currency_name, amount|
    next if amount == 0
    puts "  - Attribution de #{amount} #{currency_name}"
    # Ici, nous stockerons simplement les montants dans un modèle UserCurrency ou similaire
    # à implémenter plus tard selon les besoins
  end

  # Attribution des slots à l'utilisateur
  user_data[:slots].each do |slot_type|
    slot = case slot_type
    when "free"
      Slot.find_by(unlockPrice: 0)
    when "slot_1"
      Slot.find_by(unlockCurrencyNumber: 5_000)
    when "slot_2"
      Slot.find_by(unlockCurrencyNumber: 15_000)
    when "premium_1"
      Slot.find_by(unlockCurrencyNumber: 500)
    when "premium_2"
      Slot.find_by(unlockCurrencyNumber: 1_500)
    end

    if slot
      UserSlot.find_or_create_by!(user: user, slot: slot)
      puts "  - Attribution du slot: #{slot_type}"
    end
  end

  # Attribution des items à l'utilisateur via NFTs
  user_data[:items].each do |item_name|
    item = Item.find_by(name: item_name)
    if item
      puts "  - Attribution de l'item: #{item_name}"
      Nft.find_or_create_by!(owner: user.id.to_s, itemId: item.id) do |nft|
        nft.issueId = "#{user.id}-#{item.id}-#{Nft.where(itemId: item.id).count + 1}"
        nft.purchasePrice = item.floorPrice
      end
    else
      puts "  ⚠️ Item non trouvé: #{item_name}"
    end
  end
end

puts "✓ Utilisateurs créés avec succès"
