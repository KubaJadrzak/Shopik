# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class Check
    #: (::Payment) -> void
    def initialize(payment)
      @payment = payment
    end

    #: -> PaymentProcessor::Response
    def process
      request = Request::Check.new(payment: @payment)

      response = request.process

      StateManager.new(response).process

      response
    end
  end
end
