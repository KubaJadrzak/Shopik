# frozen_string_literal: true
# typed: strict

class ClientsController < ApplicationController
  before_action :set_client, :set_payments, only: %i[show]
  before_action :authenticate_user!

  #: -> void
  def show; end

  #: -> void
  def verify
    return if @client&.cit?

    redirect_to account_path, alert: 'We could not process your verification due to a technical issue'

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
