# typed: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_has_items, only: %i[new create]
  before_action :set_order, only: [:show]

  def new
    @order = Order.new
  end

  def show; end

  def create
    @order = current_user.orders.new(
      email:            order_params[:email],
      shipping_address: order_params[:shipping_address],
      total_price:      current_user.cart.total_price,
      status:           'New',
      payment_status:   'New',
      ordered_at:       Time.current,
    )
    @order.build_order_items_from_cart(current_user.cart)

    if @order.save
      current_user.cart.cart_items.destroy_all
      redirect_to espago_secure_web_page_start_payment_path(@order)
    else
      flash.now[:alert] = 'There was a problem placing your order.'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find_by!(id: params[:id])
  end

  def order_params
    params.require(:order).permit(:email, :shipping_address)
  end

  def ensure_cart_has_items
    redirect_to cart_path if current_user.cart.cart_items.empty?
  end
end
