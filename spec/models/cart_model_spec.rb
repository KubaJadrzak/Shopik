require 'rails_helper'

RSpec.describe Cart, type: :model do

  describe 'methods' do
    context '#total_price' do
      let(:user) { create(:user) }
      let(:cart) { user.cart }
      let(:product) { create(:product, price: 3) }
      let(:other_product) { create(:product, price: 7) }
      let!(:cart_item) { create(:cart_item, product: product, quantity: 2, cart: cart) }
      let!(:other_cart_item) { create(:cart_item, product: other_product, quantity: 1, cart: cart) }
      it 'calculates price of all cart items' do
        expect(cart.total_price).to eq(13.00)
      end
    end
  end

end
