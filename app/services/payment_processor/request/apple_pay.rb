# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module Request
    class ApplePay < Base

      # @override
      #: -> Symbol
      def method
        :post
      end

      # @override
      #: -> Symbol
      def type
        :charge
      end

      # @override
      #: -> String
      def url
        'api/charges'
      end

      # @override
      #: -> Hash[Symbol, untyped]
      def request
        {
          channel:      'elavon_apple_pay',
          amount:       @payment.amount,
          currency:     @payment.currency,
          description:  @payment.uuid,
          positive_url: positive_url,
          negative_url: negative_url,
          apple_pay:    @payment_means,
        }.compact
      end

    end
  end
end
