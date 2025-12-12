# typed: strict
# frozen_string_literal: true

module ClientProcessor
  module Request
    class Authorize < Base
      # @override
      #: -> Symbol
      def method
        :post
      end

      # @override
      #: -> Symbol
      def type
        :authorize
      end

      # @override
      #: -> String
      def url
        "api/clients/#{@client.espago_client_id}/authorize"
      end

      # @override
      #: -> Hash[Symbol, untyped]?
      def request
        nil
      end
    end
  end
end
