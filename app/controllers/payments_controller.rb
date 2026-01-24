# frozen_string_literal: true
# typed: strict

class PaymentsController < ApplicationController
  include Errors::PaymentErrors
  include Paymentable

  before_action :authenticate_user!
  before_action :set_payment, only: %i[show reverse refund success rejected pending]
  before_action :set_payable, only: %i[new create]
  before_action :set_saved_payment_methods, only: %i[new]

  #: -> void
  def new
    raise payment_error! unless @payable

    @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY') #: String?
  end

  #: -> void
  def show; end

  #: -> void
  def iframe3
    @payment = ::Payment.find_by(espago_payment_id: params[:espago_payment_id])
  end

  #: -> void
  def create
    raise payment_error! unless @payable

    set_payment_params

    raise payment_error! unless create_payment

    @payment_response = charge_payment #: PaymentProcessor::Response?

    handle_response('payment')
  end

  #: -> void
  def reverse
    raise payment_error! unless @payment&.reversable?

    @payment_response = ::PaymentProcessor::Reverse.new(@payment).process #: PaymentProcessor::Response?

    handle_response('Cancellation')
  end

  #: -> void
  def refund
    raise payment_error! unless @payment&.refundable?

    @payment_response = ::PaymentProcessor::Refund.new(@payment).process #: PaymentProcessor::Response?

    handle_response('Return')
  end

  #: -> void
  def iframe3_callback
    @payment = ::Payment.find_by(espago_payment_id: params[:espago_payment_id])
    raise payment_error! unless @payment

    @payment_response = check_payment #: PaymentProcessor::Response?

    handle_response('payment')
  end


  private

  #: -> void
  def set_payment
    @payment = Payment.find_by(uuid: params[:uuid]) #: ::Payment?
  end

  # @override
  #: -> bot
  def paymentable_error!
    payment_error!
  end

end
