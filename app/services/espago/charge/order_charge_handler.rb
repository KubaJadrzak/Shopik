class Espago::Charge::OrderChargeHandler
  def initialize(charge, card_token)
    @charge = charge
    @card_token = card_token
  end

  def process
    payload = if @card_token
                Espago::OneTimePayment::OneTimePaymentPayload.new(
                  amount:       @charge.amount,
                  currency:     'pln',
                  card:         @card_token,
                  description:  "Charge ##{@charge.charge_number} for Order ##{@charge.order.order_number}",
                  positive_url: Rails.application.routes.url_helpers.espago_charge_success_url(charge_number: @charge.charge_number),
                  negative_url: Rails.application.routes.url_helpers.espago_charge_failure_url(charge_number: @charge.charge_number),
                )
              else
                Espago::SecureWebPage::SecureWebPagePayload.new(
                  amount:       @charge.order.total_price,
                  currency:     'PLN',
                  kind:         'sale',
                  title:        "Charge ##{@charge.charge_number} for Order ##{@charge.order.order_number}",
                  description:  "Charge ##{@charge.charge_number} for Order ##{@charge.order.order_number}",
                  positive_url: Rails.application.routes.url_helpers.espago_charge_success_url(charge_number: @charge.charge_number),
                  negative_url: Rails.application.routes.url_helpers.espago_charge_failure_url(charge_number: @charge.charge_number),
                )
              end

    service = @card_token ? Espago::OneTimePayment::OneTimePaymentService : Espago::SecureWebPage::SecureWebPageService
    service.new(payload: payload).create_payment
  end
end
