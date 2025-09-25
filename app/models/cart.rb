# frozen_string_literal: true
# typed: strict

class Cart < ApplicationRecord
  extend T::Sig

  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  sig { returns(BigDecimal) }
  def total_price
    cart_items.sum(0.to_d, &:total_price)
  end
end
