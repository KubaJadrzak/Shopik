# typed: true
# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_has_items, only: %i[new create]
  before_action :set_order, only: %i[show retry_payment cancel return]

  #: -> void
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
      current_user.cart_items.destroy_all
      redirect_to new_payments_path(payable_number: @order.uuid)
    else
      flash[:alert] = 'There was a problem with your order.'
      redirect_to cart_path
    end
  end

  def retry_payment
    unless @order.can_retry_payment?
      redirect_to order_path(@order), alert: 'Cannot retry payment: payment already in progress or successful.'
      return
    end

    redirect_to new_payments_path(order_id: @order.id)
  end

  #: -> void
  def cancel
    unless @order.can_reverse_payment? # rubocop:disable Style/GuardClause
      redirect_to account_url, alert: 'We cannot process your order cancellation due to a technical issue'
    end
  end

  #: -> void
  def return
    unless @order.can_refund_payment? # rubocop:disable Style/GuardClause
      redirect_to account_url, alert: 'We cannot process your order return due to a technical issue'
    end
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
