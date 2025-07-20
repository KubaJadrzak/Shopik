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

  sig { params(subscription: Subscription).returns(String) }
  def subscription_path(subscription); end

  sig { params(subscription_id: T.nilable(Integer), order_id: T.nilable(Integer), client_id: T.nilable((Integer))).returns(String) }
  def espago_new_payment_path(subscription_id: nil, order_id: nil, client_id: nil); end
  
  sig { params(payment_number: String).returns(String) }
  def espago_start_payment_path(payment_number); end

  sig { returns(String) }
  def account_path; end

  sig { params(payment_number: String).returns(String) }
  def espago_payments_success_path(payment_number); end

  sig { params(payment_number: String).returns(String) }
  def espago_payments_awaiting_path(payment_number); end

  sig { params(payment_number: String).returns(String) }
  def espago_payments_failure_path(payment_number); end


end