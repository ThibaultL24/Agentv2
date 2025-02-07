class PlayerCycle < ApplicationRecord
  belongs_to :user
  has_many :matches

  validates :playerCycleType, presence: true
  validates :cycleName, presence: true
  validates :nbBadge, presence: true
  validates :minimumBadgeRarity, presence: true
  validates :startDate, presence: true
  validates :endDate, presence: true
  validates :nbDateRepeat, presence: true
end
