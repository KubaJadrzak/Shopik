# typed: strict
# frozen_string_literal: true

module ClientProcessor
  class Response < ::Response::Base

    class << self
      #: (::Response::Base) -> ::ClientProcessor::Response
      def build(base)
        new(
          status:    base.status,
          body:      base.body,
          connected: base.connected?,
        )
      end
    end

    #: ::Client?
    attr_accessor :client

    #: (connected: bool, body: Hash[String, untyped], ?status: Integer?) -> void
    def initialize(connected:, body:, status: nil)
      super
      @client = nil #: ::Client?
    end
  end
end
