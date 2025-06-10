# typed: strict

class Espago::BackRequestsController < ApplicationController
  extend T::Sig

  skip_before_action :verify_authenticity_token, only: [:handle_back_request]
  before_action :authenticate_espago!

  sig { void }
  def handle_back_request
    payload = T.let(JSON.parse(request.body.read), T::Hash[String, T.untyped])
    Rails.logger.info("Received Espago response: #{payload.inspect}")

    payment_id = payload['id']
    state = payload['state']
    description = payload['description']

    reject_reason = payload['reject_reason']
    behaviour = payload['behaviour']
    issuer_response_code = payload['issuer_response_code']

    payment = Payment.find_by(payment_id: payment_id)

    if payment.nil? && description.present?
      payment_number = description[/#([A-Z0-9]+)/, 1]
      Rails.logger.info("Extracted payment_number from description: #{payment_number}")

      if payment_number.present?
        payment = Payment.find_by(payment_number: payment_number)
        if payment.present?
          Rails.logger.info("Found Payment by payment_number. Assigning payment_id #{payment_id} to Payment #{payment_number}")
          payment.update!(payment_id: payment_id)
        end
      end
    end

    if payment.nil?
      Rails.logger.warn("Payment not found for payment_id: #{payment_id}")
      head :not_found
      return
    end

    payment.update_status_by_payment_status(state.to_s)
    payment.update(
      reject_reason:        reject_reason,
      behaviour:            behaviour,
      issuer_response_code: issuer_response_code,
    )

    head :ok
  end

  sig { void }
  def authenticate_espago!
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.dig(:espago, :login_basic_auth) &&
        password == Rails.application.credentials.dig(:espago, :password_basic_auth)
    end
  end
end
