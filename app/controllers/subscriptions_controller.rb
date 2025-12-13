# typed: strict
# frozen_string_literal: true


class SubscriptionsController < ApplicationController
  include SubscriptionErrors

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
    raise subscription_error! if current_user.active_subscription? || current_user.pending_subscription?

    @subscription = current_user.subscriptions.new(state: 'New')

    raise subscription_error! unless @subscription.save

    redirect_to new_payment_path(payable_number: @subscription.uuid)
  end

  #: -> void
  def retry_payment
    raise subscription_error! unless @subscription&.can_retry_payment?

    redirect_to new_payment_path(payable_number: @subscription.uuid)
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
