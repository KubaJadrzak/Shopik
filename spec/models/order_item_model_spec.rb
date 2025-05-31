require 'rails_helper'

RSpec.describe OrderItem, type: :model do

  describe 'methods' do
    context '#total_price' do
      let(:order) { create(:order) }
      let(:product) { create(:product, price: 21) }
      let(:order_item) { create(:order_item, order: order, product: product, quantity: 2) }
      it 'calculates correct total price for order item' do
        expect(order_item.total_price).to eq(42.00)
      end
    end
  end
end
