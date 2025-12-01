# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class Charge

    #: (payment: ::Payment, ?payment_means: String?) -> void
    def initialize(payment:, payment_means: nil)
      @payment = payment
      @payment_means = payment_means
      @payment_method = payment.payment_method #: String
    end

    #: -> PaymentProcessor::Response?
    def process
      request = build_request

      response = request.process

      PaymentProcessor::StateManager.new(response).process

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
  end
end
