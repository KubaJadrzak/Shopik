# frozen_string_literal: true
# typed: strict


class PaymentsController < ApplicationController
  include PaymentErrors

  before_action :authenticate_user!
  before_action :set_payment, only: %i[reverse refund success failure awaiting]
  before_action :set_payable, only: %i[new create]

  #: -> void
  def new
    raise payment_error! unless @payable

    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY') #: String?
  end

  #: -> void
  def create
    raise payment_error! unless @payable

    set_payment_params
    raise payment_error! unless create_payment && update_payable

    byebug
    response = charge_payment

    p response
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
    @payment = Payment.find_by(uuid: params[:uuid]) #: ::Payment?
  end

  #: -> void
  def set_payable
    payable_number = params[:payable_number]
    if payable_number.start_with?('ord')
      @payable = Order.find_by(uuid: payable_number) #: ::Order? | ::Subscription?
    elsif payable_number.start_with?('sub')
      @payable = Subscription.find_by(uuid: payable_number)
    else
      raise payment_error!
    end
  end

  #: -> void
  def set_payment_params
    raise payment_error! unless @payable

    @amount = @payable.amount #: BigDecimal?
    @cof = set_cof #: Symbol?
    @payment_method = set_payment_method #: Symbol | void
  end

  #: -> Symbol?
  def set_cof
    case params[:cof] # rubocop:disable Style/HashLikeCase
    when 'storing'
      :storing
    when 'recurring'
      :recurring
    when 'unscheduled'
      :unscheduled
    end
  end

  #: -> Symbol | void
  def set_payment_method
    case params[:payment_method]
    when 'iframe'
      :iframe
    when 'secure_web_page'
      :secure_web_page
    when 'iframe3'
      :iframe3
    when 'meest_paywall'
      :meest_paywall
    when 'google_pay'
      :google_pay
    when 'apple_pay'
      :apple_pay
    else
      raise payment_error!
    end
  end

  #: -> bool
  def create_payment
    raise payment_error! unless @payable

    @payment = @payable.payments.create(
      amount:         @amount,
      state:          'new',
      cof:            @cof,
      payment_method: @payment_method,
      currency:       'PLN',
      kind:           :sale,
    )

    @payment.persisted?
  end

  #: -> bool
  def update_payable
    raise payment_error! unless @payable

    @payable.state = 'Payment in Progress'
    @payable.save
  end

  #: -> void
  def charge_payment
    raise payment_error! unless @payment

    PaymentProcessor::Charge.new(
      payment:       @payment,
      payment_means: set_charge_means,
    ).process
  end

  #: -> String?
  def set_charge_means
    params[:card_token]
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
