# typed: strict

module Espago
  module Payment
    module SecureWebPage
      class SecureWebPageService

        #: (payload: Espago::Payment::SecureWebPage::SecureWebPagePayload) -> void
        def initialize(payload:)
          @payload = payload
        end

        #: -> Espago::Payment::PaymentResponse
        def create_payment
          Espago::ClientService.new.send('api/secure_web_page_register', method: :post, body: @payload.to_h)
        end
      end
    end
  end
end
