class LikesController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]

  def create
    rubit = Rubit.find(params[:rubit_id])
    rubit.likes.create!(user: current_user)

    respond_to do |format|
      format.html do
        render partial: 'likes/like_section', locals: { rubit: rubit }
      end
    end
  end

  def destroy
    rubit = Rubit.find(params[:rubit_id])
    like = rubit.likes.find_by!(user: current_user)
    like.destroy

    respond_to do |format|
      format.html do
        render partial: 'likes/like_section', locals: { rubit: rubit }
      end
    end
  end

end
