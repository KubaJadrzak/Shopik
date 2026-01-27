# typed: strict
# frozen_string_literal: true

# @requires_ancestor: ApplicationController
module Paymentable
  include Errors::PaymentErrors

  #: PaymentProcessor::Response?
  attr_accessor :payment_response

  private

  #: -> void
  def set_payment
    @payment = Payment.find_by(uuid: params[:uuid]) #: ::Payment?
  end

  #: -> void
  def set_payable
    payable_number = params[:payable_number]
    raise payment_error! unless payable_number.present?

    if payable_number.start_with?('ord')
      @payable = Order.find_by(uuid: payable_number) #: ::Order? | ::Subscription?
    elsif payable_number.start_with?('sub')
      @payable = Subscription.find_by(uuid: payable_number)
    else
      raise payment_error!
    end
  end

  #: -> void
  def set_saved_payment_methods
    @saved_payment_methods = current_user.saved_payment_methods #: ::ActiveRecord::Relation?
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
    raise payment_error! unless params[:payment_method]

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
    when ->(v) { v.start_with?('cli') }
      :cit
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
    ) #: ::Payment?

    raise payment_error! unless @payment

    @payment.persisted?
  end

  #: -> PaymentProcessor::Response?
  def charge_payment
    raise payment_error! unless @payment

    PaymentProcessor::Charge.new(
      payment:       @payment,
      payment_means: set_payment_means,
    ).process
  end

  #: -> (String | Hash[Symbol, String])?
  def set_payment_means
    return params[:card_token] if params[:card_token]

    return params[:payment_method] if params[:payment_method].starts_with?('cli')

    return google_pay_payload if params[:payment_method] == 'google_pay'

    apple_pay_payload if params[:payment_method] == 'apple_pay'
  end

  #: (String) -> void
  def handle_response(subject)
    raise payment_error! unless @payment_response.present?

    return redirect_to iframe3_payment_path(@payment) if @payment_response.iframe3?

    return redirect_to @payment_response.redirect_url, allow_other_host: true if @payment_response.redirect?

    if @payment_response.success?
      handle_final_redirect(message: "#{subject.capitalize} successful!")
    elsif @payment_response.pending?
      handle_final_redirect(message: "#{subject.capitalize} is being processed!", alert: true)
    elsif @payment_response.rejected? || @payment_response.failure?
      handle_final_redirect(message: "#{subject.capitalize} rejected!", alert: true)
    elsif @payment_response.uncertain?
      handle_final_redirect(message: "We are experiencing an issue with your #{subject}!", alert: true)
    else
      raise payment_error!
    end
  end

  #: (message: String, ?alert: bool) -> void
  def handle_final_redirect(message:, alert: false)
    raise payment_error! unless @payment

    check_payment

    flash_type = alert ? :alert : :notice

    redirect_to polymorphic_path(@payment.payable), flash_type => message
  end

  #: -> PaymentProcessor::Response
  def check_payment
    raise payment_error! unless @payment

    PaymentProcessor::Check.new(@payment).process
  end

  #: -> String?
  def espago_public_key
    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY') #: String?
  end

  #: -> Hash[Symbol, String]
  def google_pay_payload
    {
      authMethod:      'PAN_ONLY',
      pan:             '4111111111111111',
      expirationYear:  1.year.from_now,
      expirationMonth: 1,
    }
  end

  #: -> Hash[Symbol, String]
  def apple_pay_payload
    expiration_date = 1.year.from_now.strftime('%y%m%d')

    {
      applicationPrimaryAccountNumber: '4012000000020006',
      applicationExpirationDate:       expiration_date,
      onlinePaymentCryptogram:         'p0OLurz61yKfROy808cg+FqXnCQ=',
      eciIndicator:                    '05',
    }
  end

end
