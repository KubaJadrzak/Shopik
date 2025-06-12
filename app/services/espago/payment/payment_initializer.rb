# typed: strict

class Espago::Payment::PaymentInitializer
  extend T::Sig

  sig do
    params(
      payment:    Payment,
      card_token: T.nilable(String),
      cof:        T.nilable(String),
    ).returns(Espago::Response)
  end
  def self.initilize(payment:, card_token:, cof: nil)
    if payment.payable.present?
      Espago::Payment::PaymentHandler.new(payment, card_token, cof).handle_payment
    else
      Espago::Response.new(
        success: false,
        status:  :missing_reference,
        body:    { 'error' => 'Payment must be linked to a payable (order or subscription)' },
      )
    end
  end
end
