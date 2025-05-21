# typed: strict

class CartItem < ApplicationRecord
  extend T::Sig
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  sig { returns(BigDecimal) }
  def total_price
    T.must(product).price * quantity
  end
end
