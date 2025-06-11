# typed: strict

class Espago::Payment::PaymentInitializer
  extend T::Sig

  sig { params(payment: Payment, card_token: T.nilable(String)).returns(Espago::Response) }
  def self.initilize(payment:, card_token:)
    if payment.payable.present?
      Espago::Payment::PaymentHandler.new(payment, card_token).handle_payment
    else
      Espago::Response.new(
        success: false,
        status:  :missing_reference,
        body:    { 'error' => 'Payment must be linked to a payable (order or subscription)' },
      )
    end
  end
end
