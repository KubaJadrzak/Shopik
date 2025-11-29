# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class StateManager
    #: (response: ::PaymentProcessor::Response) -> void
    def initialize(response:)
      @response = response
    end

    #: -> void
    def process
      @response.payment&.update(
        state:                @response.state,
        espago_payment_id:    @response.espago_payment_id,
        espago_client_id:     @response.espago_client_id,
        reject_reason:        @response.reject_reason,
        issuer_response_code: @response.issuer_response_code,
        behaviour:            @response.behaviour,
        response:             @response.body.to_s,
      )

      payable = @response.payable

      case payable
      when ::Order
        payable.state = ORDER_STATUS_MAP[@response.state] || 'Payment Error'
      when ::Subscription
        payable.state = SUBSCRIPTION_STATUS_MAP[@response.state] || 'Payment Error'
      end

      payable.save
    end

    #: -> void
    def create_client
      nil
    end
  end
end
