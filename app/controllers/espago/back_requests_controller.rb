class Espago::BackRequestsController < ApplicationController
  extend T::Sig

  skip_before_action :verify_authenticity_token, only: [:handle_back_request]
  before_action :authenticate_espago!


  def handle_back_request
    payload = T.let(JSON.parse(request.body.read), T::Hash[String, T.untyped])
    Rails.logger.info("Received Espago response: #{payload.inspect}")

    payment_id = payload['id']
    state = payload['state']
    description = payload['description']

    reject_reason = payload['reject_reason']
    behaviour = payload['behaviour']
    issuer_response_code = payload['issuer_response_code']

    charge = Charge.find_by(payment_id: payment_id)

    if charge.nil? && description.present?
      charge_number = description[/#([A-Z0-9]+)/, 1]
      Rails.logger.info("Extracted charge_number from description: #{charge_number}")

      if charge_number.present?
        charge = Charge.find_by(charge_number: charge_number)
        if charge.present?
          Rails.logger.info("Found Charge by charge_number. Assigning payment_id #{payment_id} to Charge #{charge_number}")
          charge.update!(payment_id: payment_id)
        end
      end
    end

    if charge.nil?
      Rails.logger.warn("Charge not found for payment_id: #{payment_id}")
      head :not_found
      return
    end

    charge.update_status_by_payment_status(state.to_s)
    charge.update(
      reject_reason:        reject_reason,
      behaviour:            behaviour,
      issuer_response_code: issuer_response_code,
      raw_response:         payload,
    )

    head :ok
  end

  def authenticate_espago!
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.dig(:espago, :login_basic_auth) &&
        password == Rails.application.credentials.dig(:espago, :password_basic_auth)
    end
  end
end
