# typed: strict

class Espago::UpdatePaymentStatusJob < ApplicationJob
  extend T::Sig
  queue_as :default

  sig { params(user_id: Integer).void }
  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    Payment.awaiting.where(id: user.payments.select(:id)).find_each do |payment|
      if payment.uncertain?
        if payment.created_at < 120.minutes.ago
          payment.update_status_by_payment_status('failed')
        end
      elsif payment.pending?
        unless payment.payment_id.present?
          payment.update_status_by_payment_status('unexpected_error')
          next
        end

        new_status = Espago::PaymentStatusService.new(payment_id: T.must(payment.payment_id)).fetch_payment_status

        if new_status.present? && new_status != payment.state
          payment.update_status_by_payment_status(new_status)
        elsif payment.created_at < 120.minutes.ago
          payment.update_status_by_payment_status('resigned')
        end
      end
    end
  end
end
