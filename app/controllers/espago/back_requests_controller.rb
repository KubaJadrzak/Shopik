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

    # Try to find the record in either Order or Charge
    record = find_record_by_payment_id(payment_id)

    # If not found and description is present, try extracting the number and find again
    if record.nil? && description.present?
      number = description[/#([A-Z0-9]+)/, 1]
      Rails.logger.info("Extracted number from description: #{number}")

      if number.present?
        # Try Order by order_number first
        record = Order.find_by(order_number: number)
        if record.present?
          Rails.logger.info("Found Order by order_number. Assigning payment_id #{payment_id} to Order #{number}")
          record.update!(payment_id: payment_id)
        else
          # Try Charge by charge_number
          record = Charge.find_by(charge_number: number)
          if record.present?
            Rails.logger.info("Found Charge by charge_number. Assigning payment_id #{payment_id} to Charge #{number}")
            record.update!(payment_id: payment_id)
          end
        end
      end
    end

    if record.nil?
      Rails.logger.warn("Record not found for payment_id: #{payment_id}")
      head :not_found
      return
    end

    record.update_status_by_payment_status(state.to_s)

    head :ok
  end

  private

  sig { params(payment_id: String).returns(T.nilable(T.any(Order, Charge))) }
  def find_record_by_payment_id(payment_id)
    Order.find_by(payment_id: payment_id) || Charge.find_by(payment_id: payment_id)
  end

  sig { returns(T.untyped) }
  def authenticate_espago!
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.dig(:espago, :login_basic_auth) &&
        password == Rails.application.credentials.dig(:espago, :password_basic_auth)
    end
  end
end
