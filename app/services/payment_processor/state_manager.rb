# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class StateManager

    #: (::PaymentProcessor::Response) -> void
    def initialize(response)
      @response = response
      @type = response.type #: Symbol?
      @payment = response.payment #: ::Payment?
      @payable = @payment&.payable #: ::Order? | ::Subscription? | ::Client?
    end

    #: -> void
    def process
      return unless  @type && @payment && @payable

      update_payable

      @payment.state = @response.state
      @payment.response = @response.body.to_s

      case @type
      when :charge, :check
        handle_charge_and_check
      end

      @payment.save
    end

    #: -> void
    def handle_charge_and_check
      return unless  @payment

      espago_payment_id = @response.espago_payment_id
      espago_client_id = @response.espago_client_id

      attrs = {
        reject_reason:        @response.reject_reason,
        issuer_response_code: @response.issuer_response_code,
        behaviour:            @response.behaviour,
      }
      attrs[:espago_payment_id] = espago_payment_id if espago_payment_id
      attrs[:espago_client_id] = espago_client_id if espago_client_id

      @payment.update(attrs)
    end

    #: -> void
    def update_payable
      return unless @payable

      case @payable
      when ::Order
        @payable.state = ORDER_STATUS_MAP[@response.state] || 'Payment Error'
      when ::Subscription
        @payable.state = SUBSCRIPTION_STATUS_MAP[@response.state] || 'Payment Error'
      end

      @payable.save
    end
  end
end
