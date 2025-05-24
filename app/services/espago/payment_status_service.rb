# typed: true

module Espago
  class PaymentStatusService
    def initialize(payment_id:)
      @payment_id = payment_id
      @client = ClientService.new
    end

    def fetch_payment_status
      response = @client.send("api/charges/#{@payment_id}", method: :get)

      unless response.success
        Rails.logger.error("Failed to fetch payment status for #{@payment_id}, status: #{response.status}: body: #{response.body}")
        return
      end

      payment_data = response.body

      Rails.logger.info("Successfully fetched payment status for #{@payment_id}: #{payment_data.inspect}")

      payment_data['state']
    end
  end
end
