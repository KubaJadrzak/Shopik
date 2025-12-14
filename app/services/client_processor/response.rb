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

    #: ::SavedPaymentMethod?
    attr_accessor :saved_payment_method

    #: (connected: bool, body: Hash[String, untyped], ?status: Integer?) -> void
    def initialize(connected:, body:, status: nil)
      super
      @saved_payment_method = nil #: ::SavedPaymentMethod?
    end
  end
end
