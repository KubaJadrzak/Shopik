class Espago::Charge::ChargeResponseHandler
  extend T::Sig

  def self.handle_response(charge, response)
    if response.success?
      handle_success(charge, response.body)
    else
      handle_failure(charge, response.status.to_s)
    end
  end

  def self.handle_success(charge, data)
    charge.update!(
      payment_id:           data['id'],
      state:                data['state'],
      issuer_response_code: data['issuer_response_code'],
      reject_reason:        data['reject_reason'].presence,
      behavior:             data['behavior'].presence,
      raw_response:         data,
    )

    redirect_url = data['redirect_url'] || data.dig('dcc_decision_information', 'redirect_url')

    if redirect_url
      [:redirect_url, redirect_url]
    elsif data.key?('state')
      state = data['state']
      charge.update_status_by_payment_status(state)

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
        [:success, charge.charge_number]
      when *waiting_states
        [:awaiting, charge.charge_number]
      else
        [:failure, charge.charge_number]
      end
    else
      [:failure, charge.charge_number]
    end
  end

  def self.handle_failure(charge, state)
    charge.update_status_by_payment_status(state)

    awaiting_states = %w[
      timeout
      connection_failed
      ssl_error
      parsing_error
      unknown_faraday_error
      unexpected_error
    ]

    if awaiting_states.include?(state)
      [:awaiting, charge.charge_number]
    else
      Rails.logger.warn("Charge rejected with status #{state}")
      [:failure, charge.charge_number]
    end
  end
end
