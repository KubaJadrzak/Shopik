# typed: strict

class Espago::BackRequest::BackRequestPaymentHandler
  extend T::Sig

  sig { params(payload: T::Hash[String, T.untyped]).returns(T.nilable(Payment)) }
  def self.call(payload)
    payment_id = payload['id']
    client_id = payload['client']
    state = payload['state']
    description = payload['description']
    reject_reason = payload['reject_reason']
    behaviour = payload['behaviour']
    issuer_response_code = payload['issuer_response_code']

    payment = Payment.find_by(payment_id: payment_id)

    if payment.nil? && description.present?
      payment_number = description[/#([A-Z0-9]+)/, 1]
      if payment_number.present?
        payment = Payment.find_by(payment_number: payment_number)
        payment&.update!(payment_id: payment_id)
      end
    end

    return if payment.nil?

    client = client_id.present? ? Client.find_by(client_id: client_id) : nil

    payment.update_status_by_payment_status(state.to_s)
    payment.update(
      reject_reason: reject_reason,
      behaviour: behaviour,
      issuer_response_code: issuer_response_code,
      client: client
    )
    payment
  end
end
