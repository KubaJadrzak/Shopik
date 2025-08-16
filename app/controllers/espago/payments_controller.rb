# frozen_string_literal: true
# typed: strict

module Espago
  class PaymentsController < ApplicationController

    before_action :authenticate_user!
    before_action :set_payment, only: %i[new reverse refund payment_success payment_failure payment_awaiting]
    before_action :set_payable, only: %i[new start_payment]

    #: -> void
    def new
      unless @payable
        redirect_to account_path, alert: 'We could not create your payment due to a technical issue'
        return
      end

      @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY') #: String?
    end

    #: -> void
    def reverse
      unless @payment
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
        return
      end

      unless @payment.reversable?
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
        return
      end

      @payment.reverse_payment
    end

    #: -> void
    def refund
      return if @payment

      redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      nil

    end

    #: -> void
    def start_payment
      unless @payable
        redirect_to account_path, alert: 'We could not create your payment due to a technical issue'
        return
      end

      @payment = ::Payment.create_payment(payable: @payable)
      set_payment_params

      result_action, result_param = @payment.process_payment(
        card_token: @card_token,
        cof:        @cof,
        client_id:  @client_id,
      )
      handle_response(result_action, result_param)
    end

    #: -> void
    def payment_success

      unless @payment
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
        return
      end
      handle_redirect(message: 'Payment successful!')
    end

    #: -> void
    def payment_failure
      unless @payment
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
        return
      end
      handle_redirect(message: 'Payment failed!', alert: true)
    end

    #: -> void
    def payment_awaiting
      unless @payment
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
        return
      end
      handle_redirect(message: 'Payment is being processed!', alert: true)
    end

    private

    #: -> void
    def set_payment
      @payment = ::Payment.find_by(payment_number: params[:payment_number]) #: ::Payment?
    end

    #: -> void
    def set_payable
      payable_type = params[:payable_type]
      payable_id = params[:payable_id]
      if payable_type.blank? || payable_id.blank?
        set_new_payable
        return
      end
      @payable = payable_type.constantize.find_by(id: payable_id) #: Order? | Subscription? | ::Client?
    end

    #: -> void
    def set_new_payable
      if params[:order_id].present?
        @payable = Order.find_by(id: params[:order_id])
      elsif params[:subscription_id].present?
        @payable = Subscription.find_by(id: params[:subscription_id])
      elsif params[:client_id].present?
        @payable = ::Client.find_by(id: params[:client_id])
      end

      nil
    end

    #: -> void
    def set_payment_params
      @card_token = params[:card_token] #: String?
      @cof = params[:cof] #: String?
      set_client_id
    end

    #: -> void
    def set_client_id
      payment_mode = params[:payment_mode] #: String
      @client_id = payment_mode.start_with?('cli') ? payment_mode : nil #: String?
    end

    #: (Symbol, String) -> void
    def handle_response(result_action, result_param)
      case result_action
      when :redirect_url
        redirect_to result_param, allow_other_host: true
      when :success
        redirect_to espago_payments_success_path(result_param)
      when :awaiting
        redirect_to espago_payments_awaiting_path(result_param)
      when :failure
        redirect_to espago_payments_failure_path(result_param)
      end
    end

    #: (message: String, ?alert: bool) -> void
    def handle_redirect(message:, alert: false)
      payment = @payment #: as !nil

      flash_type = alert ? :alert : :notice

      case payment.payable
      when Subscription
        redirect_to subscription_path(payment.payable), flash_type => message
      when Order
        redirect_to order_path(payment.payable), flash_type => message
      when ::Client
        redirect_to espago_client_path(payment.payable), flash_type => message
      else
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      end
    end

  end
end
