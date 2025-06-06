# typed: strict

class Espago::OneTimePaymentService
  extend T::Sig

  sig { params(payload: Espago::OneTimePaymentPayload).void }
  def initialize(payload:)
    @payload = payload
  end

  sig { returns(Espago::Response) }
  def create_payment
    Espago::ClientService.new.send(
      'api/charges',
      method: :post,
      body:   @payload.to_h,
    )
  end
end
