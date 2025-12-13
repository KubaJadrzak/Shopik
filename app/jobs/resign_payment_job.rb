# typed: strict
# frozen_string_literal: true

class ResignPaymentJob < ApplicationJob
  queue_as :default

  #: -> void
  def perform
    handle_resigned_payments
  end

  private

  #: -> void
  def handle_resigned_payments
    ::Payment.should_be_resigned.find_each do |payment|
      payment.state = 'resigned'
      payment.payable.state = 'Payment Resigned'

      payment.payable.save(validate: false) && payment.save(validate: false)
    end
  end
end
