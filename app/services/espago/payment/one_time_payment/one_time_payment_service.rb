# typed: strict

module Espago
  module Payment
    module OneTimePayment
      class OneTimePaymentService
        extend T::Sig

        sig { params(payload: OneTimePaymentPayload).void }
        def initialize(payload:)
          @payload = payload
        end

        sig { returns(Espago::Payment::Response) }
        def create_payment
          Espago::ClientService.new.send('api/charges', method: :post, body: @payload.to_h)
        end
      end
    end
  end
end
