# typed: strict
# frozen_string_literal: true

module ClientProcessor
  module Request
    class Delete < Base
      # @override
      #: -> Symbol
      def method
        :delete
      end

      # @override
      #: -> Symbol
      def type
        :delete
      end

      # @override
      #: -> String
      def url
        "api/clients/#{@saved_payment_method.espago_client_id}"
      end

      # @override
      #: -> Hash[Symbol, untyped]?
      def request
        nil
      end
    end
  end
end
