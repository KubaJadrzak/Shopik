# typed: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_has_items, only: %i[new create]
  before_action :set_order, only: %i[show retry_payment]

  def new
    @order = Order.new
  end

  def show
    @payments = @order.payments
  end

  def create
    @order = current_user.orders.new(
      email:            order_params[:email],
      shipping_address: order_params[:shipping_address],
      total_price:      current_user.cart.total_price,
      status:           'New',
      ordered_at:       Time.current,
    )

    @order.build_order_items_from_cart(current_user.cart)
    if @order.save
      current_user.cart.cart_items.destroy_all
      redirect_to espago_new_payment_path(order_id: @order.id)
    else
      flash.now[:alert] = 'There was a problem placing your order.'
      render :new, status: :unprocessable_entity
    end
  end

  def retry_payment
    unless @order.can_retry_payment?
      redirect_to order_path(@order), alert: 'Cannot retry payment: payment already in progress or successful.'
      return
    end

    payment = @order.payments.create!(amount: @order.total_price)
    redirect_to espago_start_payment_path(payment.payment_number)
  end


  private

  def set_order
    @order = Order.includes(order_items: :product).find_by!(id: params[:id])
  end

  def order_params
    params.require(:order).permit(:email, :shipping_address)
  end

  def ensure_cart_has_items
    redirect_to cart_path if current_user.cart.cart_items.empty?
  end
end
