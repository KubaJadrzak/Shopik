#frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItemsController, type: :request do

  let(:user) { create(:user) }
  let!(:product) { create(:product) }
  let!(:cart) { user.cart }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product) }

  describe 'POST /cart_items' do


    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        post add_to_cart_path(product.id)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      context 'when product is not in cart' do
        before { cart.cart_items.destroy_all }

        it 'creates a new cart item and responds with turbo stream' do
          expect do
            post add_to_cart_path(product.id), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
          end.to change { cart.cart_items.count }
            .by(1)

          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
          expect(response.body).to include('flash')
          expect(response.body).to include('cart-items-count')
        end

        it 'creates a new cart item and redirects with HTML' do
          expect do
            post add_to_cart_path(product.id)
          end.to change { cart.cart_items.count }
            .by(1)

          expect(response).to redirect_to(products_path)
          follow_redirect!
          expect(response.body).to include("#{product.title} added to cart!")
        end
      end

      context 'when product is already in cart' do
        it 'increments the quantity and responds with turbo stream' do
          expect do
            post add_to_cart_path(product.id), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
          end.not_to(change { cart.cart_items.count })

          expect(cart_item.reload.quantity).to eq(2)
          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
          expect(response.body).to include('flash')
          expect(response.body).to include('cart-items-count')
        end
      end

      context 'when creation fails' do
        before do
          allow_any_instance_of(CartItem).to receive(:save).and_return(false)
          cart.cart_items.destroy_all
        end

        it 'renders flash alert with turbo stream' do
          post add_to_cart_path(product.id), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
          expect(response.body).to include('Failed to add')
        end

        it 'redirects with alert on HTML request' do
          post add_to_cart_path(product.id)
          follow_redirect!
          expect(response.body).to include('Failed to add')
        end
      end
    end
  end

  describe 'DELETE /cart_items/:id' do
    let(:cart_item) { create(:cart_item, cart: cart, product: product) }

    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        delete cart_item_path(cart_item)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      context 'when destroy succeeds' do
        it 'destroys cart item and responds with turbo stream' do
          cart_item # ensure created
          expect do
            delete cart_item_path(cart_item), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
          end.to change { cart.cart_items.count }
            .by(-1)

          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
          expect(response.body).to include("cart_item_#{cart_item.id}")
          expect(response.body).to include('flash')
          expect(response.body).to include('cart_total_price')
          expect(response.body).to include('cart-items-count')
        end

        it 'destroys cart item and redirects with HTML' do
          cart_item
          expect do
            delete cart_item_path(cart_item)
          end.to change { cart.cart_items.count }
            .by(-1)

          expect(response).to redirect_to(cart_path)
          follow_redirect!
          expect(response.body).to include('Cart Item deleted')
        end
      end

      context 'when destroy fails' do
        before do
          allow_any_instance_of(CartItem).to receive(:destroy).and_return(false)
        end

        it 'renders flash alert with turbo stream' do
          delete cart_item_path(cart_item), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
          expect(response.body).to include('Failed to delete Cart Item')
        end

        it 'redirects with alert on HTML request' do
          delete cart_item_path(cart_item)
          follow_redirect!
          expect(response.body).to include('Failed to delete Cart Item')
        end
      end
    end
  end
end
