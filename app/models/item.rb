class Item < ApplicationRecord
  has_many :nfts
  belongs_to :rarity
  belongs_to :type
end
