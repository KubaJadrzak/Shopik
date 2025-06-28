# typed: strict

module Espago
  module Payment
    module SecureWebPage
      class SecureWebPagePayload

        #: (amount: BigDecimal, currency: String, kind: String, title: String, description: String, positive_url: String, negative_url: String, ?cof: String?) -> void
        def initialize(amount:, currency:, kind:, title:, description:, positive_url:, negative_url:, cof: nil)
          @amount = amount
          @currency = currency
          @kind = kind
          @title = title
          @description = description
          @positive_url = positive_url
          @negative_url = negative_url
          @cof = cof

          @session_id = SecureRandom.hex(16) #: String
          @ts = Time.now.to_i #: Integer

          app_id = Rails.application.credentials.dig(:espago, :app_id) #: String
          checksum_key = Rails.application.credentials.dig(:espago, :checksum_key) #: String
          raw_string = "#{app_id}#{@kind}#{@session_id}#{@amount}#{@currency}#{@ts}#{checksum_key}"
          @checksum = Digest::MD5.hexdigest(raw_string) #: String
        end

        #: -> Hash[Symbol, untyped]
        def to_h
          {
            amount:       @amount,
            currency:     @currency,
            kind:         @kind,
            title:        @title,
            description:  @description,
            positive_url: @positive_url,
            negative_url: @negative_url,
            session_id:   @session_id,
            checksum:     @checksum,
            cof:          @cof,
          }.compact
        end
      end
    end
  end
end
