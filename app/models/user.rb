class User < ApplicationRecord
  has_many :nfts, foreign_key: :owner, primary_key: :openLootID
  has_many :matches
  has_many :user_slots
  has_many :user_builds
end
