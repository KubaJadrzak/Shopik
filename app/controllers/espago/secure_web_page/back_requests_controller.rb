# typed: true

module Espago
  module SecureWebPage
    class BackRequestsController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [:handle_back_request]
      before_action :authenticate_espago!

      def handle_back_request
        payload = JSON.parse(request.body.read)
        Rails.logger.info("Received Espago response: #{payload.inspect}")

        payment_id = payload['id']
        state = payload['state']
        order = Order.find_by(payment_id: payment_id)

        if order.nil?
          Rails.logger.warn("Order not found for payment_id: #{payment_id}")
          head :not_found
          return
        end

        order.update_status_by_payment_status(state)

        head :ok
      end

      private

      def authenticate_espago!
        authenticate_or_request_with_http_basic do |username, password|
          username == Rails.application.credentials.dig(:espago, :app_id) &&
            password == Rails.application.credentials.dig(:espago, :password)
        end
      end
    end
  end
end
