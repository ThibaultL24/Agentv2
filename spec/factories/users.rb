FactoryBot.define do
  factory :user do
    sequence(:openLootID) { |n| "user_#{n}" }
    isPremium { false }
    level { 1 }
    experience { 0 }
  end
end
