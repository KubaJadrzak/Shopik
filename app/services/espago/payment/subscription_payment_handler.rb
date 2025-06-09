# typed: strict

class Espago::Payment::SubscriptionPaymentHandler
  extend T::Sig

  sig { params(payment: Payment, card_token: T.nilable(String)).void }
  def initialize(payment, card_token)
    @payment = payment
    @card_token = card_token
  end

  sig { returns(Espago::Response) }
  def process
    unless @card_token
      return Espago::Response.new(
        success: false,
        status:  :missing_card_token,
        body:    { 'error' => 'Missing card token for subscription payment' },
      )
    end

    payload = Espago::OneTimePayment::OneTimePaymentPayload.new(
      amount:       @payment.amount,
      currency:     'pln',
      card:         @card_token,
      cof:          'storing',
      description:  "Payment ##{@payment.payment_number}",
      positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
      negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number),
    )

    Espago::OneTimePayment::OneTimePaymentService.new(payload: payload).create_payment
  end

end
