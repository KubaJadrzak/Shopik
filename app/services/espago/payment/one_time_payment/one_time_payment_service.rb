# frozen_string_literal: true
# typed: strict

module Espago
  module Payment
    module OneTimePayment
      class OneTimePaymentService

        #: (payload: OneTimePaymentPayload) -> void
        def initialize(payload:)
          @payload = payload
        end

        #: -> Espago::Payment::PaymentResponse
        def create_payment
          Espago::ClientService.new.send('api/charges', method: :post, body: @payload.to_h)
        end
      end
    end
  end
end
