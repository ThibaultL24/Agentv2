FactoryBot.define do
  factory :user_slot do
    association :user
    association :slot
    unlocked { false }
  end
end
