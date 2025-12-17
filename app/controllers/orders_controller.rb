# typed: strict
# frozen_string_literal: true

class OrdersController < ApplicationController
  include OrderErrors

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

    raise order_error! unless @order.save

    current_user.cart_items.destroy_all
    redirect_to new_payment_path(payable_number: @order.uuid)
  end

  #: -> void
  def retry_payment
    raise order_error! unless @order&.can_retry_payment?

    redirect_to new_payment_path(payable_number: @order.uuid)
  end

  #: -> void
  def cancel
    raise order_error! unless @order&.can_reverse_payment?
  end

  #: -> void
  def return
    raise order_error! unless @order&.can_refund_payment?
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
    raise order_error! if current_user.cart.empty?
  end
end
