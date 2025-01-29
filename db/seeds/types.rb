types = [
  { name: "Badge" },
  { name: "Showrunner" }
]

types.each do |type|
  Type.find_or_create_by(name: type[:name])
end

