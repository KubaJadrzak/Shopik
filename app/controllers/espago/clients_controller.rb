# frozen_string_literal: true
# typed: strict

module Espago
  class ClientsController < ApplicationController
    before_action :set_client, only: %i[show toggle_primary verify]

    #: -> void
    def show
      client = @client #: as !nil
      @payments = client.payments #: ActiveRecord::Relation?
    end

    #: -> void
    def toggle_primary
      if current_user.auto_renew_subscription? && current_user.primary_payment_method?
        current_user.auto_renew_subscription.update!(auto_renew: false)
      end

      current_primary = current_user.primary_payment_method
      current_primary&.update!(primary: false) unless current_primary == @client

      @client&.update!(primary: !@client.primary)


    end

    #: -> void
    def verify
      unless @client&.cit? # rubocop:disable Style/GuardClause
        redirect_to account_path, alert: 'We could not process your verification due to a technical issue'
      end
    end

    private

    #: -> void
    def set_client
      @client = ::Client.includes(:payments).find(params[:id]) #: ::Client?
    end
  end
end
