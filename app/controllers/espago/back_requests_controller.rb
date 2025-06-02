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
    order = Order.find_by(payment_id: payment_id)

    if order.nil?
      Rails.logger.warn("Order not found for payment_id: #{payment_id}")
      head :not_found
      return
    end

    order.update_status_by_payment_status(state.to_s)

    head :ok
  end

  private

  sig { returns(T.untyped) }
  def authenticate_espago!
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.dig(:espago, :login_basic_auth) &&
        password == Rails.application.credentials.dig(:espago, :password_basic_auth)
    end
  end
end
