# frozen_string_literal: true
# typed: strict

class Product < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :membership_price, numericality: { greater_than: 0 }, allow_nil: true

  #: (User)  -> BigDecimal
  def effective_price_for(user)
    if user.active_subscription?
      membership_price || price
    else
      price
    end
  end
end
