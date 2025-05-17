class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:account]

  def account
    @user = current_user
    @rubits = current_user.rubits.order(created_at: :desc)
    @liked_rubits = current_user.liked_rubits.order(created_at: :desc)
  end
end
