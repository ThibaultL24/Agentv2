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
      gold: 100,    # Montant de départ en Gold
      gems: 0       # Pas de Gems au début
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
      gold: 1000,
      gems: 10
    },
    slots: ["free", "gold_1"] # Slot gratuit + premier slot Gold
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
      gold: 5000,
      gems: 50
    },
    slots: ["free", "gold_1", "gold_2"] # Tous les slots Gold débloqués
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
      gold: 10000,
      gems: 100
    },
    slots: ["free", "gold_1", "gold_2", "premium_1"] # Premier slot Premium débloqué
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
      gold: 25000,
      gems: 250
    },
    slots: ["free", "gold_1", "gold_2", "premium_1", "premium_2"] # Tous les slots débloqués
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
      gold: 50000,
      gems: 500
    },
    slots: ["free", "gold_1", "gold_2", "premium_1", "premium_2"] # Tous les slots débloqués
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
  game = Game.find_by!(name: "Boss Fighters")
  gold = Currency.find_by!(name: "Gold")
  gems = Currency.find_by!(name: "Gems")

  # Création des transactions pour les currencies initiales
  if user_data[:currencies][:gold] > 0
    Transaction.find_or_create_by!(
      user: user,
      payment_method: PaymentMethod.find_or_create_by!(provider: 'system', name: 'Initial Balance'),
      amount: user_data[:currencies][:gold],
      currency: 'GOLD',
      status: 'completed',
      external_id: "initial_gold_#{user.id}",
      metadata: { type: 'initial_balance', currency: 'gold' }
    )
  end

  if user_data[:currencies][:gems] > 0
    Transaction.find_or_create_by!(
      user: user,
      payment_method: PaymentMethod.find_or_create_by!(provider: 'system', name: 'Initial Balance'),
      amount: user_data[:currencies][:gems],
      currency: 'GEMS',
      status: 'completed',
      external_id: "initial_gems_#{user.id}",
      metadata: { type: 'initial_balance', currency: 'gems' }
    )
  end

  # Attribution des slots à l'utilisateur
  user_data[:slots].each do |slot_type|
    slot = case slot_type
    when "free"
      Slot.find_by(game: game, unlockPrice: 0)
    when "gold_1"
      Slot.find_by(game: game, currency: gold, unlockCurrencyNumber: 1000)
    when "gold_2"
      Slot.find_by(game: game, currency: gold, unlockCurrencyNumber: 2500)
    when "premium_1"
      Slot.find_by(game: game, currency: gems, unlockCurrencyNumber: 100)
    when "premium_2"
      Slot.find_by(game: game, currency: gems, unlockCurrencyNumber: 250)
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
      # Création d'un NFT pour chaque item
      Nft.find_or_create_by!(owner: user.id, itemId: item.id) do |nft|
        nft.issueId = Nft.where(itemId: item.id).count + 1
        nft.purchasePrice = item.floorPrice
      end
    else
      puts "  ⚠️ Item non trouvé: #{item_name}"
    end
  end
end
puts "✓ Utilisateurs créés avec succès"
