# frozen_string_literal: true
# typed: strict

class ClientsController < ApplicationController
  include ClientErrors

  before_action :set_client, only: %i[show destroy]
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
    if request.get?
      # show page
    elsif request.post?
      # perform authorization
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
