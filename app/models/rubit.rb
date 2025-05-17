class Rubit < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :likes_by_users, through: :likes, source: :user
end
