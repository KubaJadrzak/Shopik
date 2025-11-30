# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module StateManager
    class Reverse < Base

      # @override
      #: -> void
      def update_payment
        attrs = {
          state:    @response.state,
          response: @response.body.to_s,
        }

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
