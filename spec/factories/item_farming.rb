FactoryBot.define do
  factory :item_farming, class: 'ItemFarming' do
    efficiency { 100 }
    ratio { 1.5 }
    in_game_time { 600 } # 10 minutes
  end
end
