# frozen_string_literal: true
# typed: strict

module Espago
  class BackRequestsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:handle_back_request]
    before_action :authenticate_espago!

    #: -> void
    def handle_back_request
      payload = JSON.parse(request.body.read)

      payment = BackRequest::BackRequestPaymentHandler.new(payload).process_payment

      if payment.nil?
        head :not_found
        return
      end

      Espago::BackRequest::BackRequestClientHandler.new(payload, payment).process_client

      head :ok
    end

    #: -> bool || String
    def authenticate_espago!
      authenticate_or_request_with_http_basic do |username, password|
        username == Rails.application.credentials.dig(:espago, :login_basic_auth) &&
          password == Rails.application.credentials.dig(:espago, :password_basic_auth)
      end
    end
  end
end
