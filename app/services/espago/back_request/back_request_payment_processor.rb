# frozen_string_literal: true
# typed: strict

module Espago
  module BackRequest
    class BackRequestPaymentProcessor

      #: (Hash[String, untyped]) -> void
      def initialize(payload)
        @payment_id = payload['id'] #: Integer
        @client_id = payload['client'] #: String
        @state = payload['state'] #: String
        @description = payload['description'] #: String
        @reject_reason = payload['reject_reason'] #: String
        @behaviour = payload['behaviour'] #: String
        @issuer_response_code = payload['issuer_response_code'] #: String
      end

      #: -> ::Payment?
      def process_payment
        payment = set_payment
        return unless payment

        client = set_client

        payment.update_payment_and_payable_statuses(@state.to_s)
        payment.update(
          reject_reason:        @reject_reason,
          behaviour:            @behaviour,
          issuer_response_code: @issuer_response_code,
          client:               client,
        )

        payment
      end

      private

      #: -> ::Payment?
      def set_payment
        payment = ::Payment.find_by(payment_id: @payment_id)
        return payment if payment.present?

        return if @description.blank?

        payment_number = extract_payment_number
        return if payment_number.blank?

        payment = ::Payment.find_by(payment_number: payment_number)
        payment.update!(payment_id: @payment_id) if payment.present?

        payment
      end

      #:  -> String?
      def extract_payment_number
        match = @description[/#([A-Z0-9]+)/, 1]
        match.presence
      end

      #: -> Client?
      def set_client
        return if @client_id.blank?

        Client.find_by(client_id: @client_id)
      end
    end
  end
end
