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

    context '#update_status_by_payment_status' do
      let!(:order) { create(:order) }

      {
        'executed'            => 'Preparing for Shipment',
        'rejected'            => 'Payment Rejected',
        'failed'              => 'Payment Failed',
        'resigned'            => 'Payment Resigned',
        'reversed'            => 'Payment Reversed',
        'preauthorized'       => 'Waiting for Payment',
        'tds2_challenge'      => 'Waiting for Payment',
        'tds_redirected'      => 'Waiting for Payment',
        'dcc_decision'        => 'Waiting for Payment',
        'blik_redirected'     => 'Waiting for Payment',
        'transfer_redirected' => 'Waiting for Payment',
        'new'                 => 'Waiting for Payment',
        'refunded'            => 'Payment Refunded',
        'unknown_status'      => 'Payment Error',
      }.each do |status, payment_status|
        it "updates payment status '#{status}' to status '#{payment_status}'" do
          order.update_status_by_payment_status(status)
          expect(order.payment_status).to eq(status)
          expect(order.status).to eq(payment_status)
        end
      end
    end

  end
end
