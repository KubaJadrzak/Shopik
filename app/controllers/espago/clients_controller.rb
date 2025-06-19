# typed: strict

module Espago
  class ClientsController < ApplicationController
    before_action :set_client, only: %i[show verify_mit]

    sig { void }
    def show
      client = T.must(@client)
      @payments = T.let(client.payments, T.nilable(ActiveRecord::Relation))
    end

    sig { void }
    def verify_mit
      client = T.must(@client)
      return unless client.status != 'CIT'

      redirect_to account_path, alert: 'We are experiencing an issue with your verification'
      nil
    end

    private

    sig { void }
    def set_client
      @client = T.let(Client.includes(:payments).find_by(id: params[:id]), T.nilable(Client))
    end
  end
end
