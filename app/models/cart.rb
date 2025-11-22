# frozen_string_literal: true
# typed: strict

class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  after_touch { T.must(user).touch if user }

  #: -> BigDecimal
  def total_price
    cart_items.sum(BigDecimal(0), &:total_price)
  end
end
