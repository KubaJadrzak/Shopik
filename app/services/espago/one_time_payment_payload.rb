# typed: strict

class Espago::OneTimePaymentPayload
  extend T::Sig

  sig do
    params(
      amount:       BigDecimal,
      currency:     String,
      card:         String,
      description:  String,
      positive_url: T.nilable(String),
      negative_url: T.nilable(String),
      cof:          T.nilable(String),
    ).void
  end
  def initialize(amount:, currency:, card:, description:, positive_url: nil, negative_url: nil, cof: nil)
    @amount = amount
    @currency = currency
    @card = card
    @description = description
    @positive_url = positive_url
    @negative_url = negative_url
    @cof = cof
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def to_h
    {
      amount:      @amount,
      currency:    @currency,
      card:        @card,
      description: @description,
    }.tap do |hash|
      hash[:positive_url] = @positive_url if @positive_url
      hash[:negative_url] = @negative_url if @negative_url
      hash[:cof] = @cof if @cof
    end
  end
end
