# typed: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: %i[show retry_payment extend_subscription]

  def new
    @subscription = Subscription.new
    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY', nil)
    @espago_clients = current_user.espago_clients
  end

  def show
    @payments = @subscription.payments
    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY', nil)
  end

  def create
    if current_user.active_subscription?
      redirect_to "#{account_path}#subscriptions", alert: 'You already have an active subscription.'
      return
    elsif current_user.pending_subscription?
      redirect_to "#{account_path}#subscriptions", alert: 'You already have a pending subscription.'
      return
    end

    Rails.logger.info("Card token: #{params[:card_token]}")
    @subscription = current_user.subscriptions.new(status: 'New')



    if @subscription.save && params[:card_token]
      @payment = @subscription.payments.create!(amount: @subscription.price)
      session[:card_token] = params[:card_token]
      redirect_to espago_start_payment_path(@payment.payment_number)
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
    @payment = @subscription.payments.create!(amount: @subscription.price)
    session[:card_token] = params[:card_token]
    redirect_to espago_start_payment_path(@payment.payment_number)
  end

  def extend_subscription
    unless @subscription.can_extend_subscription?
      redirect_to subscription_path(@subscription),
                  alert: 'Cannot extend subscription: payment already in progress or not Active'
      return
    end

    @payment = @subscription.payments.create!(amount: @subscription.price)
    session[:card_token] = params[:card_token]
    redirect_to espago_start_payment_path(@payment.payment_number)
  end

  private

  def set_subscription
    @subscription = Subscription.find_by!(id: params[:id])
  end

end
