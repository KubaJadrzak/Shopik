# typed: strict

class Order < ApplicationRecord
  extend T::Sig
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  validates :total_price, presence: true
  validates :status, presence: true
  validates :shipping_address, presence: true
  validates :ordered_at, presence: true
  validate :must_have_order_items

  before_create :generate_order_number

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
