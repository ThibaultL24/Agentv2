FactoryBot.define do
  factory :badge, class: 'Nft' do
    sequence(:issueId)
    sequence(:itemId) { |n| create(:item).id }
    purchasePrice { 100.0 }
    owner { create(:user).email }
  end
end
