# frozen_string_literal: true
# typed: strict

module Espago
  class ClientsController < ApplicationController
    before_action :set_client, only: %i[show]

    #: -> void
    def show
      client = @client #: as !nil
      @payments = client.payments #: ActiveRecord::Relation?
    end

    #: -> void
    def verify_mit

    end

    private

    #: -> void
    def set_client
      @client = Client.includes(:payments).find(params[:id]) #: Client?
    end
  end
end
