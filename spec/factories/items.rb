FactoryBot.define do
  factory :item do
    sequence(:name) { |n| "Item #{n}" }
    efficiency { 100 }
    supply { 1000 }
    floorPrice { 100 }

    association :rarity
    association :type

    trait :with_farming do
      after(:create) do |item|
        create(:item_farming, item: item)
      end
    end

    trait :with_crafting do
      after(:create) do |item|
        create(:item_crafting, item: item)
      end
    end

    trait :with_recharge do
      after(:create) do |item|
        create(:item_recharge, item: item)
      end
    end
  end
end
