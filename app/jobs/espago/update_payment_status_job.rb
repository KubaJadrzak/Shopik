# typed: strict

class Espago::UpdatePaymentStatusJob < ApplicationJob
  extend T::Sig
  queue_as :default

  sig { params(user_id: Integer).void }
  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    user.orders.where(status: 'Awaiting Payment').each do |order|
      if order.created_at < 120.minutes.ago
        order.update_status_by_payment_status('failed')
      end
    end

    user.orders.where(status: ['New', 'Waiting for Payment']).each do |order|
      unless order.payment_id.present?
        order.update_status_by_payment_status('unexpected_error')
        next
      end

      new_status = Espago::PaymentStatusService
                   .new(payment_id: T.must(order.payment_id))
                   .fetch_payment_status

      if new_status.present? && new_status != order.payment_status
        order.update_status_by_payment_status(new_status)
      elsif order.created_at < 120.minutes.ago
        order.update_status_by_payment_status('resigned')
      end
    end

  end
end
