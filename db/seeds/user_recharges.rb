# Création des réductions de recharge pour chaque utilisateur
puts "\nCréation des réductions de recharge..."

# Liste des temps de réduction possibles (en pourcentage)
discount_times = [5, 9, 10, 13, 16, 20, 25]

User.find_each do |user|
  puts "- Création des réductions pour #{user.username || user.email}"

  # Création d'une réduction pour chaque pourcentage
  discount_times.each do |time|
    UserRecharge.find_or_create_by!(user: user, discountTime: time) do |recharge|
      recharge.discountNumber = rand(1..5) # Nombre aléatoire de réductions entre 1 et 5
    end
  end
end

puts "✓ Réductions de recharge créées avec succès"
