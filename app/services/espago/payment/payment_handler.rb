# typed: strict

class Espago::Payment::PaymentHandler
  extend T::Sig

  sig do
    params(
      payment:    Payment,
      card_token: T.nilable(String),
      cof:        T.nilable(String),
      client_id:  T.nilable(String),
    ).void
  end
  def initialize(payment:, card_token: nil, cof: nil, client_id: nil)
    @payment = payment
    @card_token = card_token
    @cof = cof
    @client_id = client_id
  end

  sig { returns(Espago::Response) }
  def handle_payment
    description = "Payment ##{@payment.payment_number}"
    description += ' - storing' if @cof == 'storing'
    description += ' - CIT' if @client_id

    if @card_token || @client_id
      attrs = {
        amount:       @payment.amount,
        currency:     'PLN',
        description:  description,
        positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
        negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number),
      }
      attrs[:cof] = @cof if @cof.present?
      attrs[:card] = @card_token if @card_token.present?
      attrs[:client] = @client_id if @client_id.present?

      payload = Espago::OneTimePayment::OneTimePaymentPayload.new(**attrs)
      Espago::OneTimePayment::OneTimePaymentService.new(payload: payload).create_payment
    else
      attrs = {
        amount:       @payment.amount,
        currency:     'PLN',
        kind:         'sale',
        title:        description,
        description:  description,
        positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
        negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number),
      }
      attrs[:cof] = @cof if @cof.present?

      payload = Espago::SecureWebPage::SecureWebPagePayload.new(**attrs)
      Espago::SecureWebPage::SecureWebPageService.new(payload: payload).create_payment
    end
  end

end
