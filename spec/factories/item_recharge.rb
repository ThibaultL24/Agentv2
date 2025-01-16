FactoryBot.define do
  factory :item_recharge, class: 'ItemRecharge' do
    max_energy_recharge { 100 }
    time_to_charge { 3600 }
    flex_charge { 50 }
    sponsor_mark_charge { 25 }
    unit_charge_cost { 10 }
    max_charge_cost { 100 }
  end
end
