# frozen_string_literal: true
# typed: strict


class PaymentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_payment, only: %i[new reverse refund success failure awaiting]
  before_action :set_payable, only: %i[new create]

  #: -> void
  def new
    unless @payable
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY') #: String?
  end

  #: -> void
  def create
    unless @payable
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    create_payment
    set_payment_params

    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    result_action, result_param = @payment.process_payment(
      card_token: @card_token,
      cof:        @cof,
    )

    handle_response(result_action, result_param)
  end

  #: -> void
  def reverse
    unless @payment&.reversable?
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    @payment.reverse_payment

    if @payment.reversed?
      redirect_to order_path(@payment.payable), notice: 'Your order was cancelled'
    else
      redirect_to order_path, alert: 'We are experiencing an issue with your payment'
    end
  end

  #: -> void
  def refund
    unless @payment&.refundable?
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end

    @payment.refund_payment

    if @payment.refunded?
      redirect_to order_path(@payment.payable), notice: 'Your order was refunded'
    else
      redirect_to order_path(@payment.payable), alert: 'We are experiencing an issue with your payment'
    end
  end

  #: -> void
  def success

    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end
    handle_redirect(message: 'Payment successful!')
  end

  #: -> void
  def failure
    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end
    handle_redirect(message: 'Payment failed!', alert: true)
  end

  #: -> void
  def awaiting
    unless @payment
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      return
    end
    handle_redirect(message: 'Payment is being processed!', alert: true)
  end

  private

  #: -> void
  def set_payment
    @payment = ::Payment.find_by(uuid: params[:uuid]) #: ::Payment?
  end

  #: -> void
  def set_payable
    payable_number = params[:payable_number]
    if payable_number.start_with?('ord')
      @payable = Order.find_by(uuid: payable_number) #: ::Order? | ::Subscription? | ::Client?
    elsif payable_number.start_with?('sub')
      @payable = Subscription.find_by(uuid: payable_number)
    elsif payable_number.start_with?('cli')
      @payable = Client.find_by(uuid: payable_number)
    end

    nil
  end

  #: -> void
  def create_payment
    @payment = T.must(@payable).payments.create(amount: T.must(@payable).amount, state: 'new')
  end

  #: -> void
  def set_payment_params
    @card_token = params[:card_token] #: String?
    @cof = params[:cof] #: String?
  end

  #: (Symbol, String) -> void
  def handle_response(result_action, result_param)
    case result_action
    when :redirect_url
      redirect_to result_param, allow_other_host: true
    when :success
      redirect_to success_payments_path(result_param)
    when :awaiting
      redirect_to awaiting_payments_path(result_param)
    when :failure
      redirect_to failure_payments_path(result_param)
    end
  end

  #: (message: String, ?alert: bool) -> void
  def handle_redirect(message:, alert: false)
    payment = @payment #: as !nil

    flash_type = alert ? :alert : :notice

    case payment.payable
    when Subscription
      redirect_to subscription_path(payment.payable), flash_type => message
    when Order
      redirect_to order_path(payment.payable), flash_type => message
    when ::Client
      redirect_to verify_client_path(payment.payable), flash_type => message
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
    end
  end
end
