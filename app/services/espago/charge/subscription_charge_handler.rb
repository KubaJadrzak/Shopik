class Espago::Charge::SubscriptionChargeHandler
  def initialize(charge, card_token)
    @charge = charge
    @card_token = card_token
  end

  def process
    unless @card_token
      return Espago::Response.new(
        success: false,
        status:  :missing_card_token,
        body:    { 'error' => 'Missing card token for subscription charge' },
      )
    end

    payload = Espago::OneTimePayment::OneTimePaymentPayload.new(
      amount:       @charge.amount,
      currency:     'pln',
      card:         @card_token,
      cof:          'storing',
      description:  "Charge ##{@charge.charge_number} for Subscription ##{@charge.subscription.subscription_number}",
      positive_url: Rails.application.routes.url_helpers.espago_charge_success_url(charge_number: @charge.charge_number),
      negative_url: Rails.application.routes.url_helpers.espago_charge_failure_url(charge_number: @charge.charge_number),
    )

    Espago::OneTimePayment::OneTimePaymentService.new(payload: payload).create_payment
  end
end
