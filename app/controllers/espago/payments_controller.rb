class Espago::PaymentsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!


  def start_payment
    @payment = Payment.find_by(payment_number: params[:payment_number])
    @card_token = session.delete(:card_token)

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

  def payment_success
    @payment = Payment.find_by(payment_number: params[:payment_number])

    if @payment&.subscription
      @subscription = @payment.subscription
      redirect_to subscription_path(@subscription), notice: 'Payment successful!'
    elsif @payment&.order
      @order = @payment.order
      redirect_to order_path(@order), notice: 'Payment successful!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end

  def payment_failure
    @payment = Payment.find_by(payment_number: params[:payment_number])

    if @payment&.subscription
      @subscription = @payment.subscription
      redirect_to subscription_path(@subscription), alert: 'Payment failed!'
    elsif @payment&.order
      @order = @payment.order
      redirect_to order_path(@order), alert: 'Payment failed!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end

  def payment_awaiting
    @payment = Payment.find_by(payment_number: params[:payment_number])

    if @payment&.subscription
      @subscription = @payment.subscription
      redirect_to subscription_path(@subscription), alert: 'Payment is being processed!'
    elsif @payment&.order
      @order = @payment.order
      redirect_to order_path(@order), alert: 'Payment is being processed!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end
end
