# frozen_string_literal: true

require 'test_helper'

class ExpireSubscriptionJobTest < ActiveJob::TestCase
  test 'expire subscription when end date is in the past' do
    subscription = FactoryBot.create(:subscription, state: 'Active', end_date: Date.current - 1.day)

    ExpireSubscriptionJob.perform_now

    subscription.reload

    assert_equal 'Expired', subscription.state
  end

  test 'does not expire subscription when end date is in the future' do
    subscription = FactoryBot.create(:subscription, state: 'Active', end_date: Date.current + 1.day)

    ExpireSubscriptionJob.perform_now

    subscription.reload

    assert_equal 'Active', subscription.state
  end
end
