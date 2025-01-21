class PaymentMethod < ApplicationRecord
  has_many :transactions

  validates :name, presence: true
  validates :provider, presence: true, uniqueness: true

  scope :active, -> { where(is_active: true) }
end
