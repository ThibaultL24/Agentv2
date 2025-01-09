class Currency < ApplicationRecord
  belongs_to :game
  has_many :currency_packs
  has_many :slots
end
