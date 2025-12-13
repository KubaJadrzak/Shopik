# frozen_string_literal: true
# typed: strict

class ClientsController < ApplicationController
  include ClientErrors

  before_action :set_client, only: %i[show destroy authorize toggle_primary]
  before_action :set_payments, only: %i[show]
  before_action :authenticate_user!

  #: -> void
  def show; end

  #: -> void
  def destroy
    raise client_error! unless @client&.destroy

    flash[:notice] = 'We have successfully deleted your Client!'
    respond_to do |format|
      format.turbo_stream do
        redirect_to account_path
      end
    end
  end

  #:-> void
  def authorize
    return unless request.post?

    raise client_error! unless @client && !@client.mit?

    response = ::ClientProcessor::Authorize.new(@client).process

    raise client_error! unless response.communication_success?

    redirect_to client_path(@client), notice: 'Authorization success!'
  end

  #: -> void
  def toggle_primary
    raise client_error! unless @client

    if @client.primary?
      @client.update(primary: false)
      current_user.update(auto_renew: false)
    else
      current_auto_renew = current_user.auto_renew
      current_user.update(auto_renew: false)

      current_primary = current_user.primary_payment_method
      current_primary&.update(primary: false)

      @client.update(primary: true)
      current_user.update(auto_renew: current_auto_renew)
    end
  end

  private

  #: -> void
  def set_client
    @client = ::Client.includes(:payments).find_by(uuid: params[:uuid]) #: ::Client?
  end

  #: -> void
  def set_payments
    @payments = @client&.payments #: ActiveRecord::Relation?
  end
end
