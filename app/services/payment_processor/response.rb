# frozen_string_literal: true
# typed: strict


module PaymentProcessor
  class Response < ::Response::Base
    extend T::Sig

    class << self
      #: (::Response::Base) -> ::PaymentProcessor::Response
      def build(base)
        new(
          status:    base.status,
          body:      base.body,
          connected: base.connected?,
        )
      end
    end

    #: ::Payment?
    attr_writer :payment

    #: (connected: bool, body: Hash[String, untyped], ?status: Integer?) -> void
    def initialize(connected:, body:, status: nil)
      super
      @payment = nil #: ::Payment?
    end

    #: -> bool
    def redirect?
      return false unless communication_success?

      redirect_url.present?
    end

    #: -> bool
    def success?
      return false unless communication_success?

      SUCCESS_STATUSES.include?(state)
    end

    #: -> bool
    def pending?
      return false unless communication_success?

      PENDING_STATUSES.include?(state)
    end

    #: -> bool
    def rejected?
      return false unless communication_success?

      REJECTED_STATUSES.include?(state)
    end

    #: -> bool
    def uncertain?
      return false unless communication_uncertain?

      UNCERTAIN_STATUSES.include?(state)
    end

    #: -> bool
    def failure?
      return false unless communication_failure?

      FAILURE_STATUSES.include?(state)
    end

    #: -> String?
    def redirect_url
      @body['redirect_url']
    end

    #: -> String
    def state
      return @body['state'] if communication_success?

      return @body['error'] if communication_uncertain?

      'client_error'
    end

    #: -> String?
    def espago_client_id
      @body['client']
    end

    #: -> String?
    def payment_uuid
      @body['description']
    end

    #: -> String?
    def espago_payment_id
      @body['id']
    end

    #: -> String?
    def reject_reason
      @body['reject_reason']
    end

    #: -> String?
    def issuer_response_code
      @body['issuer_response_code']
    end

    #: -> String?
    def behaviour
      @body['behaviour']
    end

    #: -> String?
    def card_company
      @body.dig('card', 'company')
    end

    #: -> String?
    def card_last4
      @body.dig('card', 'last4')
    end

    #: -> Integer?
    def card_year
      @body.dig('card', 'year')
    end

    #: -> Integer?
    def card_month
      @body.dig('card', 'month')
    end

    #: -> String?
    def card_first_name
      @body.dig('card', 'first_name')
    end

    #: -> String?
    def card_last_name
      @body.dig('card', 'last_name')
    end

    #: -> String?
    def card_identifier
      @body.dig('card', 'card_identifier')
    end

    #: -> String?
    def transaction_id
      @body['transaction_id']
    end

    #: -> ::Payment?
    def payment
      @payment || ::Payment.find_by(uuid: payment_uuid)
    end

    #: -> ::Client?
    def client
      ::Client.find_by(espago_client_id: espago_client_id)
    end

    #: -> (::Order | ::Subscription | ::Client)
    def payable
      payment&.payable
    end
  end
end
