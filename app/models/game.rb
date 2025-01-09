class Game < ApplicationRecord
  has_many :currencies
  has_many :slots
end
