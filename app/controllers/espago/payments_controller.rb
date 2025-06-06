# typed: strict

class Espago::PaymentsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!

  sig { void }
  def start_payment
    @order = Order.find(params[:id])
    @card_token = T.let(session.delete(:card_token), T.nilable(String))
    app_host = ENV.fetch('APP_HOST_URL')

    response = if @card_token
                 payload = Espago::OneTimePaymentPayload.new(
                   amount:       @order.total_price,
                   currency:     'pln',
                   card:         @card_token,
                   description:  "Order ##{@order.order_number}",
                   positive_url: "#{app_host}/espago/payments/success?order_number=#{@order.order_number}",
                   negative_url: "#{app_host}/espago/payments/failure?order_number=#{@order.order_number}",
                 )

                 payment_service = Espago::OneTimePaymentService.new(payload: payload)
                 payment_service.create_payment
               else
                 payment_service = Espago::SecureWebPageService.new(@order)
                 payment_service.create_payment
               end

    Rails.logger.info(response.inspect)
    if response.success?
      data = T.let(response.body, T::Hash[String, T.untyped])
      @order.update(payment_id: data['id'])

      redirect_url = data['redirect_url'] || data.dig('dcc_decision_information', 'redirect_url')
      if redirect_url
        redirect_to redirect_url, allow_other_host: true
      elsif data.key?('state')
        state = data['state']
        @order.update_status_by_payment_status(state)

        status = @order.show_status_by_payment_status(state)
        case status
        when 'Preparing for Shipment'
          redirect_to espago_payments_success_path(@order)
        when 'Waiting for Payment'
          redirect_to espago_payments_awaiting_path(@order)
        else
          redirect_to espago_payments_failure_path(@order)
        end
      end

    else
      @order.update_status_by_payment_status(response.status)

      status = @order.show_status_by_payment_status(response.status)
      if status == 'Awaiting Payment'
        redirect_to espago_payments_awaiting_path(@order)
      else
        Rails.logger.warn("Payment rejected with status #{response.status} for Order ##{@order.order_number}")
        redirect_to order_path(@order),
                    alert: 'We could not process your payment due to a technical issue'
      end
    end

  end

  sig { void }
  def payment_success
    @order = T.let(Order.find_by(order_number: params[:order_number]), T.nilable(Order))

    if @order
      redirect_to order_path(@order), notice: 'Payment successful!'
    else
      redirect_to "#{account_path}#orders", alert: 'We are experiencing an issue with your order'
    end
  end

  sig { void }
  def payment_failure
    @order = T.let(Order.find_by(order_number: params[:order_number]), T.nilable(Order))

    if @order
      redirect_to order_path(@order), alert: 'Payment failed!'
    else
      redirect_to "#{account_path}#orders", alert: 'We are experiencing an issue with your order'
    end
  end

  sig { void }
  def payment_awaiting
    @order = T.let(Order.find_by(order_number: params[:order_number]), T.nilable(Order))

    if @order
      redirect_to order_path(@order), alert: 'Payment is being processed!'
    else
      redirect_to "#{account_path}#orders", alert: 'We are experiencing an issue with your order'
    end
  end
end
