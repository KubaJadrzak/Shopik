class Espago::Charge::ChargeProcessor



  def self.process(charge:, card_token:)
    if charge.subscription.present?
      Espago::Charge::SubscriptionChargeHandler.new(charge, card_token).process
    elsif charge.order.present?
      Espago::Charge::OrderChargeHandler.new(charge, card_token).process
    else
      Espago::Response.new(
        success: false,
        status:  :missing_reference,
        body:    {
          'error' => 'Charge must be linked to a subscription or an order',
        },
      )
    end
  end
end
