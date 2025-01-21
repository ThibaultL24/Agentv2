class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :payment_method

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true
  validates :external_id, presence: true, uniqueness: true

  enum :status, {
    pending: "pending",
    completed: "completed",
    failed: "failed",
    refunded: "refunded"
  }, default: :pending
end
