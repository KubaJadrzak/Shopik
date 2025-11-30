# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class Refund
    #: (::Payment) -> void
    def initialize(payment)
      @payment = payment
    end

    #: -> PaymentProcessor::Response
    def process
      response = Request::Refund.new(payment: @payment).process

      StateManager::Refund.new(response).process

      response
    end
  end
end
