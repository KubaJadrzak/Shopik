# typed: strict

class Espago::BackRequest::BackRequestEspagoClientHandler
  extend T::Sig

  sig { params(payload: T::Hash[String, T.untyped], user: T.nilable(User)).void }
  def self.call(payload, user)
    return unless user

    client_id = payload['client']
    return unless client_id.present?

    last4      = payload.dig('card', 'last4')
    company    = payload.dig('card', 'company')
    first_name = payload.dig('card', 'first_name')
    last_name  = payload.dig('card', 'last_name')

    existing_client = EspagoClient.find_by(client_id: client_id)
    return unless existing_client.nil?

    EspagoClient.create!(
      client_id:  client_id,
      user:       user,
      company:    company,
      last4:      last4,
      first_name: first_name,
      last_name:  last_name,
    )
  end
end
