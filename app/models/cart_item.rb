# frozen_string_literal: true
# typed: strict

class CartItem < ApplicationRecord
  belongs_to :cart, touch: true
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  #: -> BigDecimal
  def total_price
    T.must(product).price * quantity
  end
end
