# frozen_string_literal: true
# typed: true

class LikesController < ApplicationController

  before_action :authenticate_user!, only: %i[create destroy]
  before_action :set_rubit, only: %i[create destroy]
  before_action :set_like, only: [:destroy]

  def create
    like = @rubit.likes.create(user: current_user)

    if like.persisted?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "rubit_#{@rubit.id}_like_section",
            partial: 'likes/like_section',
            locals:  { rubit: @rubit },
          )
        end
        format.html do
          redirect_to request.referer || root_path
        end
      end
    else
      flash.now[:alert] = 'Failed to add like'
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'flash',
            partial: 'shared/flash',
          )
        end
        format.html do
          redirect_to request.referer || root_path, alert: 'Failed to add like'
        end
      end
    end
  end

  def destroy
    if @like.destroy
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "rubit_#{@rubit.id}_like_section",
            partial: 'likes/like_section',
            locals:  { rubit: @rubit },
          )
        end
        format.html do
          redirect_to request.referer || root_path, notice: 'Like removed'
        end
      end
    else
      flash.now[:alert] = 'Failed to remove like'

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'flash',
            partial: 'shared/flash',
          )
        end
        format.html do
          redirect_to request.referer || root_path, alert: 'Failed to remove like'
        end
      end
    end
  end

  private

  def set_rubit
    @rubit = Rubit.find(params[:rubit_id])
  end

  def set_like
    @like = @rubit.likes.find_by!(user: current_user)
  end
end
