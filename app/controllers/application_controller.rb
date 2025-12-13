# frozen_string_literal: true
# typed: true


class ApplicationController < ActionController::Base
  extend T::Sig
  include Pagy::Backend

  allow_browser versions: :modern
  rescue_from PaymentError, with: :handle_payment_error
  rescue_from ClientError, with: :handle_client_error
  rescue_from SubscriptionError, with: :handle_subscription_error
  rescue_from GenericError, with: :handle_generic_error

  def after_sign_in_path_for(resource)
    UpdatePaymentStatusJob.perform_now
    FinalizePaymentJob.perform_now
    ResignPaymentJob.perform_now
    ResignOrderJob.perform_now
    ExpireSubscriptionJob.perform_now
    super
  end

  private

  def handle_payment_error(error)
    redirect_to account_path, alert: error.message
  end

  def handle_client_error(error)
    redirect_to account_path, alert: error.message
  end

  def handle_subscription_error(error)
    redirect_to account_path, alert: error.message
  end

  def handle_generic_error(error)
    redirect_to root_path, alert: error.message
  end
end
