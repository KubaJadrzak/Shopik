# typed: strict

class Espago::SecureWebPage::SecureWebPageService
  extend T::Sig

  sig { params(payload: Espago::SecureWebPage::SecureWebPagePayload).void }
  def initialize(payload:)
    @payload = payload
  end

  sig { returns(Espago::Response) }
  def create_payment
    Espago::ClientService.new.send(
      'api/secure_web_page_register',
      method: :post,
      body:   @payload.to_h,
    )
  end
end
