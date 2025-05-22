class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true
  validates :price_at_purchase, presence: true
  validates :shipping_address, presence: true

  def total_price
    pricee * quantity
  end

end
