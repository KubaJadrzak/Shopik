# typed: strict

class Espago::ClientsController < ApplicationController
  before_action :set_client, only: %i[show]

  sig { void }
  def show
    client = T.must(@client)
    @payments = T.let(client.payments, T.nilable(ActiveRecord::Relation))
  end

  private

  sig { void }
  def set_client
    @client = T.let(Client.includes(:payments).find_by(id: params[:id]), T.nilable(Client))
  end
end
