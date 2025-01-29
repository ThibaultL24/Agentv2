types = [
  { name: "Badge" },
  { name: "Contract" }  # Type unique pour les contrats showrunner
]

puts "Création des types d'items..."
types.each do |type|
  puts "- Création du type: #{type[:name]}"
  Type.find_or_create_by(name: type[:name])
end
puts "✓ Types créés avec succès"
