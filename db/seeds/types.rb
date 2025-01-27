types = [
  { name: "Weapon" },
  { name: "Armor" },
  { name: "Accessory" },
  { name: "Tool" },
  { name: "Consumable" },
  { name: "Material" },
  { name: "Pet" },
  { name: "Mount" },
  { name: "Cosmetic" },
  { name: "Showrunner" }
]

types.each do |type|
  Type.find_or_create_by(name: type[:name])
end
