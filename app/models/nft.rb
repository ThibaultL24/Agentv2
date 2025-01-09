class Nft < ApplicationRecord
  belongs_to :item
  has_many :badge_used
  has_many :matches, through: :badge_used
end
