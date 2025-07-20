# frozen_string_literal: true
# typed: strict

module Espago
  class Client

    #: -> void
    def initialize
      base_url = ENV.fetch('ESPAGO_BASE_URL') #: String
      @user = Rails.application.credentials.dig(:espago, :app_id) #: String
      @password = Rails.application.credentials.dig(:espago, :password) #: String

      @conn = Faraday.new(url: base_url) do |faraday|
        faraday.request :json

        faraday.request :retry, max: 3, interval: 0.5, interval_randomness: 0.5, backoff_factor: 2,
                                exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed]

        faraday.response :raise_error
        faraday.response :json
        faraday.adapter Faraday.default_adapter

        faraday.options.timeout = 5
        faraday.options.open_timeout = 3
      end #: Faraday::Connection
    end

    #: (String path, ?body: untyped, ?method: Symbol) -> Espago::Payment::Response
    def send(path, body: nil, method: :get)
      Rails.logger.info(body)
      response = @conn.send(method) do |req| # rubocop:disable Style/Send
        req.url path
        req.headers['Accept'] = 'application/vnd.espago.v3+json'
        req.headers['Authorization'] = "Basic #{encoded_credentials}"
        req.body = body if body
      end

      Espago::Payment::Response.new(success: true, status: response.status, body: response.body)
    rescue Faraday::TimeoutError => e
      handle_error(:timeout, e)
    rescue Faraday::ConnectionFailed => e
      handle_error(:connection_failed, e)
    rescue Faraday::SSLError => e
      handle_error(:ssl_error, e)
    rescue Faraday::ClientError => e
      handle_error_from_response(:client_error, e)
    rescue Faraday::ServerError => e
      handle_error_from_response(:server_error, e)
    rescue Faraday::ParsingError => e
      handle_error(:parsing_error, e)
    rescue URI::InvalidURIError, URI::BadURIError => e
      handle_error(:invalid_uri, e)
    rescue Faraday::Error => e
      handle_error(:unknown_faraday_error, e)
    rescue StandardError => e
      handle_error(:unexpected_error, e)
    end

    private

    #: -> String
    def encoded_credentials
      user = @user
      password = @password
      Base64.strict_encode64("#{user}:#{password}")
    end

    #: (Symbol type, StandardError exception) -> Espago::Payment::Response
    def handle_error(type, exception)
      Rails.logger.error("Espago Client Service error status #{type}:, body: #{exception.message}")
      Espago::Payment::Response.new(success: false, status: type, body: { 'error' => exception.message })
    end

    #: (Symbol default_type, Faraday::Error exception) -> Espago::Payment::Response
    def handle_error_from_response(default_type, exception)
      if exception.respond_to?(:response) && exception.response
        status = exception.response[:status]
        body = exception.response[:body]

        Rails.logger.error("Espago Client Service error status: #{status}, body: #{body}")
        Espago::Payment::Response.new(success: false, status: status, body: body)
      else
        handle_error(default_type, exception)
      end
    end
  end
end
