class Espago::Payment::OrderPaymentHandler
  def initialize(payment, card_token)
    @payment = payment
    @card_token = card_token
  end

  def process
    payload = if @card_token
                Espago::OneTimePayment::OneTimePaymentPayload.new(
                  amount:       @payment.amount,
                  currency:     'pln',
                  card:         @card_token,
                  description:  "Payment ##{@payment.payment_number}",
                  positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
                  negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number),
                )
              else
                Espago::SecureWebPage::SecureWebPagePayload.new(
                  amount:       @payment.order.total_price,
                  currency:     'PLN',
                  kind:         'sale',
                  title:        "Payment ##{@payment.payment_number}",
                  description:  "Payment ##{@payment.payment_number}",
                  positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
                  negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number),
                )
              end

    service = @card_token ? Espago::OneTimePayment::OneTimePaymentService : Espago::SecureWebPage::SecureWebPageService
    service.new(payload: payload).create_payment
  end
end
