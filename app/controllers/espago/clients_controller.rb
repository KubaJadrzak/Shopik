# frozen_string_literal: true
# typed: strict

module Espago
  class ClientsController < ApplicationController
    before_action :set_client, only: %i[show toggle_primary verify]
    before_action :authenticate_user!

    #: -> void
    def show
      client = @client #: as !nil
      @payments = client.payments #: ActiveRecord::Relation?
    end

    #: -> void
    def toggle_primary
      if @client&.primary? && current_user.auto_renew_subscription?
        disable_primary_payment_method_with_subscription
      elsif current_user.auto_renew_subscription? && current_user.primary_payment_method?
        toggle_primary_payment_method_with_subscription
      else
        toggle_primary_payment_method
      end
    end

    #: -> void
    def verify
      return if @client&.cit?

      redirect_to account_path, alert: 'We could not process your verification due to a technical issue'

    end

    private

    #: -> void
    def disable_primary_payment_method_with_subscription
      current_user.auto_renew_subscription.update!(auto_renew: false)
      @client&.update!(primary: false)
    end

    #: -> void
    def toggle_primary_payment_method_with_subscription
      current_user.auto_renew_subscription.update!(auto_renew: false)
      current_primary = current_user.primary_payment_method
      current_primary&.update!(primary: false)
      @client&.update(primary: true)
      current_user.active_subscription.update!(auto_renew: true)
    end

    #: -> void
    def toggle_primary_payment_method
      current_primary = current_user.primary_payment_method
      current_primary&.update!(primary: false) if current_primary != @client
      @client&.update!(primary: !@client.primary)
    end

    #: -> void
    def set_client
      @client = ::Client.includes(:payments).find(params[:id]) #: ::Client?
    end
  end
end
