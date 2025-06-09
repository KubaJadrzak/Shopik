# typed: strict

class Espago::Payment::PaymentProcessor
  extend T::Sig

  sig { params(payment: Payment, card_token: T.nilable(String)).returns(Espago::Response) }
  def self.process(payment:, card_token:)
    if payment.subscription.present?
      Espago::Payment::SubscriptionPaymentHandler.new(payment, card_token).process
    elsif payment.order.present?
      Espago::Payment::OrderPaymentHandler.new(payment, card_token).process
    else
      Espago::Response.new(
        success: false,
        status:  :missing_reference,
        body:    {
          'error' => 'Payment must be linked to a subscription or an order',
        },
      )
    end
  end
end
