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
          positive_url: positive_url,
          negative_url: negative_url,
          card:         @charge_means,
          client:       @payment.client,
          cof:          @payment.cof,
        }.compact
      end

    end
  end
end
