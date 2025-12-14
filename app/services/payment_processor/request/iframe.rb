# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module Request
    class Iframe < Base

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
          amount:       @payment.amount,
          currency:     @payment.currency,
          description:  @payment.uuid,
          positive_url: positive_url,
          negative_url: negative_url,
          card:         @payment_means,
          cof:          @payment.cof,
        }.compact
      end

    end
  end
end
