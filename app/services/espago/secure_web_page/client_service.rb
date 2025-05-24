module Espago
  module SecureWebPage
    class ClientService

      def initialize
        base_url = ENV.fetch('ESPAGO_BASE_URL')
        @user = Rails.application.credentials.dig(:espago, :app_id)
        @password = Rails.application.credentials.dig(:espago, :password)

        @conn = Faraday.new(url: base_url) do |faraday|
          faraday.request :json

          faraday.request :retry, max: 3, interval: 0.5, interval_randomness: 0.5, backoff_factor: 2,
                                   exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed]

          faraday.response :raise_error
          faraday.response :json
          faraday.adapter Faraday.default_adapter

          faraday.options.timeout = 5
          faraday.options.open_timeout = 3
        end
      end

      def send(path, body: nil, method: :get)
        response = @conn.send(method) do |req|
          req.url path
          req.headers['Accept'] = 'application/vnd.espago.v3+json'
          req.headers['Authorization'] = "Basic #{encoded_credentials}"
          req.body = body if body
        end

        Response.new(success: true, status: response.status, body: response.body)

      rescue Faraday::TimeoutError => e
        Rails.logger.error("Secure Web Page ClientService timeout: #{e.message}")
        Response.new(success: false, status: :timeout, body: e.message)

      rescue Faraday::ConnectionFailed => e
        Rails.logger.error("Secure Web Page ClientService connection failed: #{e.message}")
        Response.new(success: false, status: :connection_failed, body: e.message)

      rescue Faraday::Error => e
        if e.respond_to?(:response) && e.response
          status = e.response[:status]
          body = e.response[:body]

          Rails.logger.error("Secure Web Page ClientService error status: #{status}, body: #{body}")
          return Response.new(success: false, status: status, body: body)
        end

        Rails.logger.error("Secure Web Page ClientService unknown Faraday error: #{e.message}")
        Response.new(success: false, status: :error, body: e.message)
      end

      private

      def encoded_credentials
        Base64.strict_encode64("#{@user}:#{@password}")
      end
    end
  end
end
