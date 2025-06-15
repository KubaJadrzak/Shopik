require 'rails_helper'

RSpec.describe Order, type: :model do

  describe 'validations' do
    let(:user) { create(:user) }
    context 'when order has no order items' do
      it 'order cannot be created' do
        order = build(:order, user: user)
        order.order_items = []
        order.valid?

        expect(order.errors[:order_items]).to include('order must have at least one item.')
      end
    end
  end

  describe 'callbacks' do
    context 'when order is created' do
      let(:user) { create(:user) }
      let(:order) { create(:order, user: user) }
      it 'generates an order number before creation' do
        expect(order.order_number).to_not be_nil
      end
    end
  end

  describe 'methods' do
    context '#build_order_items_from_cart' do
      let(:user) { create(:user) }

      it 'creates order items based on cart items' do
        order = build(:order, user: user)
        order.order_items = []
        cart_items = create_list(:cart_item, 2, cart: user.cart)

        order.build_order_items_from_cart(user.cart)
        order.save!

        expect(order.order_items.map(&:product_id)).to match_array(cart_items.map(&:product_id))
      end
    end

    describe '#can_retry_payment?' do
      let(:order) { create(:order) }

      context 'when all payments are retryable' do
        before do
          create_list(:payment, 2, :for_order, payable: order, state: 'failed')
        end

        it 'returns true' do
          expect(order.can_retry_payment?).to be true
        end
      end

      context 'when at least one payment is not retryable' do
        before do
          create(:payment, :for_order, payable: order, state: 'failed')
          create(:payment, :for_order, payable: order, state: 'new')
        end

        it 'returns false' do
          expect(order.can_retry_payment?).to be false
        end
      end
    end


  end
end
