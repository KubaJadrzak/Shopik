# frozen_string_literal: true
# typed: strict

class Order < ApplicationRecord
  belongs_to :user, optional: true, touch: true
  has_many :order_items, dependent: :destroy
  has_many :payments, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy


  validates :email, presence: true
  validates :total_price, presence: true
  validates :status, presence: true
  validates :shipping_address, presence: true
  validates :ordered_at, presence: true
  validate :must_have_order_items

  before_create :generate_uuid

  broadcasts_refreshes

  #: (Cart cart) -> void
  def build_order_items_from_cart(cart)
    cart.cart_items.each do |cart_item|
      order_items.build(
        product:           cart_item.product,
        quantity:          cart_item.quantity,
        price_at_purchase: T.must(cart_item.product).price,
      )
      owner = user #: as !nil
      owner.cart&.cart_items&.destroy_all
    end
  end

  #: -> bool
  def can_retry_payment?
    payments.all?(&:retryable?) && status != 'Payment Refunded'
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

  #: -> void
  def must_have_order_items
    return unless order_items.empty?

    errors.add(:base, 'order must have at least one item.')
  end

end
