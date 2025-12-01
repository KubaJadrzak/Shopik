# frozen_string_literal: true
# typed: strict


module PaymentProcessor
  class Response

    #: Integer?
    attr_reader :status

    #: Hash[String, untyped]
    attr_reader :body

    #: ::Payment?
    attr_writer :payment

    #: Symbol?
    attr_accessor :type

    #: (connected: bool, body: Hash[String, untyped], ?status: Integer?) -> void
    def initialize(connected:, body:, status: nil)
      @connected = connected
      @status = status
      @body = body
      @payment = nil #: ::Payment?
      @type = nil #: Symbol?
    end

    #: -> bool
    def connected?
      @connected
    end

    #: -> bool
    def communication_success?
      return false unless connected? && @status.present?

      @status.between?(200, 299)
    end

    #: -> bool
    def communication_failure?
      connected? && !communication_success?
    end

    #: -> bool
    def communication_uncertain?
      !connected?
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

    #: -> ::Payment?
    def payment
      @payment || ::Payment.find_by(uuid: payment_uuid)
    end

    #: -> (::Order | ::Subscription | ::Client)
    def payable
      payment&.payable
    end
  end
end
