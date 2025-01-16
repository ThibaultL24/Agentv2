FactoryBot.define do
  factory :type do
    sequence(:name) { |n| ["Weapon", "Armor", "Badge", "Consumable"][n % 4] }
  end
end
