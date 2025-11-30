# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  module StateManager
    # @abstract
    class Base
      extend T::Sig

      #: (::PaymentProcessor::Response) -> void
      def initialize(response)
        @response = response
      end

      #: -> void
      def process
        update_payment
        update_payable
      end

      sig { abstract.void }
      def update_payment; end

      sig { abstract.void }
      def update_payable; end

    end
  end
end
