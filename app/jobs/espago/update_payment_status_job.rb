class Espago::UpdatePaymentStatusJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    user.orders.where(payment_status: 'new').each do |order|
      next unless order.payment_id.present?

      begin
        status = Espago::PaymentStatusService.new(payment_id: order.payment_id).fetch_payment_status
        order.update_status_by_payment_status(status) if status.present? && status != order.payment_status
      rescue StandardError => e
        Rails.logger.error("Failed to update payment status for order #{order.id}: #{e.message}")
      end
    end
  end
end
