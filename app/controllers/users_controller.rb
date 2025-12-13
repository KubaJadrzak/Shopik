# frozen_string_literal: true
# typed: strict

class UsersController < ApplicationController
  include GenericErrors

  before_action :authenticate_user!, only: [:account]

  #: -> void
  def account
    @user = current_user #: ::User?
    @section = params[:section] || 'orders' #: String?

    case @section
    when 'orders'
      @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc) #: ::ActiveRecord::Relation?
    when 'subscriptions'
      @subscriptions = current_user.subscriptions.order(created_at: :desc) #: ::ActiveRecord::Relation?
    when 'clients'
      @clients = current_user.clients.order(created_at: :desc) #: ::ActiveRecord::Relation?
    else
      @section = 'orders'
      @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)
    end

    UpdatePaymentStatusJob.perform_now
    FinalizePaymentJob.perform_now
    ResignPaymentJob.perform_now
    ResignOrderJob.perform_now
    ExpireSubscriptionJob.perform_now
  end

  #: -> void
  def toggle_auto_renew
    raise generic_error! unless current_user.can_toggle_auto_renew?

    current_value = current_user.auto_renew
    current_user.update(auto_renew: !current_value)
  end
end
