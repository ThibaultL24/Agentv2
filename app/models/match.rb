class Match < ApplicationRecord
  belongs_to :user
  has_many :badge_used
  has_many :nfts

end
