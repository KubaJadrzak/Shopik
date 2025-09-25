# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do

  describe 'methods' do
    context 'total_price' do
      it 'calculates correct total price for order item' do
        order = create(:order)
        product = create(:product, price: 21)
        order_item = create(:order_item, order: order, product: product, quantity: 2)
        expect(order_item.total_price).to eq(42.00)
      end
    end
  end
end
