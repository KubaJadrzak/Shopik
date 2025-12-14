# typed: strict
# frozen_string_literal: true

module ClientProcessor
  class StateManager
    #: (::ClientProcessor::Response) -> void
    def initialize(response)
      @response = response
      @type = response.type #: Symbol?
      @saved_payment_methods = response.saved_payment_methods #: ::SavedPaymentMethod?
    end

    #: -> void
    def process
      authorize_client if @type == :authorize
    end

    #: -> void
    def authorize_client
      return unless @saved_payment_methods && @response.communication_success?

      @saved_payment_methods.state = 'MIT Verified'
      @saved_payment_methods.save(validate: false)
    end
  end
end
