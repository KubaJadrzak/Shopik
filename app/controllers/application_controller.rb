# frozen_string_literal: true
# typed: true


class ApplicationController < ActionController::Base
  extend T::Sig
  include Pagy::Backend

  allow_browser versions: :modern
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::InvalidForeignKey, with: :handle_invalid_foreign_key
  rescue_from ActionController::RoutingError, with: :handle_routing_error
  rescue_from PaymentError, with: :handle_payment_error

  def payment_error!
    redirect_to account_path, alert: 'We are experiencing an issue with your payment'
  end

  def after_sign_in_path_for(resource)
    Espago::UpdatePaymentStatusJob.perform_later(resource.id)
    super
  end

  def raise_not_found
    raise ActionController::RoutingError, "No route matches #{request.path.inspect}"
  end

  private

  def record_not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: 'Record not found.' }
      format.json { render json: { error: 'Record not found' }, status: :not_found }
      format.turbo_stream do
        flash.now[:alert] = 'Record not found.'
        render turbo_stream: turbo_stream.replace('flash', partial: 'shared/flash'), status: :not_found
      end
    end
  end

  def handle_invalid_foreign_key(exception)
    Rails.logger.warn "Foreign key violation: #{exception.message}"

    respond_to do |format|
      format.html do
        redirect_back fallback_location: root_path, alert: 'Invalid reference to another resource.'
      end
      format.turbo_stream do
        flash.now[:alert] = 'Invalid reference to another resource.'
        render turbo_stream: turbo_stream.replace('flash', partial: 'shared/flash')
      end
      format.json do
        render json: { error: 'Invalid reference to another resource.' }, status: :unprocessable_entity
      end
    end
  end

  def handle_routing_error(exception)
    Rails.logger.warn "Routing error: #{exception.message}"

    respond_to do |format|
      format.html do
        redirect_to root_path, alert: 'Page not found.'
      end
      format.turbo_stream do
        flash.now[:alert] = 'Page not found.'
        render turbo_stream: turbo_stream.replace('flash', partial: 'shared/flash'), status: :not_found
      end
      format.json do
        render json: { error: 'Page not found' }, status: :not_found
      end
    end
  end

  def handle_payment_error(error)
    redirect_to account_path, alert: error.message
  end
end
