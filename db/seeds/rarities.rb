rarities = [
  { name: "Common", color: "#808080" },        # Gris
  { name: "Uncommon", color: "#1eff00" },      # Vert
  { name: "Rare", color: "#0070dd" },          # Bleu
  { name: "Epic", color: "#a335ee" },          # Violet
  { name: "Legendary", color: "#ff8000" },     # Orange
  { name: "Mythic", color: "#ff00ff" },        # Magenta
  { name: "Exalted", color: "#ffff00" },       # Jaune
  { name: "Exotic", color: "#ff007f" },        # Rose vif
  { name: "Transcendent", color: "#00ffff" },  # Cyan
  { name: "Unique", color: "#ffffff" }         # Blanc
]

rarities.each do |rarity|
  Rarity.find_or_create_by(name: rarity[:name]) do |r|
      r.color = rarity[:color]
  end
end
