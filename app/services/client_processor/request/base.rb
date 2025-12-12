# typed: strict
# frozen_string_literal: true

module ClientProcessor
  module Request
    # @abstract
    class Base
      extend T::Sig

      #: ::Client?
      attr_reader :client

      #: ::ClientProcessor::Response?
      attr_accessor :response

      #: (::Client) -> void
      def initialize(client)
        @client = client
      end

      #: -> ::ClientProcessor::Response
      def process
        base = ::EspagoClient.new.send(url, method: method, body: request)
        response = ::ClientProcessor::Response.build(base)
        response.client = @client
        response.type = type
        @response = response
      end

      sig { abstract.returns(String) }
      def url; end

      sig { abstract.returns(Symbol) }
      def method; end

      sig { abstract.returns(Symbol) }
      def type; end

      sig { abstract.returns(T.nilable(T::Hash[Symbol, T.untyped])) }
      def request; end
    end
  end
end
