# frozen_string_literal: true
# typed: strict

module Espago
  class UpdatePaymentStatusJob < ApplicationJob
    queue_as :default

    #: (Integer) -> void
    def perform(user_id)
      user = User.find_by(id: user_id)
      return unless user

      handle_awaiting_payments(user)
    end

    private

    #: (User) -> void
    def handle_awaiting_payments(user)
      ::Payment.awaiting.where(id: user.payments.select(:id)).find_each do |payment|
        if payment.uncertain?
          payment.update_payment_and_payable_statuses('failed') if payment.created_at < 120.minutes.ago
        elsif payment.pending?
          unless payment.payment_id.present?
            payment.update_payment_and_payable_statuses('unexpected_error')
            next
          end
          update_payment_status(payment)
        end
      end
    end

    #: (::Payment) -> void
    def update_payment_status(payment)
      payment_id = payment.payment_id #: as !nil
      new_status = Espago::Payment::StatusService.new(payment_id: payment_id).fetch_payment_status

      if new_status.present? && new_status != payment.state
        payment.update_payment_and_payable_statuses(new_status)
      elsif payment.created_at < 120.minutes.ago
        payment.update_payment_and_payable_statuses('resigned')
      end
    end
  end
end
