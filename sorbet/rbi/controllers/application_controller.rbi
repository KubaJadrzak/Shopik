# typed: strict
class ApplicationController < ActionController::Base
  def current_user; end

  sig { returns(String) }
  def root_path; end

  sig { returns(String) }
  def products_path; end

  sig { returns(String) }
  def cart_path; end
end