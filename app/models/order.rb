class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  validates :total_price, presence: true
  validates :status, presence: true
  validates :ordered_at, presence: true
  validate :must_have_order_items

  before_create :generate_order_number

  def build_order_items_from_cart(cart)
    cart.cart_items.each do |cart_item|
      order_items.build(
        product:           cart_item.product,
        quantity:          cart_item.quantity,
        price_at_purchase: cart_item.price,
      )
    end
  end

  def user_facing_payment_status
    case payment_status
    when 'executed'
      'Paid'
    when 'rejected', 'failed', 'connection failed'
      'Failed'
    when 'resigned'
      'Resigned'
    when 'reversed'
      'Reversed'
    when 'preauthorized', 'tds2_challenge', 'tds_redirected', 'dcc_decision', 'blik_redirected', 'transfer_redirected', 'new'
      'Awaiting Confirmation'
    when 'refunded'
      'Refunded'
    when 'Processing'
      'Processing'
    else
      'Unkown'
    end
  end

  private

  def must_have_order_items
    return unless order_items.empty?

    errors.add(:order_items, 'must have at least one item.')

  end

  def generate_order_number
    self.order_number = SecureRandom.hex(10).upcase
  end
end
