# typed: strict

class Espago::OneTimePayment::OneTimePaymentPayload
  extend T::Sig

  sig do
    params(
      amount:       BigDecimal,
      currency:     String,
      description:  String,
      positive_url: String,
      negative_url: String,
      card:         T.nilable(String),
      client:       T.nilable(String),
      cof:          T.nilable(String),
    ).void
  end
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

  sig { returns(T::Hash[Symbol, T.untyped]) }
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
