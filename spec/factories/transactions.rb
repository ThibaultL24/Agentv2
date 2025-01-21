FactoryBot.define do
  factory :transaction do
    association :user
    association :payment_method
    amount { 10.0 }
    currency { 'EUR' }
    status { 'pending' }
    sequence(:external_id) { |n| "tx_#{n}" }
    metadata { {} }
  end
end
