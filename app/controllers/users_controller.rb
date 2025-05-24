# typed: true

class UsersController < ApplicationController

  before_action :authenticate_user!, only: [:account]

  def account
    @user = current_user

    @rubits = current_user
              .rubits
              .root_rubits
              .includes(:user, :likes, :likes_by_users, :parent_rubit)
              .order(created_at: :desc)

    @liked_rubits = current_user
                    .liked_rubits.includes(:user, :likes, :likes_by_users, :parent_rubit)
                    .order(created_at: :desc)

    @comments = current_user
                .rubits
                .child_rubits
                .includes(:user, :likes, :likes_by_users, :parent_rubit)
                .order(created_at: :desc)

    @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)

    @orders.each do |order|
      next unless order.payment_id.present? && order.payment_status == 'new'

      begin
        status = Espago::PaymentStatusService.new(payment_id: order.payment_id).fetch_payment_status
        order.update_status_by_payment_status(status) if status.present? && status != order.payment_status
      rescue StandardError => e
        Rails.logger.error("Failed to update payment status for order #{order.id}: #{e.message}")
      end
    end
  end
end
