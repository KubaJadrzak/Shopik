# frozen_string_literal: true
# typed: strict

module Espago
  module Payment
    class Response

      #: bool
      attr_reader :success

      #: String
      attr_reader :status

      #: Hash[String, untyped]
      attr_reader :body

      #: (success: bool, status: (String | Symbol | Integer), body: Hash[String, untyped]) -> void
      def initialize(success:, status:, body:)
        @success = success
        @status = status.to_s #: String
        @body = body
      end

      #: -> bool
      def success?
        @success
      end
    end
  end
end
