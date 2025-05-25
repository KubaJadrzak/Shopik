require 'rails_helper'

RSpec.describe 'Orders Requests Test', type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  before do
    user.cart.cart_items.create!(product: product, quantity: 1)
  end

  describe 'GET /orders/new' do
    context 'when user is authorized' do
      before do
        sign_in user
      end
      it 'returns success if cart has items' do
        get new_order_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Place Order')
      end

      it 'redirects to cart page if cart is empty' do
        user.cart.cart_items.destroy_all
        get new_order_path
        expect(response).to redirect_to(cart_path)
      end
    end

    context 'when user is not authorized' do
      it 'redirects to sign in page' do
        get new_order_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /orders' do

    let(:valid_params) do
      {
        order: {
          email:            user.email,
          shipping_address: '123 Test Street',
        },
      }
    end
    context 'when user is authorized' do
      before do
        sign_in user
      end
      it 'creates a new order and redirects to payment' do
        post orders_path, params: valid_params
        order = Order.last
        expect(response).to redirect_to(espago_secure_web_page_start_payment_path(order))
        expect(order.email).to eq(user.email)
        expect(order.order_items.count).to eq(1)
        expect(user.cart.cart_items.count).to eq(0)
      end

      it 'renders :new with errors if order is invalid' do
        invalid_params = { order: { email: '', shipping_address: '' } }
        post orders_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('There was a problem placing your order')
      end

      it 'redirects to cart if cart is empty' do
        user.cart.cart_items.destroy_all
        post orders_path, params: valid_params
        expect(response).to redirect_to(cart_path)
      end
    end
    context 'when user is not authorized' do
      it 'redirects to sign in page' do
        get new_order_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /orders/:id' do
    context 'when user is authorized' do
      before do
        sign_in user
      end
      it 'shows the order if it exists' do
        order = create(:order, user: user)
        get order_path(order)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(order.order_number)
      end

      it 'redirects to root with alert if order not found' do
        get order_path(99999)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('Record not found')
      end
    end
    context 'when user is not authorized' do
      it 'redirects to sign in page' do
        get new_order_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
