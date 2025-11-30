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
      ::PaymentProcessor::StateManager::ChargeCheck.new(response).process
    when ::Client
    end
  end

  #: -> (::Payment | ::Client)?
  def find_subject
    uuid = @back_request['description']

    return unless uuid.present?

    if uuid.starts_with?('pay')
      ::Payment.find_by(uuid: uuid)
    elsif uuid.starts_with?('cli')
      ::Client.find_by(uuid: uuid)
    end
  end
end
