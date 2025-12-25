# frozen_string_literal: true

require 'test_helper'

class ResignPaymentJobTest < ActiveJob::TestCase
  test 'resign payments which should be resigned' do
    payment = FactoryBot.create(:payment, state: 'new', updated_at: 1.day.ago)
    payable = payment.payable

    ResignPaymentJob.perform_now

    payment.reload
    payable.reload

    assert_equal 'resigned', payment.state
    assert_equal 'Payment Resigned', payable.state
  end

  test 'does not resign payments which should not be resigned' do
    payment = FactoryBot.create(:payment, state: 'new', updated_at: Time.current)
    payable = payment.payable

    ResignPaymentJob.perform_now

    payment.reload
    payable.reload

    assert_equal 'new', payment.state
    assert_equal 'New', payable.state
  end
end
