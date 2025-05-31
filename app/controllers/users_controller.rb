# typed: true

class UsersController < ApplicationController

  before_action :authenticate_user!, only: [:account]

  def account
    @user = current_user

    @rubits = current_user
              .rubits
              .root_rubits
              .includes(:user, :likes, :likes_by_users, :parent_rubit)
              .order(created_at: :desc)

    @liked_rubits = current_user
                    .liked_rubits.includes(:user, :likes, :likes_by_users, :parent_rubit)
                    .order(created_at: :desc)

    @comments = current_user
                .rubits
                .child_rubits
                .includes(:user, :likes, :likes_by_users, :parent_rubit)
                .order(created_at: :desc)

    @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)

    Espago::UpdatePaymentStatusJob.perform_later(current_user.id)
  end
end
