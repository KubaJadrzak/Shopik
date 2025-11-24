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

    PaymentProcessor::Response.new(connected: true, status: response.status, body: response.body)
  rescue Faraday::Error, StandardError => e
    handle_error(e)
  end

  private

  #: -> String
  def encoded_credentials
    Base64.strict_encode64("#{@user}:#{@password}")
  end

  #: (StandardError exception) -> PaymentProcessor::Response
  def handle_error(exception)
    status = case exception
             when Faraday::TimeoutError then :timeout
             when Faraday::ConnectionFailed then :connection_failed
             when Faraday::SSLError then :ssl_error
             when Faraday::ParsingError then :parsing_error
             when URI::InvalidURIError, URI::BadURIError then :invalid_uri
             when Faraday::ClientError then :client_error
             when Faraday::ServerError then :server_error
             else
               :unexpected_error
             end

    PaymentProcessor::Response.new(
      connected: false,
      status:    status,
      body:      { error: status.to_s },
    )
  end
end
