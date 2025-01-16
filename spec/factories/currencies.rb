FactoryBot.define do
  factory :currency do
    sequence(:name) { |n| "Currency #{n}" }
    sequence(:gameName) { |n| "Game Currency #{n}" }
    onChain { false }
    price { 1.0 }
    association :game
  end
end
