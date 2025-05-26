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
  def espago_secure_web_page_start_payment_path(order); end

    sig { returns(String) }
  def account_path; end
end