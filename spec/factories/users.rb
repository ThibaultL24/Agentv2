FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    isPremium { false }
    level { 1 }
    experience { 0 }
    maxRarity { "Epic" }
  end

  factory :player_cycle do
    association :user
    playerCycleType { 1 }
    cycleName { "Daily Cycle" }
    nbBadge { 3 }
    minimumBadgeRarity { "Common" }
    startDate { Time.current }
    endDate { 1.day.from_now }
    nbDateRepeat { 1 }
  end
end
