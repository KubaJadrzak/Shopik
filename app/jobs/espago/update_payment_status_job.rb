# typed: strict

module Espago
  class UpdatePaymentStatusJob < ApplicationJob
    extend T::Sig
    queue_as :default

    sig { params(user_id: Integer).void }
    def perform(user_id)
      user = User.find_by(id: user_id)
      return unless user

      handle_awaiting_payments(user)

    end

    private

    def handle_awaiting_payments(user)
      ::Payment.awaiting.where(id: user.payments.select(:id)).find_each do |payment|
        if payment.uncertain?
          payment.update_status_by_payment_status('failed') if payment.created_at < 120.minutes.ago
        elsif payment.pending?
          unless payment.payment_id.present?
            payment.update_status_by_payment_status('unexpected_error')
            next
          end
          update_payment_status(payment)
        end
      end
    end

    def update_payment_status(payment)
      new_status = Espago::Payment::PaymentStatusService.new(payment_id: payment.payment_id).fetch_payment_status

      if new_status.present? && new_status != payment.state
        payment.update_status_by_payment_status(new_status)
      elsif payment.created_at < 120.minutes.ago
        payment.update_status_by_payment_status('resigned')
      end
    end
  end
end
