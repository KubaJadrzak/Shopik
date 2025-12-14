# typed: strict
# frozen_string_literal: true

class BackRequestsProcessor
  #: (Hash[String, untyped]) -> void
  def initialize(back_request)
    @back_request = back_request
  end

  #: -> void
  def process
    subject = find_subject

    return unless subject

    case subject
    when ::Payment
      response = ::PaymentProcessor::Response.new(connected: true, status: 200, body: @back_request)
      response.payment = subject
      response.type = :charge
      ::PaymentProcessor::StateManager.new(response).process
    when ::SavedPaymentMethod
    end
  end

  #: -> (::Payment | ::SavedPaymentMethod)?
  def find_subject
    uuid = @back_request['description']

    return unless uuid.present?

    if uuid.starts_with?('pay')
      ::Payment.find_by(uuid: uuid)
    elsif uuid.starts_with?('sav')
      ::SavedPaymentMethod.find_by(uuid: uuid)
    end
  end
end
