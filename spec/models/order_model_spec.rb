#frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do

  describe 'validations' do
    context 'must_have_order_items' do
      it 'ensures that order has order items' do
        order = build(:order)
        order.order_items = []
        order.valid?

        expect(order.errors[:base]).to include('order must have at least one item.')
      end
    end
  end

  describe 'callbacks' do
    context 'generate_order_number' do
      it 'generates an order number before creation' do
        order = create(:order)
        expect(order.order_number).to_not be_nil
      end
    end
  end

  describe 'methods' do
    context 'build_order_items_from_cart' do
      it 'creates order items from cart items and removes cart items' do
        user = create(:user)
        order = build(:order, user: user)
        order.order_items = []
        cart_items = create_list(:cart_item, 2, cart: user.cart)

        order.build_order_items_from_cart(user.cart)
        order.save!

        expect(order.order_items.map(&:product_id)).to match_array(cart_items.map(&:product_id))
        expect(user.cart.cart_items).to match_array([])
      end
    end


    context 'can_retry_payment?' do
      let(:order) { create(:order) }

      it 'returns true when all payments are retryable' do
        create_list(:payment, 2, :for_order, payable: order, state: 'failed')
        expect(order.can_retry_payment?).to be true
      end

      it 'returns false when at least one payment is not retryable' do
        create(:payment, :for_order, payable: order, state: 'failed')
        create(:payment, :for_order, payable: order, state: 'new')

        expect(order.can_retry_payment?).to be false
      end
    end


  end
end
