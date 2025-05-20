# typed: strict
class ApplicationController < ActionController::Base
  def current_user; end

  sig { returns(String) }
  def root_path; end
end