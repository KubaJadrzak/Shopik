# typed: strict
# frozen_string_literal: true


class EspagoClient

  #: -> void
  def initialize
    base_url = ENV.fetch('ESPAGO_BASE_URL')
    @user = Rails.application.credentials.dig(:espago, :app_id) #: String
    @password = Rails.application.credentials.dig(:espago, :password) #: String

    @client = Sofia.new(base_url: base_url) #: Sofia::Client
  end

  #: (String path, ?body: Hash[Symbol, untyped]?, ?method: Symbol) -> ::Response
  def send(path, body: nil, method: :get)
    response = @client.send(method) do |req|
      req.path = path
      req.headers['Accept'] = 'application/vnd.espago.v3+json'
      req.headers['Authorization'] = "Basic #{encoded_credentials}"
      req.body = body if body
    end

    ::Response.new(
      connected: true,
      status:    response.status,
      body:      response.body,
    )
  rescue Sofia::Error::TimeoutError
    ::Response.new(connected: false, body: { error: 'timeout' })
  rescue Sofia::Error::ConnectionFailed
    ::Response.new(connected: false, body: { error: 'connection_failed' })
  rescue Sofia::Error::SSLError
    ::Response.new(connected: false, body: { error: 'ssl_error' })
  rescue Sofia::Error::InvalidJSON
    ::Response.new(connected: false, body: { error: 'parsing_error' })
  rescue URI::InvalidURIError, URI::BadURIError
    ::Response.new(connected: false, body: { error: 'invalid_uri' })
  rescue StandardError
    ::Response.new(connected: false, body: { error: 'unexpected_error' })
  end

  private

  #: -> String
  def encoded_credentials
    Base64.strict_encode64("#{@user}:#{@password}")
  end
end
