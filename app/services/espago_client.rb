# frozen_string_literal: true
# typed: strict

class EspagoClient

  #: -> void
  def initialize
    base_url = ENV.fetch('ESPAGO_BASE_URL')
    @user = Rails.application.credentials.dig(:espago, :app_id) #: String
    @password = Rails.application.credentials.dig(:espago, :password) #: String

    @conn = Faraday.new(url: base_url) do |faraday|
      faraday.request :json
      faraday.request :retry,
                      max:                 3,
                      interval:            0.5,
                      interval_randomness: 0.5,
                      backoff_factor:      2,
                      exceptions:          [Faraday::TimeoutError, Faraday::ConnectionFailed]

      faraday.response :raise_error
      faraday.response :json
      faraday.adapter Faraday.default_adapter

      faraday.options.timeout = 5
      faraday.options.open_timeout = 3
    end #: Faraday::Connection
  end

  #: (String path, ?body: Hash[Symbol, untyped]?, ?method: Symbol) -> PaymentProcessor::Response
  def send(path, body: nil, method: :get)
    response = @conn.send(method) do |req|
      req.url path
      req.headers['Accept'] = 'application/vnd.espago.v3+json'
      req.headers['Authorization'] = "Basic #{encoded_credentials}"
      req.body = body if body
    end

    PaymentProcessor::Response.new(
      connected: true,
      status:    response.status,
      body:      response.body,
    )
  rescue Faraday::ClientError => e
    handle_client_error(e)
  rescue Faraday::ServerError
    PaymentProcessor::Response.new(connected: false, body: { error: 'server_error' })
  rescue Faraday::TimeoutError
    PaymentProcessor::Response.new(connected: false, body: { error: 'timeout' })
  rescue Faraday::ConnectionFailed
    PaymentProcessor::Response.new(connected: false, body: { error: 'connection_failed' })
  rescue Faraday::SSLError
    PaymentProcessor::Response.new(connected: false, body: { error: 'ssl_error' })
  rescue Faraday::ParsingError
    PaymentProcessor::Response.new(connected: false, body: { error: 'parsing_error' })
  rescue URI::InvalidURIError, URI::BadURIError
    PaymentProcessor::Response.new(connected: false, body: { error: 'invalid_uri' })
  rescue StandardError
    PaymentProcessor::Response.new(connected: false, body: { error: 'unexpected_error' })
  end

  private

  #: -> String
  def encoded_credentials
    Base64.strict_encode64("#{@user}:#{@password}")
  end

  #: (Faraday::ClientError | Faraday::ServerError exception) -> PaymentProcessor::Response
  def handle_client_error(exception)
    status = exception.response[:status]
    body   = exception.response[:body]

    PaymentProcessor::Response.new(
      connected: true,
      status:    status,
      body:      body,
    )
  end
end
