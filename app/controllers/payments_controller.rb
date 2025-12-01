# frozen_string_literal: true
# typed: strict


class PaymentsController < ApplicationController
  include PaymentErrors

  before_action :authenticate_user!
  before_action :set_payment, only: %i[show reverse refund success rejected pending]
  before_action :set_payable, only: %i[new create]

  #: -> void
  def new
    raise payment_error! unless @payable

    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY') #: String?
  end

  #: -> void
  def show
    @payment
  end

  #: -> void
  def create
    byebug
    raise payment_error! unless @payable

    set_payment_params
    raise payment_error! unless create_payment

    @response = charge_payment #: PaymentProcessor::Response?

    handle_response
  end

  #: -> void
  def reverse
    raise payment_error! unless @payment&.reversable?

    @response = ::PaymentProcessor::Reverse.new(@payment).process

    handle_response
  end

  #: -> void
  def refund
    raise payment_error! unless @payment&.refundable?

    @response = ::PaymentProcessor::Refund.new(@payment).process

    handle_response
  end

  #: -> void
  def success
    handle_final_redirect(message: 'Payment successful!')
  end

  #: -> void
  def pending
    handle_final_redirect(message: 'Payment is being processed!', alert: true)
  end

  #: -> void
  def rejected
    handle_final_redirect(message: 'Payment rejected!', alert: true)
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

  #: -> PaymentProcessor::Response
  def charge_payment
    raise payment_error! unless @payment

    T.must(PaymentProcessor::Charge.new(
      payment:       @payment,
      payment_means: set_payment_means,
    ).process)
  end

  #: -> String?
  def set_payment_means
    params[:card_token]
  end

  #: -> void
  def handle_response
    raise payment_error! unless @response

    return redirect_to @response.redirect_url, allow_other_host: true if @response.redirect?

    if @response.success?
      handle_final_redirect(message: 'Payment successful!')
    elsif @response.pending?
      handle_final_redirect(message: 'Payment is being processed!', alert: true)
    elsif @response.rejected? || @response.failure?
      handle_final_redirect(message: 'Payment rejected!', alert: true)
    elsif @response.uncertain?
      handle_final_redirect(message: 'We are experiencing an issue with your payment', alert: true)
    else
      raise !payment_error!
    end
  end

  #: (message: String, ?alert: bool) -> void
  def handle_final_redirect(message:, alert: false)
    raise payment_error! unless @payment

    flash_type = alert ? :alert : :notice

    redirect_to polymorphic_path(@payment.payable), flash_type => message
  end
end
