# typed: strict

class Espago::UpdatePaymentStatusJob < ApplicationJob
  extend T::Sig
  queue_as :default

  sig { params(user_id: Integer).void }
  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    user.orders.where(payment_status: 'new').each do |order|
      return order.update_status_by_payment_status('unexpected_error') unless order.payment_id.present?

      begin
        status = Espago::PaymentStatusService.new(payment_id: T.must(order.payment_id)).fetch_payment_status
        if status.present? && status != order.payment_status
          order.update_status_by_payment_status(status)
        elsif order.created_at < 90.minutes.ago
          order.update_status_by_payment_status('resigned')
        end
      rescue StandardError => e
        Rails.logger.error("Failed to update payment status for order #{order.id}: #{e.message}")
      end
    end
  end
end
