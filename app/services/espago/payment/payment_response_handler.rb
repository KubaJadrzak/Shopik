# frozen_string_literal: true
# typed: strict

module Espago
  module Payment
    class PaymentResponseHandler

      #: (::Payment, PaymentResponse) -> void
      def initialize(payment, response)
        @payment = payment
        @response = response
        @data = response.body #: Hash[String, untyped]
        @state = @data['state'] #: String
      end

      #: -> [Symbol, String]
      def handle_response
        return handle_success if @response.success?

        handle_failure
      end

      #:  -> [Symbol, String]
      def handle_success
        @payment.update!(
          payment_id:           @data['id'],
          state:                @data['state'],
          issuer_response_code: @data['issuer_response_code'],
          reject_reason:        @data['reject_reason']&.presence,
          behaviour:            @data['behaviour']&.presence,
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
        redirect_url = @data['redirect_url'] || @data.dig('dcc_decision_information', 'redirect_url')

        if redirect_url
          [:redirect_url, redirect_url]
        elsif @data.key?('state')
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
