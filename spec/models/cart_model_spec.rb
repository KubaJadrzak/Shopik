require 'rails_helper'

RSpec.describe Cart, type: :model do

  describe 'methods' do
    context 'total_price' do
      it 'calculates price of all cart items' do
        user = create(:user)
        cart = user.cart
        product = create(:product, price: 3)
        other_product = create(:product, price: 7)
        create(:cart_item, product: product, quantity: 2, cart: cart)
        create(:cart_item, product: other_product, quantity: 1, cart: cart)

        expect(cart.total_price).to eq(13.00)
      end
    end
  end

end
