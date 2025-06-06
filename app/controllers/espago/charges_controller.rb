# typed: strict

class Espago::ChargesController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!

  sig { void }
  def start_charge
    @subscription = Subscription.find(params[:id])
    @card_token = T.let(session.delete(:card_token), T.nilable(String))

    unless @card_token
      redirect_to espago_charges_failure_path(@subscription)
      return
    end

    if current_user.has_active_subscription?
      redirect_to "#{account_path}#subscriptions", alert: 'You already have an active subscription.'
      return
    end

    charge = T.let(@subscription.charges.create!(
                     amount: @subscription.price,
                   ), Charge,)

    app_host = ENV.fetch('APP_HOST_URL')

    payload = Espago::OneTimePaymentPayload.new(
      amount:       charge.amount,
      currency:     'pln',
      card:         @card_token,
      cof:          'storing',
      description:  "Charge ##{charge.charge_number}",
      positive_url: "#{app_host}/espago/charges/success?subscription_number=#{@subscription.subscription_number}",
      negative_url: "#{app_host}/espago/charges/failure?subscription_number=#{@subscription.subscription_number}",
    )



    payment_service = Espago::OneTimePaymentService.new(payload: payload)
    response = payment_service.create_payment


    Rails.logger.info(response.inspect)

    if response.success?
      data = T.let(response.body, T::Hash[String, T.untyped])

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
        redirect_to redirect_url, allow_other_host: true
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
          redirect_to espago_charges_success_path(@subscription)
        when *waiting_states
          redirect_to espago_charges_awaiting_path(@subscription)
        else
          redirect_to espago_charges_failure_path(@subscription)
        end
      else
        redirect_to espago_charges_failure_path(@subscription)
      end

    else
      state = response.status.to_s

      charge.update_status_by_payment_status(state)
      awaiting_states = %w[
        timeout
        connection_failed
        ssl_error
        parsing_error
        unknown_faraday_error
        unexpected_error
      ]
      case state
      when *awaiting_states
        redirect_to espago_charges_awaiting_path(@subscription)
      else
        Rails.logger.warn("Charge rejected with status #{state} for Subscription ##{@subscription.subscription_number}")
        redirect_to subscription_path(@subscription),
                    alert: 'We could not process your charge due to a technical issue'
      end
    end
  end


  sig { void }
  def charge_success
    @subscription = T.let(Subscription.find_by(subscription_number: params[:subscription_number]),
                          T.nilable(Subscription),)

    if @subscription
      redirect_to subscription_path(@subscription), notice: 'Charge successful!'
    else
      redirect_to "#{account_path}#subscriptions", alert: 'We are experiencing an issue with your subscription'
    end
  end

  sig { void }
  def charge_failure
    @subscription = T.let(Subscription.find_by(subscription_number: params[:subscription_number]),
                          T.nilable(Subscription),)
    Rails.logger.info("Subscription number: #{@subscription}")
    if @subscription
      redirect_to subscription_path(@subscription), alert: 'Charge failed!'
    else
      redirect_to "#{account_path}#subscriptions", alert: 'We are experiencing an issue with your subscription'
    end
  end

  sig { void }
  def charge_awaiting
    @subscription = T.let(Subscription.find_by(subscription_number: params[:subscription_number]),
                          T.nilable(Subscription),)

    if @subscription
      redirect_to subscription_path(@subscription), alert: 'Payment is being processed!'
    else
      redirect_to "#{account_path}#subscriptions", alert: 'We are experiencing an issue with your subscription'
    end
  end
end
