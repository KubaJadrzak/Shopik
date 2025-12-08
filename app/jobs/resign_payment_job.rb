# typed: strict
# frozen_string_literal: true

class ResignPaymentJob < ApplicationJob
  queue_as :default

  #: (Integer) -> void
  def perform(user_id)
    @user = User.find(user_id) #: ::User?
    return unless @user

    handle_resigned_payments
  end

  private

  #: -> void
  def handle_resigned_payments
    return unless @user

    # Fix for weird sorbet behaviour,
    # missing method awaiting on ActiveRecord::Relation
    payments = @user.payments #: as untyped


    payments.should_be_resigned.find_each do |payment|
      payment.state = 'resigned'
      payment.payable.state = 'Payment Resigned'

      payment.payable.save(validate: false) && payment.save(validate: false)
    end
  end
end
