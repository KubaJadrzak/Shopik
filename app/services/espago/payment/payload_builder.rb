# frozen_string_literal: true
# typed: strict

module Espago
  module Payment
    class PayloadBuilder
      #: (payment: ::Payment, ?description: String?, ?cof: String?, ?card_token: String?, ?client_id: String?) -> void
      def initialize(
        payment:,
        description: nil,
        cof: nil,
        card_token: nil,
        client_id: nil
      )
        @payment = payment
        @amount = payment.amount #: BigDecimal
        @description = description
        @cof = cof
        @card = card_token
        @client = client_id

        @kind = 'sale' #: String
        @currency = 'PLN' #: String
        @title = description
        @session_id = SecureRandom.hex(16) #: String
      end

      #: -> Hash[Symbol, untyped]
      def one_time_payment
        {
          amount:       @amount,
          currency:     @currency,
          description:  @description,
          positive_url: positive_url,
          negative_url: negative_url,
          card:         @card,
          client:       @client,
          cof:          @cof,
        }.compact
      end

      #: -> Hash[Symbol, untyped]
      def secure_web_payment
        {
          amount:       @amount,
          currency:     @currency,
          kind:         @kind,
          title:        @title,
          description:  @description,
          positive_url: positive_url,
          negative_url: negative_url,
          session_id:   @session_id,
          checksum:     checksum,
          cof:          @cof,
        }.compact
      end

      #: -> String
      def positive_url
        Rails.application
             .routes
             .url_helpers
             .espago_payments_success_url(payment_number: @payment.payment_number)
      end

      #: -> String
      def negative_url
        Rails.application
             .routes
             .url_helpers
             .espago_payments_failure_url(payment_number: @payment.payment_number)
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
