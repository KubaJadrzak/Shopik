# typed: strict
# frozen_string_literal: true

module PaymentProcessor
  class StateManager

    #: (::PaymentProcessor::Response) -> void
    def initialize(response)
      @response = response
      @type = response.type #: Symbol?
      @payment = response.payment #: ::Payment?
      @payable = @payment&.payable #: ::Order? | ::Subscription? | ::SavedPaymentMethod?
    end

    #: -> void
    def process
      return unless @type && @payment && @payable

      attach_client
      update_payable

      @payment.state = @response.state
      @payment.response = @response.body.to_json

      case @type
      when :charge, :check, :iframe3
        handle_charge
        create_client
      end

      @payment.save(validate: false)
    end

    #: -> void
    def handle_charge
      return unless @payment

      espago_payment_id = @response.espago_payment_id
      espago_client_id = @response.espago_client_id
      card_identifier = @response.card_identifier
      transaction_id = @response.transaction_id

      attrs = {
        reject_reason:        @response.reject_reason,
        issuer_response_code: @response.issuer_response_code,
        behaviour:            @response.behaviour,
      }
      attrs[:espago_payment_id] = espago_payment_id if espago_payment_id
      attrs[:espago_client_id] = espago_client_id if espago_client_id
      attrs[:card_identifier] = card_identifier if card_identifier
      attrs[:transaction_id] = transaction_id if transaction_id

      @payment.update(attrs)
    end

    #: -> void
    def attach_client
      c = @response.saved_payment_method
      return unless @payment && @payment.saved_payment_method.nil? && @response.success? && c

      @payment.saved_payment_method = c
    end

    #: -> void
    def update_payable
      return unless @payable

      case @payable
      when ::Order
        @payable.state = ORDER_STATUS_MAP[@response.state] || 'Payment Error'
      when ::Subscription
        @payable.state = SUBSCRIPTION_STATUS_MAP[@response.state] || 'Payment Error'
      end
      @payable.save(validate: false)
    end

    #: -> void
    def create_client
      return unless @payment&.storing? && @response.success? && @response.saved_payment_method.nil? && @response.espago_client_id

      @payment.user.saved_payment_methods.create(
        state:            'CIT Verified',
        espago_client_id: @response.espago_client_id,
        card_identifier:  @response.card_identifier,
        company:          @response.card_company,
        last4:            @response.card_last4,
        first_name:       @response.card_first_name,
        last_name:        @response.card_last_name,
        month:            @response.card_month,
        year:             @response.card_year,
      )

      attach_client
    end
  end
end
