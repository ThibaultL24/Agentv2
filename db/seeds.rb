# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Charger les seeds dans un ordre spécifique pour respecter les dépendances
seed_files = [
  'rarities.rb',  # Définition des raretés
  'types.rb',     # Définition des types d'items
  'badges.rb',    # Définition des badges (items spéciaux)
  'users.rb',     # Création des utilisateurs
  'nfts.rb',      # Création des instances de badges (NFTs)
  'showrunner_contracts.rb'  # Ajout des contrats de showrunner
]

seed_files.each do |file|
  puts "Seeding #{file}..."
  load Rails.root.join('db', 'seeds', file)
  puts "✓ Done"
end

puts "\nSeeding completed successfully! 🌱"
