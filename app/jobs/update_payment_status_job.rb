# typed: strict
# frozen_string_literal: true

class UpdatePaymentStatusJob < ApplicationJob
  queue_as :default

  #: -> void
  def perform
    handle_awaiting_payments
  end

  private

  #: -> void
  def handle_awaiting_payments
    ::Payment.should_be_checked.find_each do |payment|
      ::PaymentProcessor::Check.new(payment).process
    end
  end
end
