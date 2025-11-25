# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module Request
    # @abstract
    class Base
      extend T::Sig

      #: (payment: ::Payment, ?payment_means: String?) -> void
      def initialize(payment:, payment_means: nil)
        @payment = payment
        @payment_means = payment_means
      end

      #: -> ::PaymentProcessor::Response
      def perform
        ::EspagoClient.new.send(url, method: method, body: request)
      end

      #:  -> String
      def positive_url
        Rails.application
             .routes
             .url_helpers
             .success_payments_url(uuid: @payment.uuid)
      end

      #: -> String
      def negative_url
        Rails.application
             .routes
             .url_helpers
             .rejected_payments_url(uuid: @payment.uuid)
      end

      sig { abstract.returns(String) }
      def url; end

      sig { abstract.returns(Symbol) }
      def method; end

      sig { abstract.returns(T::Hash[Symbol, T.untyped]) }
      def request; end
    end
  end
end
