# frozen_string_literal: true
# typed: strict

module Espago
  module Payment
    class StatusService

      #: (payment_id: String) -> void
      def initialize(payment_id:)
        @payment_id = payment_id
        @client = Espago::Client.new #: Espago::Client
      end

      #: -> String?
      def fetch_payment_status
        response = @client.send("api/charges/#{@payment_id}", method: :get) # rubocop:disable Style/Send

        unless response.success
          return
        end

        payment_data = response.body #: Hash[String, untyped]

        payment_data['state']
      end
    end
  end
end
