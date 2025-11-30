# typed: strict
# frozen_string_literal: true



class UpdatePaymentStatusJob < ApplicationJob
  queue_as :default

  #: (Integer) -> void
  def perform(user_id)
    @user = User.find_by(id: user_id) #: ::User?
    return unless @user

    handle_awaiting_payments
  end

  private

  #: -> void
  def handle_awaiting_payments
    return unless @user

    @user.payments.awaiting.find_each do |payment|
      ::PaymentProcessor::Check.new(payment).process
    end
  end
end
