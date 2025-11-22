# frozen_string_literal: true
# typed: strict

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  delegate :price, :title, to: :product

  #: -> BigDecimal
  def total_price
    T.must(product).price * quantity
  end
end
