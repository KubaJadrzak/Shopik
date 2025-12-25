# frozen_string_literal: true

require 'test_helper'

class RenewSubscriptionJobTest < ActiveJob::TestCase
  test 'renew subscription when previous subscription is expired and user has primary saved payment method' do
    user = FactoryBot.create(:user, auto_renew: true)
    FactoryBot.create(:saved_payment_method, primary: true, user: user)
    FactoryBot.create(:subscription, state: 'Expired', user: user)

    assert_difference -> { Subscription.count }, 1 do
      VCR.use_cassette('renew subscription when previous subscription is expired and user has primary saved payment method') do
        RenewSubscriptionJob.perform_now
      end
    end

    old_subscription = ::Subscription.last

    assert_equal 'Active', old_subscription.state
  end

  test 'does not renew subscription when user does not have previous expired subscription' do
    user = FactoryBot.create(:user, auto_renew: true)
    FactoryBot.create(:saved_payment_method, primary: true, user: user)
    FactoryBot.create(:subscription, state: 'Active', user: user)

    assert_difference -> { Subscription.count }, 0 do
      RenewSubscriptionJob.perform_now
    end

    new_subscription = ::Subscription.last

    assert_equal 'Active', new_subscription.state
  end

  test 'does not renew subscription when user does not have primary saved payment method' do
    user = FactoryBot.create(:user, auto_renew: true)
    FactoryBot.create(:saved_payment_method, primary: false, user: user)
    FactoryBot.create(:subscription, state: 'Expired', user: user)

    assert_difference -> { Subscription.count }, 0 do
      RenewSubscriptionJob.perform_now
    end

    old_subscription = ::Subscription.last

    assert_equal 'Expired', old_subscription.state
  end
end
