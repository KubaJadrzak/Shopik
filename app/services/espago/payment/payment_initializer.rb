# typed: strict

class Espago::Payment::PaymentInitializer
  extend T::Sig

  sig do
    params(
      payment:    Payment,
      card_token: T.nilable(String),
      cof:        T.nilable(String),
      client_id:  T.nilable(String),
    ).returns(Espago::Response)
  end
  def self.initilize(payment:, card_token: nil, cof: nil, client_id: nil)
    if payment.payable.present?
      Espago::Payment::PaymentHandler.new(payment: payment, card_token: card_token, cof: cof,
                                          client_id: client_id,).handle_payment
    else
      Espago::Response.new(
        success: false,
        status:  :missing_reference,
        body:    { 'error' => 'Payment must be linked to a payable (order or subscription)' },
      )
    end
  end
end
