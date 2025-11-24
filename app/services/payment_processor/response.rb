# frozen_string_literal: true
# typed: strict


module PaymentProcessor
  class Response

    #: bool
    attr_reader :connected

    #: String
    attr_reader :status

    #: Hash[String, untyped]
    attr_reader :body

    #: (connected: bool, status: (String | Symbol | Integer), body: Hash[String, untyped]) -> void
    def initialize(connected:, status:, body:)
      @connected = connected
      @status = status.to_s #: String
      @body = body
    end

    #: -> bool
    def connected?
      @connected
    end
  end
end
