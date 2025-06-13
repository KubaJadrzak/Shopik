# typed: strict

class Espago::BackRequest::BackRequestClientHandler
  extend T::Sig

  sig { params(payload: T::Hash[String, T.untyped], payment: Payment).void }
  def self.call(payload, payment)
    return unless payload['state'] == 'executed'

    description = payload['description']
    user = payment.user
    return unless description&.match?(/storing|cit|recurring/i)
    return unless user

    client_id = payload['client']
    return unless client_id.present?

    last4      = payload.dig('card', 'last4')
    company    = payload.dig('card', 'company')
    first_name = payload.dig('card', 'first_name')
    last_name  = payload.dig('card', 'last_name')
    year       = payload.dig('card', 'year')
    month      = payload.dig('card', 'month')


    client = Client.find_by(client_id: client_id)

    if client.nil?
      client = Client.create!(
        client_id:  client_id,
        user:       user,
        company:    company,
        last4:      last4,
        first_name: first_name,
        last_name:  last_name,
        year:       year,
        month:      month,
        status:     'CIT',
      )
    end


    payment.update!(client: client) if payment.client != client
  end
end
