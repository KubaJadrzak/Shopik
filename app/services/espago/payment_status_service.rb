# typed: strict


class Espago::PaymentStatusService
  extend T::Sig

  sig { params(payment_id: String).void }
  def initialize(payment_id:)
    @payment_id = payment_id
    @client = T.let(Espago::ClientService.new, Espago::ClientService)
  end

  sig { returns(T.nilable(String)) }
  def fetch_payment_status
    response = @client.send("api/charges/#{@payment_id}", method: :get)

    unless response.success
      Rails.logger.error("Failed to fetch payment status for #{@payment_id}, status: #{response.status}: body: #{response.body}")
      return
    end

    payment_data = T.let(response.body, T::Hash[String, T.untyped])

    Rails.logger.info("Successfully fetched payment status for #{@payment_id}: #{response.inspect}")

    payment_data['state']
  end
end
