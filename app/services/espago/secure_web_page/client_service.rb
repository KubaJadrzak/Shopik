module Espago
  module SecureWebPage
    class ClientService


      def initialize
        base_url = ENV.fetch('ESPAGO_BASE_URL')
        @user = Rails.application.credentials.dig(:espago, :app_id)
        @password = Rails.application.credentials.dig(:espago, :password)

        @conn = Faraday.new(url: base_url) do |faraday|
          faraday.request :json
          faraday.response :raise_error
          faraday.response :json
          faraday.adapter Faraday.default_adapter
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
      rescue Faraday::Error => e
        if e.respond_to?(:response) && e.response
          status = e.response[:status]
          body = e.response[:body]

          Rails.logger.error("Secure Web Page ClientService status: #{status}, body: #{body}")
          return Response.new(success: false, status: status, body: body)
        end

        Rails.logger.error("Secure Web Page ClientService status: #{e.message}")
        Response.new(success: false, status: :connection_failed, body: e.message)
      end

      private

      def encoded_credentials
        Base64.strict_encode64("#{@user}:#{@password}")
      end
    end
  end
end
