# typed: strict

module Espago
  module SecureWebPage
    class PaymentsController < ApplicationController
      extend T::Sig

      before_action :authenticate_user!

      sig { void }
      def start_payment
        @order = T.let(Order.find(params[:id]), T.nilable(Order))

        payment_service = Espago::SecureWebPageService.new(T.must(@order))
        response = payment_service.create_payment

        if response.success?
          data = T.let(response.body, T::Hash[String, T.untyped])
          T.must(@order).update(payment_id: data['id'])
          redirect_to data['redirect_url'], allow_other_host: true
        else
          T.must(@order).update_status_by_payment_status(response.status.to_s)
          Rails.logger.warn("Payment rejected with status #{response.status} for Order ##{T.must(@order).id}")
          redirect_to order_path(T.must(@order)),
                      alert: 'We could not process your payment due to a technical issue'
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
    end
  end
end
