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
    items: [] # Nouveau joueur sans items
  },
  {
    email: "casual@example.com",
    password: "password123",
    username: "casual_gamer",
    isPremium: false,
    level: 5,
    experience: 1000,
    maxRarity: "Uncommon",
    items: ["Rookie Badge", "Rookie Showrunner Contract"] # Joueur casual avec items de base
  },
  {
    email: "regular@example.com",
    password: "password123",
    username: "regular_player",
    isPremium: true,
    level: 15,
    experience: 5000,
    maxRarity: "Rare",
    items: ["Initiate Badge", "Encore Badge", "Initiate Showrunner Contract"] # Joueur régulier avec quelques badges
  },
  {
    email: "collector@example.com",
    password: "password123",
    username: "nft_collector",
    isPremium: true,
    level: 20,
    experience: 8000,
    maxRarity: "Epic",
    items: ["Rookie Badge", "Initiate Badge", "Encore Badge", "Contender Badge"] # Collectionneur de badges
  },
  {
    email: "pro@example.com",
    password: "password123",
    username: "pro_gamer",
    isPremium: true,
    level: 25,
    experience: 12000,
    maxRarity: "Exalted",
    items: ["Contender Badge", "Champion Showrunner Contract", "Contender Showrunner Contract"] # Joueur pro focalisé sur les contrats
  },
  {
    email: "whale@example.com",
    password: "password123",
    username: "crypto_whale",
    isPremium: true,
    level: 30,
    experience: 20000,
    maxRarity: "Legendary",
    items: ["Contender Badge", "Challenger Showrunner Contract", "Champion Showrunner Contract", "Encore Badge"] # Whale avec items rares
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

  # Attribution des items à l'utilisateur via NFTs
  user_data[:items].each do |item_name|
    item = Item.find_by(name: item_name)
    if item
      puts "  - Attribution de l'item: #{item_name}"
      # Création d'un NFT pour chaque item
      Nft.find_or_create_by!(owner: user.id, itemId: item.id) do |nft|
        nft.issueId = Nft.where(itemId: item.id).count + 1
        nft.purchasePrice = item.floorPrice
      end
    else
      puts "  ⚠️ Item non trouvé: #{item_name} (sera créé plus tard)"
    end
  end
end
puts "✓ Utilisateurs créés avec succès"
