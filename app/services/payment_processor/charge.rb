# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class Charge

    #: (payment: Payment, ?charge_means: String?) -> void
    def initialize(payment:, charge_means: nil)
      @payment = payment
      @charge_means = charge_means
      @payment_method = payment.payment_method #: String
    end

    #: -> void
    def process
      request = build_request

      request.perform
    end

    #: -> Request::Base
    def build_request
      case @payment_method
      when 'iframe'
        Request::Iframe.new(payment: @payment, charge_means: @charge_means)
      else
        Request::SecureWebPage.new(payment: @payment)
      end
    end
  end
end
