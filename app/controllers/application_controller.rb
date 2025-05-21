# typed: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::InvalidForeignKey, with: :handle_invalid_foreign_key
  rescue_from ActionController::RoutingError, with: :handle_routing_error

  def raise_not_found
    raise ActionController::RoutingError.new("No route matches #{request.path.inspect}")
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
end
