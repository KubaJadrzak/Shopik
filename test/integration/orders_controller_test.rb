# frozen_string_literal: true

require 'test_helper'
require 'vcr'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = FactoryBot.create(:user)
    sign_in @user

    FactoryBot.create(:cart, :with_cart_item, user: @user)
  end

  test 'CREATE should create order, delete cart_items and redirect_to new_payment_path' do
    post orders_path, params: {
      email:            @user.email,
      shipping_address: 'Example Shipping Address',
    }

    assert_redirected_to new_payment_path

  end
end
