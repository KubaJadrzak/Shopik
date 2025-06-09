class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: [:show]

  def new
    @subscription = Subscription.new
    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY', nil)
  end

  def show
  end

  def create
    if current_user.has_active_subscription?
      redirect_to "#{account_path}#subscriptions", alert: 'You already have an active subscription.'
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

  private

  def set_subscription
    @subscription = Subscription.find_by!(id: params[:id])
  end

end
