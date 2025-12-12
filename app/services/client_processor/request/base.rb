# typed: strict
# frozen_string_literal: true

module ClientProcessor
  module Request
    # @abstract
    class Base
      extend T::Sig

      #: ::Payment
      attr_reader :payment

      #: ::PaymentProcessor::Response?
      attr_accessor :response

      #: (payment: ::Payment, ?payment_means: String?) -> void
      def initialize(payment:, payment_means: nil)
        @client = payment
      end

      #: -> ::PaymentProcessor::Response
      def process
        response = ::EspagoClient.new.send(url, method: method, body: request)

        response.payment = @payment
        response.type = type
        @response = response
      end

      sig { abstract.returns(String) }
      def url; end

      sig { abstract.returns(Symbol) }
      def method; end

      sig { abstract.returns(Symbol) }
      def type; end

      sig { abstract.returns(T.nilable(T::Hash[Symbol, T.untyped])) }
      def request; end
    end
  end
end
