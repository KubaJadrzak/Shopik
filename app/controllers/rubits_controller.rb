# typed: strict

class RubitsController < ApplicationController
  extend T::Sig

  sig { returns(T.nilable(Pagy)) }
  attr_accessor :pagy

  sig { returns(T.nilable(T::Array[Rubit])) }
  attr_accessor :rubits

  sig { returns(T.nilable(Rubit)) }
  attr_accessor :rubit

  before_action :authenticate_user!, only: %i[create destroy]
  before_action :set_rubit, only: %i[show destroy]

  sig { void }
  def index
    pagy_result = T.let(
      pagy_countless(
        Rubit
          .root_rubits
          .left_joins(:likes)
          .group('rubits.id')
          .order('likes_count DESC')
          .includes(:user, :likes_by_users),
        items: 20,
      ),
      [Pagy, T::Array[Rubit]],
    )

    @pagy = pagy_result[0]
    @rubits = pagy_result[1]

    render 'scrollable_list' if params[:page]
  end

  sig { void }
  def show
    @rubit = Rubit.includes(child_rubits: %i[user likes likes_by_users]).find(params[:id])
  end

  sig { void }
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
      parent_rubit = params[:parent_rubit_id].present? ? Rubit.find_by(id: params[:parent_rubit_id]) : nil
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

  sig { void }
  def destroy
    if @rubit&.destroy
      flash.now[:notice] = 'Rubit deleted'
    else
      flash.now[:alert] = 'Failed to delete Rubit'
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("rubit_#{@rubit&.id}"),
          turbo_stream.replace('flash', partial: 'shared/flash'),
        ]
      end
      format.html { redirect_to root_path }
    end
  end

  private

  sig { returns(ActionController::Parameters) }
  def rubit_params
    params.require(:rubit).permit(:content, :parent_rubit_id)
  end

  sig { void }
  def set_rubit
    @rubit = Rubit.find(params[:id])
  end
end
