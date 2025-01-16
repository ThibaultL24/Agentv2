FactoryBot.define do
  factory :badge_used do
    association :match
    sequence(:nftId)
  end
end
