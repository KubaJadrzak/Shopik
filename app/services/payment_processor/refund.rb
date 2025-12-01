# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class Refund
    #: (::Payment) -> void
    def initialize(payment)
      @payment = payment
    end

    #: -> PaymentProcessor::Response?
    def process
      request = Request::Refund.new(payment: @payment)

      response = request.process

      PaymentProcessor::StateManager.new(response).process

      response
    end
  end
end
