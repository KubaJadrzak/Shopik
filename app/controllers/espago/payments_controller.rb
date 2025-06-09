# typed: strict

class Espago::PaymentsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!


  sig { void }
  def start_payment
    @payment = T.let(Payment.find_by(payment_number: params[:payment_number]), T.nilable(Payment))
    @card_token = T.let(session.delete(:card_token), T.nilable(String))

    unless @payment
      redirect_to account_path, alert: 'We could not process your payment due to a technical issue'
      return
    end

    response = Espago::Payment::PaymentProcessor.process(payment: @payment, card_token: @card_token)
    Rails.logger.info(response.inspect)

    action, param = Espago::Payment::PaymentResponseHandler.handle_response(@payment, response)

    case action
    when :redirect_url
      redirect_to param, allow_other_host: true
    when :success
      redirect_to espago_payments_success_path(param)
    when :awaiting
      redirect_to espago_payments_awaiting_path(param)
    when :failure
      redirect_to espago_payments_failure_path(param)
    end
  end

  sig { void }
  def payment_success
    @payment = Payment.find_by(payment_number: params[:payment_number])
    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    if @payment.subscription
      @subscription = T.let(@payment.subscription, T.nilable(Subscription))
      redirect_to subscription_path(T.must(@subscription)), notice: 'Payment successful!'
    elsif @payment.order
      @order = T.let(@payment.order, T.nilable(Order))
      redirect_to order_path(T.must(@order)), notice: 'Payment successful!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end

  sig { void }
  def payment_failure
    @payment = Payment.find_by(payment_number: params[:payment_number])
    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    if @payment.subscription
      @subscription = T.let(@payment.subscription, T.nilable(Subscription))
      redirect_to subscription_path(T.must(@subscription)), notice: 'Payment failed!'
    elsif @payment.order
      @order = T.let(@payment.order, T.nilable(Order))
      redirect_to order_path(T.must(@order)), notice: 'Payment failed!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end

  sig { void }
  def payment_awaiting
    @payment = Payment.find_by(payment_number: params[:payment_number])
    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    if @payment.subscription
      @subscription = T.let(@payment.subscription, T.nilable(Subscription))
      redirect_to subscription_path(T.must(@subscription)), notice: 'Payment is being processed!'
    elsif @payment.order
      @order = T.let(@payment.order, T.nilable(Order))
      redirect_to order_path(T.must(@order)), notice: 'Payment is being processed!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end
end
