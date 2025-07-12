# frozen_string_literal: true
# typed: strict

module Espago
  module BackRequest
    class ClientProcessor

      #: (Hash[String, untyped], ::Payment) -> void
      def initialize(payload, payment)
        @payment = payment
        @payload = payload
        @state = payload['state'] #: String
        @description = payload['description'] #: String
        @user = payment.user #: ::User?
        @client_id = payload['client'] #: String
      end

      #: -> void
      def process_client
        return unless valid?

        create_or_update_client
      end


      private

      #: -> bool?
      def valid?
        @state == 'executed' &&
          @description.match?(/storing|cit|mit/i) &&
          @user &&
          @client_id.present?
      end

      #: -> void
      def create_or_update_client
        last4      = @payload.dig('card', 'last4')
        company    = @payload.dig('card', 'company')
        first_name = @payload.dig('card', 'first_name')
        last_name  = @payload.dig('card', 'last_name')
        year       = @payload.dig('card', 'year')
        month      = @payload.dig('card', 'month')

        @client = ::Client.find_by(client_id: @client_id) #: ::Client?

        if @client.nil?
          @client = ::Client.create!(
            client_id:  @client_id,
            user:       @user,
            company:    company,
            last4:      last4,
            first_name: first_name,
            last_name:  last_name,
            year:       year,
            month:      month,
            status:     'CIT',
          )
        end

        handle_mit_status if @description.match?(/mit/i)

        @payment.update!(client: @client) if @payment.client != @client
      end

      #: -> void
      def handle_mit_status
        client = @client #: as !nil
        if mit_verified?
          client.update(status: 'MIT')
        elsif mit_failure?
          client.update(status: 'CIT')
        end
      end

      #: -> bool
      def mit_verified?
        client = @client #: as !nil
        client.status != 'MIT'
      end

      #: -> bool
      def mit_failure?
        client = @client #: as !nil
        client.status == 'MIT' && ::Payment::FAILURE_STATUSES.include?(@state)
      end
    end
  end
end
