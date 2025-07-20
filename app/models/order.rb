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
    payments.all?(&:retryable?)
  end

  #: -> BigDecimal
  def amount
    total_price
  end

  private

  #: -> void
  def generate_order_number
    self.order_number = SecureRandom.hex(10).upcase
  end

  #: -> void
  def must_have_order_items
    return unless order_items.empty?

    errors.add(:base, 'order must have at least one item.')
  end

end
