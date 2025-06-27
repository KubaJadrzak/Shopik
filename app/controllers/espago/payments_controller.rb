# frozen_string_literal: true
# typed: strict

module Espago
  class PaymentsController < ApplicationController

    before_action :authenticate_user!
    before_action :set_payment, only: %i[new start_payment payment_success payment_failure payment_awaiting]
    before_action :set_parent, only: %i[new start_payment]

    #: -> void
    def new
      unless @parent
        redirect_to account_path, alert: 'We could not create your payment due to a technical issue'
        return
      end

      @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY') #: String?
    end

    #: -> void
    def start_payment
      unless @parent
        redirect_to account_path, alert: 'We could not create your payment due to a technical issue'
        return
      end

      create_payment
      unless @payment
        redirect_to account_path, alert: 'We could not create your payment due to a technical issue'
        return
      end

      set_payment_params

      action, param = Espago::Payment::EspagoPaymentProcessor.new(payment: @payment, card_token: @card_token, cof: @cof,
                                                                  client_id: @client_id,).process_payment

      handle_action(action, param)
    end

    #: -> void
    def payment_success
      unless @payment
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
        return
      end
      handle_redirect('Payment successful!')
    end

    #: -> void
    def payment_failure
      unless @payment
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
        return
      end
      handle_redirect('Payment failed!')
    end

    #: -> void
    def payment_awaiting
      unless @payment
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
        return
      end
      handle_redirect('Payment is being processed!')
    end

    private

    #: -> void
    def set_payment
      @payment = ::Payment.find_by(payment_number: params[:payment_number]) #: ::Payment?
    end

    #: -> void
    def set_parent
      parent_type = params[:parent_type]
      parent_id = params[:parent_id]
      @parent = parent_type.find_by(id: parent_id) #: Order? | Subscription? | Client?
    end

    #: -> void
    def create_payment
      parent = @parent #: as !nil
      @payment = parent.payments.create(amount: parent.amount, state: 'new')
    end

    #: -> void
    def set_payment_params
      @card_token = params[:card_token] #: String?
      @cof = params[:cof] #: String?
      client_id_param = params[:payment_mode] #: String?
      @client_id = client_id_param&.start_with?('cli') ? client_id_param : nil #: String?
    end

    #: (Symbol, String) -> void
    def handle_action(action, param)
      case action
      when :redirect_url
        redirect_to param, allow_other_host: true
      when :success
        redirect_to espago_payments_success_path(param)
      when :awaiting
        redirect_to espago_payments_awaiting_path(param)
      when :failure
        redirect_to espago_payments_failure_path(param)
      end
    end

    #: (String) -> void
    def handle_redirect(message)
      payment = @payment #: as !nil
      case payment.payable
      when Subscription
        redirect_to subscription_path(payment.payable), notice: message
      when Order
        redirect_to order_path(payment.payable), notice: message
      when Client
        redirect_to espago_client_path(payment.payable), notice: message
      else
        redirect_to account_path, alert: 'We are experiencing an issue with your payment'
      end
    end
  end
end
