#frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartsController, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  let!(:product) { create(:product) }
  let!(:other_product) { create(:product, title: 'Other Product Title') }

  let!(:cart_item) { create(:cart_item, cart: user.cart, product: product) }
  let!(:other_cart_item) { create(:cart_item, cart: other_user.cart, product: other_product) }

  describe 'GET /cart' do
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        get cart_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      it 'shows the user’s cart with associated cart items' do
        get cart_path

        expect(response).to have_http_status(:ok)

        expect(response.body).to include(cart_item.product.title)
        expect(response.body).not_to include(other_cart_item.product.title)
      end
    end
  end
end
