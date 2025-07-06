# frozen_string_literal: true
# typed: strict

module Espago
  class PaymentsController < ApplicationController

    before_action :authenticate_user!
    before_action :set_payment, only: %i[new start_payment payment_success payment_failure payment_awaiting]
    before_action :set_parent, only: %i[new verify start_payment]

    #: -> void
    def new
      unless @parent
        redirect_to account_path, alert: 'We could not create your payment due to a technical issue'
        return
      end

      @espago_public_key = ENV.fetch('ESPAGO_PUBLIC_KEY') #: String?
    end

    #: -> void
    def verify
      unless @parent.present? && @parent.status != 'MIT' # rubocop:disable Style/GuardClause
        redirect_to account_path, alert: 'We could not process your verification due to a technical issue'
      end
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
      if parent_type.blank? || parent_id.blank?
        set_new_parent
        return
      end
      @parent = parent_type.constantize.find_by(id: parent_id) #: Order? | Subscription? | Client?
    end

    #: -> void
    def set_new_parent
      if params[:order_id].present?
        @parent = Order.find_by(id: params[:order_id])
      elsif params[:subscription_id].present?
        @parent = Subscription.find_by(id: params[:subscription_id])
      elsif params[:client_id].present?
        @parent = Client.find_by(id: params[:client_id])
      end

      nil
    end

    #: -> void
    def create_payment
      parent = @parent #: as !nil
      if parent.instance_of?(Client)
        @payment = parent.payable_payments.create(amount: parent.amount, state: 'new')
        return
      end
      @payment = parent.payments.create(amount: parent.amount, state: 'new')
    end

    #: -> void
    def set_payment_params
      @card_token = params[:card_token] #: String?
      @cof = params[:cof] #: String?
      set_payment_mode
    end

    #: -> void
    def set_payment_mode
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
