# typed: strict
# frozen_string_literal: true


class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: %i[show retry_payment]
  before_action :set_payments, only: [:show]

  #: -> void
  def new
    @subscription = Subscription.new #: ::Subscription?
  end

  #: -> void
  def show
    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY', nil) #: String?
  end

  #: -> void
  def create
    if current_user.active_subscription?
      redirect_to "#{account_path}#subscriptions", alert: 'You already have an active subscription.'
      return
    elsif current_user.pending_subscription?
      redirect_to "#{account_path}#subscriptions", alert: 'You already have a pending subscription.'
      return
    end

    @subscription = current_user.subscriptions.new(state: 'new')

    if @subscription.save
      redirect_to new_payment_path(payable_number: @subscription.uuid)
    else
      flash.now[:alert] = 'There was a problem with your subscription.'
      render :new, status: :unprocessable_entity
    end
  end

  #: -> void
  def retry_payment
    unless T.must(@subscription).can_retry_payment?
      redirect_to subscription_path(@subscription),
                  alert: 'Cannot retry payment: payment already in progress or successful.'
      return
    end
    redirect_to new_payment_path(payable_number: T.must(@subscription).uuid)
  end

  private

  #: -> ::Subscription?
  def set_subscription
    @subscription = Subscription.find_by(uuid: params[:uuid])
  end

  #: -> ActiveRecord::Relation?
  def set_payments
    @payments = @subscription&.payments #: ActiveRecord::Relation?
  end

end
