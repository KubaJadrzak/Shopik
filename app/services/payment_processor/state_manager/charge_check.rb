# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module StateManager
    class ChargeCheck < Base

      # @override
      #: -> void
      def update_payment
        espago_payment_id = @response.espago_payment_id
        espago_client_id = @response.espago_client_id

        attrs = {
          state:                @response.state,
          reject_reason:        @response.reject_reason,
          issuer_response_code: @response.issuer_response_code,
          behaviour:            @response.behaviour,
          response:             @response.body.to_s,
        }
        attrs[:espago_payment_id] = espago_payment_id if espago_payment_id
        attrs[:espago_client_id] = espago_client_id if espago_client_id

        @response.payment&.update(attrs)
      end

      # @override
      #: -> void
      def update_payable
        payable = @response.payable

        case payable
        when ::Order
          payable.state = ORDER_STATUS_MAP[@response.state] || 'Payment Error'
        when ::Subscription
          payable.state = SUBSCRIPTION_STATUS_MAP[@response.state] || 'Payment Error'
        end

        payable.save
      end

    end
  end
end
