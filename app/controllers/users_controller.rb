# frozen_string_literal: true
# typed: true

class UsersController < ApplicationController

  before_action :authenticate_user!, only: [:account]

  def account
    @user = current_user

    @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)

    @subscriptions = current_user.subscriptions.order(created_at: :desc)

    @clients = current_user.clients.order(created_at: :desc)

    Espago::UpdatePaymentStatusJob.perform_later(current_user.id)
  end
end
