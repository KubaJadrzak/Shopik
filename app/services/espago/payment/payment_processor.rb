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
        @description = '' #: String
      end

      #: -> [Symbol, String]
      def process_payment
        @payment.update_payment_and_payable_statuses(@payment.state)
        response = if @payment.payable.present?
                     handle_payment
                   else
                     handle_no_payable
                   end

        @payment.process_response(response)
      end

      #: -> [Symbol, String]
      def reverse_payment
        payment_id = @payment.payment_id #: as !nil
        response = create_payment_reversal(payment_id)

        @payment.process_response(response)
      end

      #: -> [Symbol, String]
      def refund_payment
        payment_id = @payment.payment_id #: as !nil
        response = create_payment_refund(payment_id)

        @payment.process_response(response)
      end

      private

      #: -> Response
      def handle_payment
        build_description
        if @card_token || @client_id
          handle_one_time_payment
        else
          handle_secure_web_payment
        end
      end

      #: -> Response
      def handle_no_payable
        Response.new(
          success: false,
          status:  :missing_payable,
          body:    { 'error' => 'Payment must be linked to a payable' },
        )
      end

      #: -> String
      def build_description
        desc = "Payment ##{@payment.payment_number}"
        desc += ' - storing' if @cof == 'storing'
        desc += ' - cit' if @client_id && @cof != 'recurring'
        desc += ' - mit' if @client_id && @cof == 'recurring'

        @description = desc
      end

      #: -> Response
      def handle_one_time_payment
        payload = PayloadBuilder.new(payment:     @payment,
                                     description: @description,
                                     cof:         @cof,
                                     card_token:  @card_token,
                                     client_id:   @client_id,).one_time_payment

        create_one_time_payment(payload)
      end

      #: -> Response
      def handle_secure_web_payment
        payload = PayloadBuilder.new(payment:     @payment,
                                     description: @description,
                                     cof:         @cof,
                                     card_token:  @card_token,
                                     client_id:   @client_id,).secure_web_payment
        create_secure_web_payment(payload)
      end

      #: (String) -> Response
      def create_payment_reversal(payment_id)
        Espago::Client.new.send("api/charges/#{payment_id}", method: :delete) # rubocop:disable Style/Send
      end

      #: (Hash[Symbol, String]) -> Response
      def create_one_time_payment(payload)
        Espago::Client.new.send('api/charges', method: :post, body: payload) # rubocop:disable Style/Send
      end

      #: (Hash[Symbol, String]) -> Response
      def create_secure_web_payment(payload)
        Espago::Client.new.send('api/secure_web_page_register', method: :post, body: payload) # rubocop:disable Style/Send
      end

      #: (String) -> Response
      def create_payment_refund(payment_id)
        Espago::Client.new.send("api/charges/#{payment_id}/refund", method: :post) # rubocop:disable Style/Send
      end
    end
  end
end
