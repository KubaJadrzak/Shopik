require 'rails_helper'

RSpec.describe CartItem, type: :model do

  describe 'methods' do
    context 'total_price' do
      it 'calculates correct total price for order item' do
        user = create(:user)
        cart = user.cart
        product = create(:product, price: 21)
        cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)

        expect(cart_item.total_price).to eq(42.00)
      end
    end
  end
end
