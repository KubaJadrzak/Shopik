# typed: strict
# frozen_string_literal: true

module ClientProcessor
  class Delete

    #: (::SavedPaymentMethod) -> void
    def initialize(saved_payment_methods)
      @saved_payment_methods = saved_payment_methods
    end

    #: -> ::ClientProcessor::Response
    def process
      request = Request::Delete.new(@saved_payment_methods)

      response = request.process

      StateManager.new(response).process

      response
    end
  end
end
