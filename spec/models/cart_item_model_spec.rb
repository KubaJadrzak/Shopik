require 'rails_helper'

RSpec.describe CartItem, type: :model do

  describe 'methods' do
    context '#total_price' do
      let(:user) { create(:user) }
      let(:cart) { user.cart }
      let(:product) { create(:product, price: 21) }
      let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }
      it 'calculates correct total price for order item' do
        expect(cart_item.total_price).to eq(42.00)
      end
    end
  end
end
