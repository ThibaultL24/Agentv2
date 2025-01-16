FactoryBot.define do
  factory :slot do
    association :game
    association :currency
    unlockCurrencyNumber { 100 }
    unlockPrice { 50 }
    unlocked { false }
    totalCost { 150 }
  end
end
