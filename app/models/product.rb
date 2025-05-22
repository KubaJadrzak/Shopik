# typed: strict

class Product < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end
