class Slot < ApplicationRecord
  belongs_to :currency
  belongs_to :game
  has_many :user_slots
  has_many :users
end
