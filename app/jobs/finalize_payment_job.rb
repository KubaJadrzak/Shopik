# typed: strict
# frozen_string_literal: true

class FinalizePaymentJob < ApplicationJob
  queue_as :default

  #: -> void
  def perform
    handle_finalized_payments
  end

  private

  #: -> void
  def handle_finalized_payments
    ::Payment.should_be_finalized.find_each do |payment|
      finalize_payment(payment)
    end
  end

  #: (::Payment) -> void
  def finalize_payment(payment)
    payment.state = 'finalized'
    payable = payment.payable

    case payable
    when ::Order
      payable.state = ORDER_STATUS_MAP['finalized'] || 'Payment Error'
    when ::Subscription
      payable.state = SUBSCRIPTION_STATUS_MAP['finalized'] || 'Payment Error'
    end

    payable.save(validate: false) && payment.save(validate: false)
  end
end
