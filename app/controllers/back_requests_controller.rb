# frozen_string_literal: true
# typed: strict

class BackRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:receive]
  before_action :authenticate_espago!

  #: -> void
  def receive
    back_request = ::JSON.parse(request.body.read)

    ::BackRequestsProcessor.new(back_request).process
  end

  #: -> bool
  def authenticate_espago!
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.dig(:espago, :login_basic_auth) &&
        password == Rails.application.credentials.dig(:espago, :password_basic_auth)
    end
  end
end
