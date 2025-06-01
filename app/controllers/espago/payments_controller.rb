class Espago::PaymentsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!

  def start_payment
    @order = Order.find(params[:id])
    @card_token = session.delete(:card_token)

    response = if @card_token
                 payment_service = Espago::OneTimePaymentService.new(card_token: @card_token, order: @order)
                 payment_service.create_payment
               else
                 payment_service = Espago::SecureWebPageService.new(T.must(@order))
                 payment_service.create_payment
               end

    if response.success?
      data = T.let(response.body, T::Hash[String, T.untyped])
      T.must(@order).update(payment_id: data['id'])

      if data.key?('redirect_url')
        redirect_to data['redirect_url'], allow_other_host: true
      elsif data.key?('state')
        state = data['state']
        @order.update_status_by_payment_status(state)

        status = @order.show_status_by_payment_status(state)
        case status
        when 'Preparing for Shipment'
          redirect_to payment_success_path(@order)
        when 'Waiting for Payment'
          redirect_to payment_awaiting_path(@order)
        else
          redirect_to payment_failure_path(@order)
        end
      end

    else
      T.must(@order).update_status_by_payment_status(response.status.to_s)
      Rails.logger.warn("Payment rejected with status #{response.status} for Order ##{T.must(@order).id}")
      redirect_to order_path(T.must(@order)),
                  alert: 'We could not process your payment due to a technical issue'
    end

    Rails.logger.info(response)
  end

  def payment_success
    @order = T.let(Order.find_by(order_number: params[:order_number]), T.nilable(Order))

    if @order
      redirect_to order_path(@order), notice: 'Payment successful!'
    else
      redirect_to "#{account_path}#orders", alert: 'We are experiencing an issue with your order'
    end
  end

  def payment_failure
    @order = T.let(Order.find_by(order_number: params[:order_number]), T.nilable(Order))

    if @order
      redirect_to order_path(@order), alert: 'Payment failed!'
    else
      redirect_to "#{account_path}#orders", alert: 'We are experiencing an issue with your order'
    end
  end

  def payment_awaiting
    @order = T.let(Order.find_by(order_number: params[:order_number]), T.nilable(Order))

    if @order
      redirect_to order_path(@order), alert: 'Payment is being processed'
    else
      redirect_to "#{account_path}#orders", alert: 'We are experiencing an issue with your order'
    end
  end
end
