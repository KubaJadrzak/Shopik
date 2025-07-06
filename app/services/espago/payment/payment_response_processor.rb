# frozen_string_literal: true
# typed: strict

module Espago
  module Payment
    class PaymentResponseProcessor

      #: (payment: ::Payment, response: PaymentResponse) -> void
      def initialize(payment:, response:)
        @payment = payment
        @response = response
        @body = response.body #: Hash[String, untyped]
        @state = @body['state'] #: String
      end

      #: -> [Symbol, String]
      def process_response
        return handle_success if @response.success?

        handle_failure
      end

      #:  -> [Symbol, String]
      def handle_success
        @payment.update!(
          payment_id:           @body['id'],
          state:                @body['state'],
          issuer_response_code: @body['issuer_response_code'],
          reject_reason:        @body['reject_reason']&.presence,
          behaviour:            @body['behaviour']&.presence,
        )

        handle_success_redirect
      end

      #: -> [Symbol, String]
      def handle_failure
        @payment.update_status_by_payment_status(@state)

        handle_failure_redirect
      end

      #: -> [Symbol, String]
      def handle_success_redirect
        redirect_url = @body['redirect_url'] || @body.dig('dcc_decision_information', 'redirect_url')

        if redirect_url
          [:redirect_url, redirect_url]
        elsif @body.key?('state')
          @payment.update_status_by_payment_status(@state)

          pending_statuses = ::Payment::PENDING_STATUSES

          case @state
          when 'executed'
            [:success, @payment.payment_number]
          when *pending_statuses
            [:awaiting, @payment.payment_number]
          else
            [:failure, @payment.payment_number]
          end
        else
          [:failure, @payment.payment_number]
        end
      end

      #: -> [Symbol, String]
      def handle_failure_redirect
        uncertain_statuses = ::Payment::UNCERTAIN_STATUSES

        if uncertain_statuses.include?(@state)
          [:awaiting, @payment.payment_number]
        else
          [:failure, @payment.payment_number]
        end
      end
    end
  end
end
