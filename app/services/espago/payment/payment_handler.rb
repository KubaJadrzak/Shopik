# typed: strict

class Espago::Payment::PaymentHandler
  extend T::Sig

  sig do
    params(
      payment:    Payment,
      card_token: T.nilable(String),
      cof:        T.nilable(String),
    ).void
  end
  def initialize(payment, card_token, cof)
    @payment = payment
    @card_token = card_token
    @cof = cof
  end

  sig { returns(Espago::Response) }
  def handle_payment
    description = "Payment ##{@payment.payment_number}"
    description += ' - storing' if @cof == 'storing'
    if @card_token
      payload = Espago::OneTimePayment::OneTimePaymentPayload.new(
        amount:       @payment.amount,
        currency:     'PLN',
        card:         @card_token,
        description:  description,
        positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
        negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number),
      )
      Espago::OneTimePayment::OneTimePaymentService.new(payload: payload).create_payment
    else
      payload = Espago::SecureWebPage::SecureWebPagePayload.new(
        amount:       @payment.amount,
        currency:     'PLN',
        kind:         'sale',
        title:        description,
        description:  description,
        positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
        negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number),
      )
      Espago::SecureWebPage::SecureWebPageService.new(payload: payload).create_payment
    end
  end
end
