# frozen_string_literal: true
# typed: strict

class Order < ApplicationRecord
  belongs_to :user, touch: true
  has_many :order_items, dependent: :destroy
  has_many :payments, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy


  validates :email, presence: true
  validates :total_price, presence: true
  validates :state, presence: true
  validates :shipping_address, presence: true
  validates :ordered_at, presence: true

  before_create :generate_uuid

  scope :should_be_resigned, -> {
    left_outer_joins(:payments)
      .where(payments: { id: nil })
      .where('orders.updated_at < ?', 1.hour.ago)
  }

  broadcasts_refreshes

  #: -> String
  def to_param
    uuid
  end

  #: -> String?
  def last_payment_state
    payments.first&.state
  end

  #: -> ::Payment?
  def last_payment
    payments.first
  end

  #: (Cart cart) -> void
  def build_order_items_from_cart(cart)
    cart.cart_items.each do |cart_item|
      order_items.build(
        product:           cart_item.product,
        quantity:          cart_item.quantity,
        price_at_purchase: cart_item.product&.price,
      )
      user&.cart_items&.destroy_all
    end
  end

  #: -> bool
  def can_retry_payment?
    payments.all?(&:retryable?)
  end

  #: -> bool
  def can_reverse_payment?
    payments.first&.reversable? || false
  end

  #: -> bool
  def can_refund_payment?
    payments.first&.refundable? || false
  end

  #: -> BigDecimal
  def amount
    total_price
  end

  private

  #: -> void
  def generate_uuid
    self.uuid = "ord_#{SecureRandom.uuid}"
  end
end
