# typed: strict

class Espago::Payment::PaymentResponseHandler
  extend T::Sig

  sig { params(payment: Payment, response: Espago::Response).returns([Symbol, String]) }
  def self.handle_response(payment, response)
    return handle_success(payment, response.body) if response.success?

    handle_failure(payment, response.status.to_s)
  end

  sig { params(payment: Payment, data: T::Hash[String, T.untyped]).returns([Symbol, String]) }
  def self.handle_success(payment, data)
    payment.update!(
      payment_id:           data['id'],
      state:                data['state'],
      issuer_response_code: data['issuer_response_code'],
      reject_reason:        data['reject_reason']&.presence,
      behaviour:            data['behaviour']&.presence,
    )

    redirect_url = data['redirect_url'] || data.dig('dcc_decision_information', 'redirect_url')

    if redirect_url
      [:redirect_url, redirect_url]
    elsif data.key?('state')
      state = data['state']
      payment.update_status_by_payment_status(state)

      waiting_states = %w[
        preauthorized
        tds2_challenge
        tds_redirected
        dcc_decision
        blik_redirected
        transfer_redirected
        new
      ]

      case state
      when 'executed'
        [:success, payment.payment_number]
      when *waiting_states
        [:awaiting, payment.payment_number]
      else
        [:failure, payment.payment_number]
      end
    else
      [:failure, payment.payment_number]
    end
  end

  sig { params(payment: Payment, state: String).returns([Symbol, String]) }
  def self.handle_failure(payment, state)
    payment.update_status_by_payment_status(state)

    awaiting_states = %w[
      timeout
      connection_failed
      ssl_error
      parsing_error
      unknown_faraday_error
      unexpected_error
    ]

    if awaiting_states.include?(state)
      [:awaiting, payment.payment_number]
    else
      Rails.logger.warn("Payment rejected with status #{state}")
      [:failure, payment.payment_number]
    end
  end
end
