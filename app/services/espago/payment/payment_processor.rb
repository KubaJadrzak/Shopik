# frozen_string_literal: true
# typed: strict

module Espago
  module Payment
    class PaymentProcessor

      #: (payment: ::Payment, ?card_token: String?, ?cof: String?, ?client_id: String?) -> void
      def initialize(payment:, card_token: nil, cof: nil, client_id: nil)
        @payment = payment
        @card_token = card_token
        @cof = cof
        @client_id = client_id
      end

      #: -> [Symbol, untyped]
      def process_payment
        @payment.update_status_by_payment_status(@payment.state)
        response = if @payment.payable.present?
                     handle_payment
                   else
                     handle_no_payable
                   end

        Rails.logger.info(response.inspect)

        PaymentResponseHandler.new(@payment, response).handle_response
      end

      private

      #: -> PaymentResponse
      def handle_payment
        description = build_description
        if @card_token || @client_id
          handle_one_time_payment(description)
        else
          handle_secure_web_payment(description)
        end
      end

      #: -> PaymentResponse
      def handle_no_payable
        PaymentResponse.new(
          success: false,
          status:  :missing_reference,
          body:    { 'error' => 'Payment must be linked to a payable' },
        )
      end

      #: -> String
      def build_description
        desc = "Payment ##{@payment.payment_number}"
        desc += ' - storing' if @cof == 'storing'
        desc += ' - recurring' if @cof == 'recurring'
        desc += ' - CIT' if @client_id && @cof != 'recurring'
        desc
      end

      #: (String) -> PaymentResponse
      def handle_one_time_payment(description)
        attrs = {
          amount:       @payment.amount,
          currency:     'PLN',
          description:  description,
          positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
          negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number),
        }
        attrs[:cof] = @cof if @cof.present?
        attrs[:card] = @card_token if @card_token.present?
        attrs[:client] = @client_id if @client_id.present?

        payload = OneTimePayment::OneTimePaymentPayload.new(**attrs)
        OneTimePayment::OneTimePaymentService.new(payload: payload).create_payment
      end

      #: (String) -> PaymentResponse
      def handle_secure_web_payment(description)
        attrs = {
          amount:       @payment.amount,
          currency:     'PLN',
          kind:         'sale',
          title:        description,
          description:  description,
          positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
          negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number),
        }
        attrs[:cof] = @cof if @cof.present?

        payload = SecureWebPage::SecureWebPagePayload.new(**attrs)
        SecureWebPage::SecureWebPageService.new(payload: payload).create_payment
      end
    end
  end
end
