users = [
  {
    email: "test@example.com",
    password: "password123",
    username: "testuser",
    isPremium: true,
    level: 1,
    experience: 0,
    maxRarity: "Legendary"
  },
  {
    email: "player@example.com",
    password: "password123",
    username: "player1",
    isPremium: false,
    level: 5,
    experience: 1000,
    maxRarity: "Epic"
  }
]

users.each do |user_data|
  User.find_or_create_by(email: user_data[:email]) do |user|
    user.password = user_data[:password]
    user.username = user_data[:username]
    user.isPremium = user_data[:isPremium]
    user.level = user_data[:level]
    user.experience = user_data[:experience]
    user.maxRarity = user_data[:maxRarity]
  end
end

