# typed: false

class RubitsController < ApplicationController
  extend T::Sig
  before_action :authenticate_user!, only: %i[create destroy]
  before_action :set_rubit, only: %i[show destroy]

  def index
    @pagy, @rubits = pagy_countless(Rubit
                    .root_rubits
                    .left_joins(:likes)
                    .group('rubits.id')
                    .order('likes_count DESC')
                    .includes(:user, :likes_by_users), items: 20,)


    render 'scrollable_list' if params[:page]
  end

  def show
    @rubit = Rubit.includes(child_rubits: %i[user likes likes_by_users]).find(params[:id])
  end

  def create
    @rubit = current_user.rubits.new(rubit_params)


    if @rubit.save
      flash.now[:notice] = 'Rubit created'

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend('rubits', partial: 'rubits/rubit', locals: { rubit: @rubit }),
            turbo_stream.replace('new_rubit_form', partial: 'rubits/form',
                                                   locals:  { parent_rubit: @rubit.parent_rubit },),
            turbo_stream.replace('flash', partial: 'shared/flash'),
          ]
        end
        format.html { redirect_to root_path, notice: 'Rubit created' }
      end
    else
      parent_rubit = Rubit.find_by(id: params[:parent_rubit_id]) if params[:parent_rubit_id].present?
      flash.now[:alert] = 'Failed to create Rubit'

      respond_to do |format|
        format.html { render :new }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('new_rubit_form', partial: 'rubits/form', locals: { parent_rubit: parent_rubit }),
            turbo_stream.replace('flash', partial: 'shared/flash'),
          ]
        end
      end
    end
  end

  def destroy
    if @rubit.destroy
      flash.now[:notice] = 'Rubit deleted'
    else
      flash.now[:alert] = 'Failed to delete Rubit'
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("rubit_#{@rubit.id}"),
          turbo_stream.replace('flash', partial: 'shared/flash'),
        ]
      end
      format.html { redirect_to root_path }
    end
  end

  private

  def set_rubit
    @rubit = Rubit.find(params[:id])
  end

  def rubit_params
    params.require(:rubit).permit(:content, :parent_rubit_id)
  end
end
