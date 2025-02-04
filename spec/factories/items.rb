FactoryBot.define do
  factory :item do
    sequence(:name) { |n| "Item #{n}" }
    efficiency { 1.0 }
    supply { 1000 }
    floorPrice { 100.0 }
    association :type
    association :rarity

    trait :badge do
      association :type, factory: :type, name: 'Badge'

      transient do
        rarity_name { 'Common' }
      end

      after(:create) do |item, evaluator|
        metrics = case evaluator.rarity_name
        when 'Common'
          { efficiency: 1.00, ratio: 1.00, bft_per_min: 5, flex: 1300, sm: 0 }
        when 'Uncommon'
          { efficiency: 2.05, ratio: 2.05, bft_per_min: 8, flex: 2900, sm: 2430 }
        when 'Rare'
          { efficiency: 4.20, ratio: 2.15, bft_per_min: 10, flex: 1400, sm: 4053 }
        when 'Epic'
          { efficiency: 12.92, ratio: 8.72, bft_per_min: 15, flex: 6300, sm: 10142 }
        when 'Legendary'
          { efficiency: 39.74, ratio: 26.82, bft_per_min: 20, flex: 25900, sm: 16919 }
        when 'Mythic'
          { efficiency: 122.19, ratio: 82.45, bft_per_min: 30, flex: 92700, sm: 28222 }
        end

        item.update!(
          efficiency: metrics[:efficiency],
          rarity: create(:rarity, name: evaluator.rarity_name)
        )

        create(:item_farming,
          item: item,
          ratio: metrics[:ratio],
          in_game_time: 600
        )

        create(:item_crafting,
          item: item,
          flex_craft: metrics[:flex],
          sponsor_mark_craft: metrics[:sm],
          unit_to_craft: 1,
          nb_lower_badge_to_craft: 2
        )

        recharge_costs = case evaluator.rarity_name
        when 'Common'
          { flex: 500, sm: 150, charges: 1 }
        when 'Uncommon'
          { flex: 1400, sm: 350, charges: 2 }
        when 'Rare'
          { flex: 3300, sm: 876, charges: 3 }
        when 'Epic'
          { flex: 1600, sm: 1948, charges: 4 }
        when 'Legendary'
          { flex: 12000, sm: 4065, charges: 5 }
        when 'Mythic'
          { flex: 23500, sm: 8400, charges: 6 }
        end

        create(:item_recharge,
          item: item,
          max_energy_recharge: recharge_costs[:charges],
          time_to_charge: "48h",
          unit_charge_cost: recharge_costs[:flex],
          sponsor_mark_charge: recharge_costs[:sm]
        )
      end
    end

    trait :contract do
      association :type, factory: :type, name: 'Contract'
    end
  end

  factory :type do
    sequence(:name) { |n| "Type #{n}" }
  end

  factory :rarity do
    sequence(:name) { |n| "Rarity #{n}" }
  end

  factory :item_farming do
    association :item
    in_game_time { 600 }
    ratio { 1.0 }
  end

  factory :item_crafting do
    association :item
    unit_to_craft { 1 }
    nb_lower_badge_to_craft { 2 }
    flex_craft { 1000 }
    sponsor_mark_craft { 500 }
  end

  factory :item_recharge do
    association :item
    max_energy_recharge { 100 }
    time_to_charge { "48h" }
    unit_charge_cost { 500 }
  end
end
