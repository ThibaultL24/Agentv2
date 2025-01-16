FactoryBot.define do
  factory :rarity do
    sequence(:name) { |n| ["Common", "Uncommon", "Rare", "Epic", "Legendary"][n % 5] }
  end
end
