# frozen_string_literal: true
# typed: strict

module Espago
  class ClientsController < ApplicationController
    before_action :set_client, only: %i[show toggle_primary]

    #: -> void
    def show
      client = @client #: as !nil
      @payments = client.payments #: ActiveRecord::Relation?
    end

    #: -> void
    def toggle_primary
      current_primary = Client.find_by(primary: true)
      current_primary&.update!(primary: false) unless current_primary == @client

      owner = @client #: as !nil
      owner.update!(primary: !owner.primary)
    end

    private

    #: -> void
    def set_client
      @client = Client.includes(:payments).find(params[:id]) #: Client?
    end
  end
end
