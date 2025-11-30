# frozen_string_literal: true
# typed: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:account]

  def account
    @user = current_user
    @section = params[:section] || 'orders'

    @subscriptions = current_user.subscriptions.order(created_at: :desc)
    case @section
    when 'orders'
      @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)
    when 'subscriptions'
    when 'clients'
      @clients = current_user.clients.order(created_at: :desc)
    else
      @section = 'orders'
      @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)
    end

    UpdatePaymentStatusJob.perform_later(current_user.id)
    FinalizePaymentJob.perform_later(current_user.id)
  end
end
