# typed: true

module Espago
  module SecureWebPage
    class PaymentsController < ApplicationController
      before_action :authenticate_user!

      def start_payment
        @order = Order.find(params[:id])

        payment_service = Espago::SecureWebPage::PaymentService.new(@order)
        response = payment_service.create_payment

        if response.success?
          data = response.body
          @order.update(payment_id: data['id'])
          redirect_to data['redirect_url'], allow_other_host: true
        else
          @order.update(payment_status: 'connection failed', status: 'Connection Failed')
          redirect_to order_path(@order), alert: 'We are experiencing an issue with payment service'
        end
      end

      def payment_success
        @order = Order.find_by(order_number: params[:order_number])

        if @order
          redirect_to order_path(@order), notice: 'Payment successful!'
        else
          redirect_to "#{account_path}#orders", alert: 'We are experiencing an issue with your order'
        end
      end

      def payment_failure
        @order = Order.find_by(order_number: params[:order_number])

        if @order
          redirect_to order_path(@order), alert: 'Payment failed!'
        else
          redirect_to "#{account_path}#orders", alert: 'We are experiencing an issue with your order'
        end
      end
    end
  end
end
