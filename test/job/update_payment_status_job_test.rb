# frozen_string_literal: true

require 'test_helper'

class UpdatePaymentStatusJobTest < ActiveJob::TestCase
  test 'update payment status' do
    payment = FactoryBot.create(:payment, state: 'new', espago_payment_id: 'pay_9d0vezjGTyA9iUYd')
    payable = payment.payable

    VCR.use_cassette('update payment status') do
      UpdatePaymentStatusJob.perform_now
    end

    payment.reload
    payable.reload

    assert_equal 'executed', payment.state
    assert_equal 'Preparing for Shipment', payable.state
  end
end
