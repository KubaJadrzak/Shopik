# typed: strict

module Espago
  module Payment
    module SecureWebPage
      class SecureWebPageService
        extend T::Sig

        sig { params(payload: Espago::Payment::SecureWebPage::SecureWebPagePayload).void }
        def initialize(payload:)
          @payload = payload
        end

        sig { returns(Espago::Payment::Response) }
        def create_payment
          Espago::ClientService.new.send('api/secure_web_page_register', method: :post, body: @payload.to_h)
        end
      end
    end
  end
end
