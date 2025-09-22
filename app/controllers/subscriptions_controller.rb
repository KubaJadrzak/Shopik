# frozen_string_literal: true
# typed: false

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: %i[show toggle_auto_renew retry_payment extend_subscription]

  def new
    @subscription = Subscription.new
  end

  def show
    @payments = @subscription.payments
    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY', nil)
  end

  def toggle_auto_renew
    unless @subscription.active?
      redirect_to "#{account_path}#subscriptions", alert: 'This subscription is not active'
      return
    end

    unless @subscription.user.primary_payment_method?
      redirect_to "#{account_path}#subscriptions", alert: 'Cannot enable auto-renew without primary payment method'
      return
    end

    @subscription.update(auto_renew: !@subscription.auto_renew)
  end

  def create
    if current_user.active_subscription?
      redirect_to "#{account_path}#subscriptions", alert: 'You already have an active subscription.'
      return
    elsif current_user.pending_subscription?
      redirect_to "#{account_path}#subscriptions", alert: 'You already have a pending subscription.'
      return
    end

    @subscription = current_user.subscriptions.new(status: 'New')

    if @subscription.save
      redirect_to espago_new_payment_path(subscription_id: @subscription.id)
    else
      flash.now[:alert] = 'There was a problem with your subscription.'
      render :new, status: :unprocessable_entity
    end
  end

  def retry_payment
    unless @subscription.can_retry_payment?
      redirect_to subscription_path(@subscription),
                  alert: 'Cannot retry payment: payment already in progress or successful.'
      return
    end
    redirect_to espago_new_payment_path(subscription_id: @subscription.id)
  end

  def extend_subscription
    unless @subscription.can_extend_subscription?
      redirect_to subscription_path(@subscription),
                  alert: 'Cannot extend subscription: payment already in progress or subscription is not Active'
      return
    end

    redirect_to espago_new_payment_path(subscription_id: @subscription.id)
  end

  private

  def set_subscription
    @subscription = Subscription.find_by!(id: params[:id])
  end

end
