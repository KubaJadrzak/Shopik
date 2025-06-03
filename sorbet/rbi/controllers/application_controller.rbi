# typed: strict
class ApplicationController < ActionController::Base
  def current_user; end

  sig { returns(String) }
  def root_path; end

  sig { returns(String) }
  def products_path; end

  sig { returns(String) }
  def cart_path; end

  sig { params(order: Order).returns(String) }
  def order_path(order); end

  sig { params(order: Order).returns(String) }
  def espago_start_payment_path(order); end

  sig { params(order: Order).void}
  def espago_payments_success_path(order); end

  sig { params(order: Order).void}
  def espago_payments_failure_path(order); end

  sig { params(order: Order).void}
  def espago_payments_awaiting_path(order); end

  sig { returns(String) }
  def account_path; end
end