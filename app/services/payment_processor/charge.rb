# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class Charge

    #: (payment: Payment, ?payment_means: String?) -> void
    def initialize(payment:, payment_means: nil)
      @payment = payment
      @payment_means = payment_means
      @payment_method = payment.payment_method #: String
    end

    #: -> PaymentProcessor::Response
    def process
      request = build_request

      response = request.perform #: PaymentProcessor::Response

      update_payment_and_payable(response)
      create_client if @payment.storing? && response.success?

      response
    end

    private

    #: -> Request::Base
    def build_request
      case @payment_method
      when 'iframe'
        Request::Iframe.new(payment: @payment, payment_means: @payment_means)
      else
        Request::SecureWebPage.new(payment: @payment)
      end
    end

    #: (PaymentProcessor::Response) -> void
    def update_payment_and_payable(response)
      @payment.update(
        state:                response.state,
        espago_payment_id:    response.espago_payment_id,
        espago_client_id:     response.espago_client_id,
        reject_reason:        response.reject_reason,
        issuer_response_code: response.issuer_response_code,
        behaviour:            response.behaviour,
        response:             response.body.to_s,
      )

      payable = @payment.payable

      case payable
      when Order
        payable.state = ORDER_STATUS_MAP[response.state] || 'Unknown'
      when Subscription
        payable.state = SUBSCRIPTION_STATUS_MAP[response.state] || 'Unknown'
      end

      payable.save
    end

    #: -> void
    def create_client
      nil
    end
  end
end
