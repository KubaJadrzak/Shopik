# typed: strict

module Espago
  module Payment
    class EspagoPaymentProcessor
      extend T::Sig

      sig do
        params(
          payment:    ::Payment,
          card_token: T.nilable(String),
          cof:        T.nilable(String),
          client_id:  T.nilable(String),
        ).void
      end
      def initialize(payment:, card_token: nil, cof: nil, client_id: nil)
        @payment = payment
        @card_token = card_token
        @cof = cof
        @client_id = client_id
      end

      sig { returns([Symbol, T.untyped]) }
      def process_payment
        @payment.update_status_by_payment_status(@payment.state)

        response = if @payment.payable.present?
                     PaymentHandler.new(
                       payment:    @payment,
                       card_token: @card_token,
                       cof:        @cof,
                       client_id:  @client_id,
                     ).handle_payment
                   else
                     Response.new(
                       success: false,
                       status:  :missing_reference,
                       body:    { 'error' => 'Payment must be linked to a payable' },
                     )
                   end

        Rails.logger.info(response.inspect)

        PaymentResponseHandler.handle_response(@payment, response)
      end
    end
  end
end
