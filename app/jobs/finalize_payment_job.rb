# typed: strict
# frozen_string_literal: true

class FinalizePaymentJob < ApplicationJob
  queue_as :default

  #: (Integer) -> void
  def perform(user_id)
    @user = User.find(user_id) #: ::User?
    return unless @user

    handle_finalized_payments
  end

  private

  #: -> void
  def handle_finalized_payments
    return unless @user

    # Fix for sorbet behaviour,
    # missing method awaiting on ActiveRecord::Relation
    payments = @user.payments #: as untyped

    payments.should_be_finalized.find_each do |payment|
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
