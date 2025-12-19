# frozen_string_literal: true

require 'test_helper'
require 'vcr'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  test 'CREATE should create order, delete cart_items and redirect_to new_payment_path' do
    FactoryBot.create(:cart, :with_cart_item, user: @user)
    post orders_path, params: {
      order: {
        email:            @user.email,
        shipping_address: 'Example Shipping Address',
      },
    }

    order = ::Order.first
    assert_redirected_to new_payment_path(payable_number: order.uuid)

    assert_equal 10.00, order.amount
    assert order.order_items.first.title
    assert_empty @user.cart_items
    assert_equal 0.0, @user.cart.total_price
  end

  test 'CREATE should raise redirect_to account_path and show alert if cart is empty' do
    FactoryBot.create(:cart, user: @user)
    post orders_path, params: {
      order: {
        email:            @user.email,
        shipping_address: 'Example Shipping Address',
      },
    }

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your Order!', flash[:alert]
  end

  test 'RETRY_PAYMENT should redirect_to new_payment_path' do
    order = FactoryBot.create(:order, user: @user, state: 'Payment Resigned')
    FactoryBot.create(:payment, payable: order, state: 'resigned')

    post retry_payment_order_path(order)

    assert_redirected_to new_payment_path(payable_number: order.uuid)
  end

  test 'RETRY_PAYMENT should raise redirect_to account_path and show alert if order cannot be retried' do
    order = FactoryBot.create(:order, user: @user)
    FactoryBot.create(:payment, payable: order)
    post retry_payment_order_path(order)

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your Order!', flash[:alert]
  end

  test 'CANCEL should raise redirect_to account_path and show alert if order cannot be cancelled' do
    order = FactoryBot.create(:order, user: @user)
    FactoryBot.create(:payment, payable: order)
    get cancel_order_path(order)

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your Order!', flash[:alert]
  end

  test 'RETURN should raise redirect_to account_path and show alert if order cannot be returned' do
    order = FactoryBot.create(:order, user: @user)
    FactoryBot.create(:payment, payable: order)
    get return_order_path(order)

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your Order!', flash[:alert]
  end
end
