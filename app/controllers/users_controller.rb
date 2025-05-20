# typed: strict

class UsersController < ApplicationController
  extend T::Sig

  sig { returns(T.nilable(User)) }
  attr_accessor :user

  sig { returns(T.nilable(ActiveRecord::Relation)) }
  attr_accessor :rubits

  sig { returns(T.nilable(ActiveRecord::Relation)) }
  attr_accessor :liked_rubits

  sig { returns(T.nilable(ActiveRecord::Relation)) }
  attr_accessor :comments

  before_action :authenticate_user!, only: [:account]

  sig { void }
  def account
    @user = current_user

    @rubits = current_user
              .rubits
              .root_rubits
              .includes(:user, :likes, :likes_by_users, :parent_rubit)
              .order(created_at: :desc)

    @liked_rubits = current_user
                    .liked_rubits.includes(:user, :likes, :likes_by_users,
                                           :parent_rubit,).order(created_at: :desc)


    @comments = current_user
                .rubits
                .child_rubits
                .includes(:user, :likes, :likes_by_users, :parent_rubit)
                .order(created_at: :desc)
  end
end
