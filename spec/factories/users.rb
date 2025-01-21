FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    sequence(:openLootID) { |n| "user_#{n}" }
    isPremium { false }
    level { 1 }
    experience { 0 }
  end
end
