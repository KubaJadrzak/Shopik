# frozen_string_literal: true
# typed: strict

class BackRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:receive]
  before_action :authenticate_espago!

  #: -> void
  def receive
    payload = JSON.parse(request.body.read)

    payment = Espago::BackRequest::PaymentProcessor.new(payload).process_payment

    if payment.nil?
      head :not_found
      return
    end

    Espago::BackRequest::ClientProcessor.new(payload, payment).process_client

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
