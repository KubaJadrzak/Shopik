# frozen_string_literal: true
# typed: strict

module Espago
  module Payment
    class PaymentStatusService
      extend T::Sig

      #: (payment_id: String) -> void
      def initialize(payment_id:)
        @payment_id = payment_id
        @client = Espago::ClientService.new #: Espago::ClientService
      end

      #: -> String?
      def fetch_payment_status
        response = @client.send("api/charges/#{@payment_id}", method: :get) # rubocop:disable Style/Send

        unless response.success
          Rails.logger.info("Failed to fetch payment status for #{@payment_id}, status: #{response.status}: body: #{response.body}")
          return
        end

        payment_data = response.body #: Hash[String, untyped]

        Rails.logger.info("Successfully fetched payment status for #{@payment_id}: #{response.inspect}")

        payment_data['state']
      end
    end
  end
end
