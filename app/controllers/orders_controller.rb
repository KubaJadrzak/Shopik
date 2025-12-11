# typed: strict
# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_has_items, only: %i[new create]
  before_action :set_order, only: %i[show retry_payment cancel return]

  #: -> void
  def new
    @order = Order.new #: ::Order?
  end

  #: -> void
  def show
    @payments = @order&.payments #: ActiveRecord::Relation?
  end

  #: -> void
  def create
    @order = current_user.orders.new(
      email:            order_params[:email],
      shipping_address: order_params[:shipping_address],
      total_price:      current_user.cart.total_price,
      state:            'New',
      ordered_at:       Time.current,
    )

    @order.build_order_items_from_cart(current_user.cart)
    if @order.save
      current_user.cart_items.destroy_all
      redirect_to new_payment_path(payable_number: @order.uuid)
    else
      redirect_to cart_path, alert: 'There was a problem with your order.'
    end
  end

  #: -> void
  def retry_payment
    unless @order&.can_retry_payment?
      redirect_to order_path(@order), alert: 'Cannot retry payment'
      return
    end

    redirect_to new_payment_path(payable_number: @order.uuid)
  end

  #: -> void
  def cancel
    return if @order&.can_reverse_payment?

    redirect_to account_url, alert: 'We cannot process your order cancellation due to a technical issue'
  end

  #: -> void
  def return
    return if @order&.can_refund_payment?

    redirect_to account_url, alert: 'We cannot process your order return due to a technical issue'
  end

  private

  #: -> void
  def set_order
    @order = Order.includes(order_items: :product).find_by(uuid: params[:uuid])
  end

  #: -> Hash[Symbol, untyped]
  def order_params
    params.require(:order).permit(:email, :shipping_address)
  end

  #: -> void
  def ensure_cart_has_items
    redirect_to cart_path if current_user.cart.empty?
  end
end
