# typed: strict

module Espago
  module BackRequest
    class BackRequestClientHandler


      def initialize(payload, payment)
        @payload = payload
        @state = payload['state']
        @description = payload['description']
        @user = payment.user
        @client_id = payload['client']
      end

      sig { params(payload: T::Hash[String, T.untyped], payment: ::Payment).void }
      def process_client
        return unless valid?

        create_or_update_client
      end
    end

    private

    def valid?
      @state == 'executed' &&
        @description.match?(/storing|cit|recurring/i) &&
        @user &&
        @client_id.present?
    end

    def create_or_update_client
      last4      = @payload.dig('card', 'last4')
      company    = @payload.dig('card', 'company')
      first_name = @payload.dig('card', 'first_name')
      last_name  = @payload.dig('card', 'last_name')
      year       = @payload.dig('card', 'year')
      month      = @payload.dig('card', 'month')

      client = Client.find_by(client_id: client_id)
      if client.nil?
        create_client
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
end
