# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module Request
    class Saved_Payment_Method < Base

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
          amount:                @payment.amount,
          currency:              @payment.currency,
          description:           @payment.uuid,
          positive_url:          positive_url,
          negative_url:          negative_url,
          saved_payment_methods: @payment_means,
          cof:                   @payment.cof,
        }.compact
      end

    end
  end
end
