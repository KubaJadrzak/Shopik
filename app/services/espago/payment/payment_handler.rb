# typed: strict

module Espago
  module Payment
    class PaymentHandler
      extend T::Sig

      sig do
        params(payment: ::Payment, card_token: T.nilable(String), cof: T.nilable(String), client_id: T.nilable(String)).void
      end
      def initialize(payment:, card_token: nil, cof: nil, client_id: nil)
        @payment = payment
        @card_token = card_token
        @cof = cof
        @client_id = client_id
      end

      sig { returns(Response) }
      def handle_payment
        description = build_description

        if @card_token || @client_id
          handle_one_time_payment(description)
        else
          handle_secure_web_payment(description)
        end
      end

      private

      sig { returns(String) }
      def build_description
        desc = "Payment ##{@payment.payment_number}"
        desc += ' - storing' if @cof == 'storing'
        desc += ' - CIT' if @client_id
        desc
      end

      sig { params(description: String).returns(Response) }
      def handle_one_time_payment(description)
        attrs = {
          amount: @payment.amount,
          currency: 'PLN',
          description: description,
          positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
          negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number)
        }
        attrs[:cof] = @cof if @cof.present?
        attrs[:card] = @card_token if @card_token.present?
        attrs[:client] = @client_id if @client_id.present?

        payload = OneTimePayment::OneTimePaymentPayload.new(**attrs)
        OneTimePayment::OneTimePaymentService.new(payload: payload).create_payment
      end

      sig { params(description: String).returns(Response) }
      def handle_secure_web_payment(description)
        attrs = {
          amount: @payment.amount,
          currency: 'PLN',
          kind: 'sale',
          title: description,
          description: description,
          positive_url: Rails.application.routes.url_helpers.espago_payments_success_url(payment_number: @payment.payment_number),
          negative_url: Rails.application.routes.url_helpers.espago_payments_failure_url(payment_number: @payment.payment_number)
        }
        attrs[:cof] = @cof if @cof.present?

        payload = SecureWebPage::SecureWebPagePayload.new(**attrs)
        SecureWebPage::SecureWebPageService.new(payload: payload).create_payment
      end
    end
  end
end
