# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module Request
    class Check < Base
      # @override
      #: -> Symbol
      def method
        :get
      end

      # @override
      #: -> Symbol
      def type
        :check
      end

      # @override
      #: -> String
      def url
        "api/charges/#{@payment.espago_payment_id}"
      end

      # @override
      #: -> Hash[Symbol, untyped]?
      def request
        nil
      end
    end
  end
end
