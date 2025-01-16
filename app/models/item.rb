class Item < ApplicationRecord
  belongs_to :type
  belongs_to :rarity
  has_one :item_farming
  has_one :item_crafting
  has_one :item_recharge
  has_many :nfts, foreign_key: :itemId
end
