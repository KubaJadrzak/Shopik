# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class Reverse
    #: (::Payment) -> void
    def initialize(payment)
      @payment = payment
    end

    #: -> PaymentProcessor::Response
    def process
      response = Request::Reverse.new(payment: @payment).process

      StateManager::RefundReverse.new(response).process

      response
    end
  end
end
