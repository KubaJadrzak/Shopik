# typed: strict

class LikesController < ApplicationController
  extend T::Sig

  sig { returns(T.nilable(Rubit)) }
  attr_accessor :rubit

  before_action :authenticate_user!, only: %i[create destroy]
  before_action :set_rubit, only: %i[create destroy]

  sig { void }
  def create
    T.must(@rubit).likes.create!(user: current_user)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "rubit_#{T.must(@rubit).id}_like_section",
          partial: 'likes/like_section',
          locals:  { rubit: @rubit },
        )
      end
      format.html do
        redirect_to request.referer || root_path
      end
    end
  end

  sig { void }
  def destroy
    like = T.must(@rubit).likes.find_by!(user: current_user)
    like.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "rubit_#{T.must(@rubit).id}_like_section",
          partial: 'likes/like_section',
          locals:  { rubit: @rubit },
        )
      end
      format.html do
        redirect_to request.referer || root_path
      end
    end
  end

  private

  sig { returns(Rubit) }
  def set_rubit
    @rubit = Rubit.find(params[:rubit_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Rubit not found.'
  end

end
