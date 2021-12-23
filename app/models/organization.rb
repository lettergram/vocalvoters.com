class Organization < ApplicationRecord
  has_many :letters
  has_many :users
end
