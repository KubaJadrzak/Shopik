# frozen_string_literal: true

require 'test_helper'
require 'vcr'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  test 'CREATE should create subscription and redirect_to new_payment_path' do
    post subscriptions_path

    subscription = ::Subscription.first

    assert_equal 'New', subscription.state
    assert_equal @user, subscription.user

    assert_redirected_to new_payment_path(payable_number: subscription.uuid)
  end

  test 'CREATE should raise redirect_to account_path and show alert if user have an active subscription' do
    FactoryBot.create(:subscription, user: @user, state: 'Active')
    post subscriptions_path

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your subscription!', flash[:alert]
  end

  test 'CREATE should raise redirect_to account_path and show alert if user have a pending subscription' do
    FactoryBot.create(:subscription, user: @user, state: 'Payment in Progress')
    post subscriptions_path

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your subscription!', flash[:alert]
  end

  test 'RETRY_PAYMENT should redirect_to new_payment_path with existing subscription' do
    subscription = FactoryBot.create(:subscription, user: @user, state: 'Payment Resigned')
    post retry_payment_subscription_path(subscription)

    assert_redirected_to new_payment_path(payable_number: subscription.uuid)
  end

  test 'RETRY_PAYMENT should raise redirect_to account_path and show alert if payment for subscription cannot be retried' do
    subscription = FactoryBot.create(:subscription, user: @user, state: 'Active')
    FactoryBot.create(:payment, state: 'executed', payable: subscription)
    subscription.reload

    post retry_payment_subscription_path(subscription)

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your subscription!', flash[:alert]
  end

end
