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

  sig { params(charge_number: String).returns(String) }
  def espago_start_charge_path(charge_number); end

  sig { returns(String) }
  def account_path; end

  sig { params(charge: Charge).returns(Charge) }
  def espago_charges_success_path(charge); end

  sig { params(charge: Charge).returns(Charge) }
  def espago_charges_awaiting_path(charge); end

  sig { params(charge: Charge).returns(Charge) }
  def espago_charges_failure_path(charge); end


end