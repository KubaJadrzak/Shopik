# frozen_string_literal: true

require 'test_helper'

class ResignOrderJobTest < ActiveJob::TestCase
  test 'resign order which does not have payment and last updated more than 1 day ago' do
    order = FactoryBot.create(:order, updated_at: 10.days.ago)

    ResignOrderJob.perform_now

    order.reload

    assert_equal 'Payment Resigned', order.state
  end

  test 'does not resign order that has payment' do
    order = FactoryBot.create(:order)
    FactoryBot.create(:payment, payable: order)

    ResignOrderJob.perform_now

    order.reload

    assert_equal 'New', order.state
  end
end
