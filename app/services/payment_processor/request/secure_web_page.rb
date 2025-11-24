# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module Request
    class SecureWebPage < Base
      #: (payment: ::Payment, ?payment_means: String?) -> void
      def initialize(payment:, payment_means: nil)
        super
        @session_id = SecureRandom.hex(16) #: String
        @amount = @payment.amount #: BigDecimal
        @currency = @payment.currency #: String
        @kind = @payment.kind.to_s #: String
        @uuid = @payment.uuid #: String
      end

      # @override
      #: -> Symbol
      def method
        :post
      end

      # @override
      #: -> String
      def url
        'api/secure_web_page_register'
      end

      # @override
      #: -> Hash[Symbol, untyped]
      def request
        {
          amount:       @amount,
          currency:     @currency,
          kind:         @kind,
          title:        @uuid,
          description:  @uuid,
          positive_url: positive_url,
          negative_url: negative_url,
          session_id:   @session_id,
          checksum:     checksum,
          cof:          @payment.cof,
        }.compact
      end

      #: -> String
      def checksum
        ts = Time.now.to_i #: Integer
        app_id = Rails.application.credentials.dig(:espago, :app_id) #: String
        checksum_key = Rails.application.credentials.dig(:espago, :checksum_key) #: String
        raw_string = "#{app_id}#{@kind}#{@session_id}#{@amount}#{@currency}#{ts}#{checksum_key}"
        Digest::MD5.hexdigest(raw_string) #: String
      end

    end
  end
end
