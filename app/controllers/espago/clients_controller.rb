# typed: strict

class Espago::ClientsController < ApplicationController

  before_action :set_client, only: %i[show]

  sig { void }
  def show
    return redirect_to root_path, alert: 'Espago client not found' unless @client

    @payments = @client.payments
  end

  private

  sig { void }
  def set_client
    @client = T.let(Client.includes(:payments).find_by(id: params[:id]), T.nilable(Client))
  end

end
