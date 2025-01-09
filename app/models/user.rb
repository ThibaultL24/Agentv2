class User < ApplicationRecord
  has_many :user_builds
  has_many :user_recharges
  has_many :player_cycles
  has_many :matches
  has_many :user_slots
  has_many :nfts, foreign_key: :owner, class_name: "Nft"
end
