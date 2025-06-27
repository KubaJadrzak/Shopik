# frozen_string_literal: true
# typed: strict

class Espago::BackRequest::BackRequestPaymentHandler

  def initialize(payload)
    @payment_id = payload['id']
    @client_id = payload['client']
    @state = payload['state']
    @description = payload['description']
    @reject_reason = payload['reject_reason']
    @behaviour = payload['behaviour']
    @issuer_response_code = payload['issuer_response_code']
  end

  #: -> Payment
  def process_payment
    payment = set_payment
    return if payment.nil?

    client = set_client(@client_id)

    payment.update_status_by_payment_status(@state.to_s)
    payment.update(
      reject_reason:        @reject_reason,
      behaviour:            @behaviour,
      issuer_response_code: @issuer_response_code,
      client:               client,
    )
    payment
  end

  private

  #: (Integer payment_id, String? description) -> Payment?
  def set_payment
    payment = Payment.find_by(payment_id: @payment_id)
    return payment if payment.present?

    return if @description.blank?

    payment_number = extract_payment_number(@description)
    return if payment_number.blank?

    payment = Payment.find_by(payment_number: payment_number)
    payment.update!(payment_id: @payment_id) if payment.present?

    payment
  end

  #: (String description) -> String?
  def extract_payment_number(description)
    match = description[/#([A-Z0-9]+)/, 1]
    match.presence
  end

  #: (untyped client_id) -> Client?
  def set_client(client_id)
    return if client_id.blank?

    Client.find_by(client_id: client_id)
  end
end
