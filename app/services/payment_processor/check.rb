# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class Check
    #: (::Payment) -> void
    def initialize(payment)
      @payment = payment
    end

    #: -> void
    def process
      response = Request::Check.new(payment: @payment).process

      StateManager::ChargeCheck.new(response).process
    end
  end
end
