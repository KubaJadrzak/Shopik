# frozen_string_literal: true

require 'test_helper'

class FinalizePaymentJobTest < ActiveJob::TestCase
  test 'finalize payment which is executed and last updated more than 1 day ago' do
    payment = FactoryBot.create(:payment, state: 'executed', updated_at: 10.days.ago)
    payable = payment.payable

    FinalizePaymentJob.perform_now

    payment.reload
    payable.reload

    assert_equal 'finalized', payment.state
    assert_equal 'Delivered', payable.state
  end

  test 'does not finalize payment which was updated less than 1 day ago' do
    payment = FactoryBot.create(:payment, state: 'executed', updated_at: Time.current)
    payable = payment.payable

    FinalizePaymentJob.perform_now

    payment.reload
    payable.reload

    assert_equal 'executed', payment.state
    assert_equal 'New', payable.state
  end
end
