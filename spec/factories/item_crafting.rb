FactoryBot.define do
  factory :item_crafting, class: 'ItemCrafting' do
    unit_to_craft { 1 }
    flex_craft { 100 }
    sponsor_mark_craft { 50 }
    nb_lower_badge_to_craft { 2 }
  end
end
