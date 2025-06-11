# typed: strict

class Espago::PaymentsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!
  before_action :set_payment, only: %i[
    new start_payment payment_success payment_failure payment_awaiting
  ]

  sig { void }

  def new
    if params[:order_id]
      @parent = Order.find(params[:order_id])
    elsif params[:subscription_id]
      @parent = Subscription.find(params[:subscription_id])
    else
      redirect_to root_path, alert: 'Missing order or subscription to create payment.' and return
    end

    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY', nil)
  end
  sig { void }
  def start_payment

    parent_type = params[:parent_type]
    parent_id = params[:parent_id]
    @parent = parent_type.constantize.find_by(id: parent_id)
    unless @parent
      redirect_to account_path, alert: 'We could not create your payment due to a technical issue'
      return
    end
    @payment = @parent.payments.create(amount: @parent.amount, state: 'new')
    unless @payment.persisted?
      redirect_to account_path, alert: 'We could not create your payment due to a technical issue'
      return
    end


    @card_token = T.let(session.delete(:card_token), T.nilable(String))


    begin
      @payment.update_status_by_payment_status(@payment.state)
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to update payment state: #{e.message}")
      redirect_to account_path, alert: 'We could not process your payment due to a technical issue'
      return
    end

    response = Espago::Payment::PaymentInitializer.initilize(payment: @payment, card_token: @card_token)
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
    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    case @payment.payable
    when Subscription
      redirect_to subscription_path(@payment.payable), notice: 'Payment successful!'
    when Order
      redirect_to order_path(@payment.payable), notice: 'Payment successful!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end

  sig { void }
  def payment_failure
    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    case @payment.payable
    when Subscription
      redirect_to subscription_path(@payment.payable), notice: 'Payment failed!'
    when Order
      redirect_to order_path(@payment.payable), notice: 'Payment failed!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end

  sig { void }
  def payment_awaiting
    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    case @payment.payable
    when Subscription
      redirect_to subscription_path(@payment.payable), notice: 'Payment is being processed!'
    when Order
      redirect_to order_path(@payment.payable), notice: 'Payment is being processed!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end

  private

  sig { void }
  def set_payment
    @payment = T.let(Payment.find_by(payment_number: params[:payment_number]), T.nilable(Payment))
  end
end
