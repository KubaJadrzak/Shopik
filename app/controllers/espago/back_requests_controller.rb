class Espago::BackRequestsController < ApplicationController
  extend T::Sig

  skip_before_action :verify_authenticity_token, only: [:handle_back_request]
  before_action :authenticate_espago!

  def handle_back_request
    payload = JSON.parse(request.body.read)
    Rails.logger.info("Received Espago response: #{payload.inspect}")

    payment = Espago::BackRequest::BackRequestPaymentHandler.call(payload)

    if payment.nil?
      Rails.logger.warn('Payment not found for payment_id or payment_number')
      head :not_found
      return
    end

    Espago::BackRequest::BackRequestEspagoClientHandler.call(payload, payment.user)

    head :ok
  end

  def authenticate_espago!
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.dig(:espago, :login_basic_auth) &&
        password == Rails.application.credentials.dig(:espago, :password_basic_auth)
    end
  end
end
