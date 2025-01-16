FactoryBot.define do
  factory :badge, class: 'Nft' do
    sequence(:issueId)
    owner { association(:user).openLootID }
    itemId { association(:item).id }
    purchasePrice { 100.0 }
  end
end
