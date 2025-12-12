# typed: strict
# frozen_string_literal: true

module PaymentProcessor
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
        @payment = payment
        @payment_means = payment_means
        @response = nil
      end

      #: -> ::PaymentProcessor::Response
      def process
        base = ::EspagoClient.new.send(url, method: method, body: request)
        response = PaymentProcessor::Response.build(base)

        response.payment = @payment
        response.type = type
        @response = response
      end

      #:  -> String
      def positive_url
        Rails.application
             .routes
             .url_helpers
             .success_payment_url(uuid: @payment.uuid)
      end

      #: -> String
      def negative_url
        Rails.application
             .routes
             .url_helpers
             .rejected_payment_url(uuid: @payment.uuid)
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
