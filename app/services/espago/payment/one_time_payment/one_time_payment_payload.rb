# frozen_string_literal: true
# typed: strict

module Espago
  module Payment
    module OneTimePayment
      class OneTimePaymentPayload

        #: (amount: BigDecimal, currency: String, description: String, positive_url: String, negative_url: String, ?card: String?, ?client: String?, ?cof: String?) -> void
        def initialize(amount:, currency:, description:, positive_url:, negative_url:, card: nil, client: nil, cof: nil)
          @amount = amount
          @currency = currency
          @description = description
          @positive_url = positive_url
          @negative_url = negative_url
          @card = card
          @client = client
          @cof = cof
        end

        #: -> Hash[Symbol, untyped]
        def to_h
          {
            amount:       @amount,
            currency:     @currency,
            description:  @description,
            positive_url: @positive_url,
            negative_url: @negative_url,
            card:         @card,
            client:       @client,
            cof:          @cof,
          }.compact
        end
      end
    end
  end
end
