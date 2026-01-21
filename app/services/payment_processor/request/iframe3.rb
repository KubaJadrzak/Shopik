# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module Request
    class Iframe3 < Base

      # @override
      #: -> Symbol
      def method
        :post
      end

      # @override
      #: -> Symbol
      def type
        :iframe3
      end

      # @override
      #: -> String
      def url
        'api/charges/init'
      end

      # @override
      #: -> Hash[Symbol, untyped]?
      def request
        {
          amount:      @payment.amount,
          currency:    @payment.currency,
          description: @payment.uuid,
          cof:         @payment.cof,
        }.compact
      end
    end
  end
end
