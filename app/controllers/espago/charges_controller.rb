class Espago::ChargesController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!


  def start_charge
    @charge = Charge.find_by(charge_number: params[:charge_number])
    @card_token = session.delete(:card_token)

    unless @charge
      redirect_to account_path, alert: 'We could not process your charge due to a technical issue'
      return
    end

    response = Espago::Charge::ChargeProcessor.process(charge: @charge, card_token: @card_token)
    Rails.logger.info(response.inspect)

    action, param = Espago::Charge::ChargeResponseHandler.handle_response(@charge, response)

    case action
    when :redirect_url
      redirect_to param, allow_other_host: true
    when :success
      redirect_to espago_charges_success_path(param)
    when :awaiting
      redirect_to espago_charges_awaiting_path(param)
    when :failure
      redirect_to espago_charges_failure_path(param),
                  alert: 'We could not process your charge due to a technical issue'
    end
  end

  def charge_success
    @charge = Charge.find_by(charge_number: params[:charge_number])

    if @charge&.subscription
      @subscription = @charge.subscription
      redirect_to subscription_path(T.must(@subscription)), notice: 'Charge successful!'
    elsif @charge&.order
      @order = @charge.order
      redirect_to order_path(T.must(@order)), notice: 'Charge successful!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your charge'
    end
  end

  def charge_failure
    @charge = Charge.find_by(charge_number: params[:charge_number])

    if @charge&.subscription
      @subscription = @charge.subscription
      redirect_to subscription_path(T.must(@subscription)), alert: 'Charge failed!'
    elsif @charge&.order
      @order = @charge.order
      redirect_to order_path(T.must(@order)), alert: 'Charge failed!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your charge'
    end
  end

  def charge_awaiting
    @charge = Charge.find_by(charge_number: params[:charge_number])

    if @charge&.subscription
      @subscription = @charge.subscription
      redirect_to subscription_path(T.must(@subscription)), alert: 'Payment is being processed!'
    elsif @charge&.order
      @order = @charge.order
      redirect_to order_path(T.must(@order)), alert: 'Payment is being processed!'
    else
      redirect_to account_path, alert: 'We are experiencing an issue with your charge'
    end
  end
end
