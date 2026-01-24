# frozen_string_literal: true
# typed: strict

class SavedPaymentMethodsController < ApplicationController
  include Errors::SavedPaymentMethodErrors

  before_action :set_saved_payment_method, only: %i[show destroy authorize toggle_primary]
  before_action :set_payments, only: %i[show]
  before_action :authenticate_user!

  #: -> void
  def show; end

  #: -> void
  def destroy
    raise saved_payment_method_error! unless @saved_payment_method

    response = ::ClientProcessor::Delete.new(@saved_payment_method).process

    raise saved_payment_method_error! unless response.communication_success?

    flash[:notice] = 'We have successfully deleted your Saved Payment Method!'
    respond_to do |format|
      format.turbo_stream do
        redirect_to account_path
      end
    end
  end

  #:-> void
  def authorize
    return unless request.post?

    raise saved_payment_method_error! unless @saved_payment_method && !@saved_payment_method.mit?

    response = ::ClientProcessor::Authorize.new(@saved_payment_method).process

    raise saved_payment_method_error! unless response.communication_success?

    redirect_to saved_payment_method_path(@saved_payment_method), notice: 'Authorization success!'
  end

  #: -> void
  def toggle_primary
    raise saved_payment_method_error! unless @saved_payment_method

    if @saved_payment_method.primary?
      @saved_payment_method.update(primary: false)
      current_user.update(auto_renew: false)
    else
      current_auto_renew = current_user.auto_renew
      current_user.update(auto_renew: false)

      current_primary = current_user.primary_payment_method
      current_primary&.update(primary: false)

      @saved_payment_method.update(primary: true)
      current_user.update(auto_renew: current_auto_renew)
    end
  end

  private

  #: -> void
  def set_saved_payment_method
    @saved_payment_method = ::SavedPaymentMethod.includes(:payments).find_by(uuid: params[:uuid]) #: ::SavedPaymentMethod?
  end

  #: -> void
  def set_payments
    @payments = @saved_payment_method&.payments #: ActiveRecord::Relation?
  end
end
