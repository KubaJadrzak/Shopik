# frozen_string_literal: true
# typed: strict

class OrderItem < ApplicationRecord
  extend T::Sig
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true
  validates :price_at_purchase, presence: true

  delegate :title, to: :product

  sig { returns(BigDecimal) }
  def total_price
    price_at_purchase * quantity
  end

end
