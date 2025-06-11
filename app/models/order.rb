# typed: strict

class Order < ApplicationRecord
  extend T::Sig
  belongs_to :user, optional: true, touch: true
  has_many :order_items, dependent: :destroy
  has_many :payments, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy


  validates :email, presence: true
  validates :total_price, presence: true
  validates :status, presence: true
  validates :shipping_address, presence: true
  validates :ordered_at, presence: true
  validate :must_have_order_items

  before_create :generate_order_number

  broadcasts_refreshes

  sig { params(cart: Cart).void }
  def build_order_items_from_cart(cart)
    cart.cart_items.each do |cart_item|
      order_items.build(
        product:           cart_item.product,
        quantity:          cart_item.quantity,
        price_at_purchase: T.must(cart_item.product).price,
      )
    end
  end

  sig { returns(T::Boolean) }
  def can_retry_payment?
    payments.all?(&:retryable?)
  end

  sig { returns(T.nilable(Payment)) }
  def in_progress_payment
    payments.in_progress.first
  end

  sig { returns(T::Boolean) }
  def in_progress_payment?
    in_progress_payment.present?
  end

  sig { returns(BigDecimal) }
  def amount
    total_price
  end

  private

  sig { void }
  def generate_order_number
    self.order_number = SecureRandom.hex(10).upcase
  end

  sig { void }
  def must_have_order_items
    return unless order_items.empty?

    errors.add(:order_items, 'order must have at least one item.')
  end

end
