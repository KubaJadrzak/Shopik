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

        if order
          case state
          when 'executed'
            order.update(payment_status: state, status: 'Preparing for Shipment')
          when 'rejected'
            order.update(payment_status: state, status: 'Payment Rejected')
          when 'failed'
            order.update(payment_status: state, status: 'Payment Failed')
          when 'resigned'
            order.update(payment_status: state, status: 'Payment Resigned')
          when 'reversed'
            order.update(payment_status: state, status: 'Payment Reversed')
          when 'preauthorized', 'tds2_challenge', 'tds_redirected', 'dcc_decision', 'blik_redirected', 'transfer_redirected', 'new'
            order.update(payment_status: state, status: 'Waiting for Payment')
          when 'refunded'
            order.update(payment_status: state, status: 'Payment Refunded')
          else
            order.update(payment_status: state)
          end
        end

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
