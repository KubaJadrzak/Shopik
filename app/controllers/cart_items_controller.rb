# frozen_string_literal: true
# typed: true

class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_item, only: [:destroy]
  before_action :set_cart, only: [:destroy]

  def create
    @product = Product.find(params[:product_id])
    @cart_item = current_user.cart_items.find_by(product_id: @product.id)

    success = if @cart_item
                @cart_item.increment(:quantity)
                @cart_item.save
              else
                current_user.cart_items.create(product: @product).persisted?
              end

    if success
      flash[:notice] = 'Product added to cart!'
    else
      flash[:alert] = 'Failed to add product to cart.'
    end

    respond_to do |format|
      format.turbo_stream do
        redirect_to root_path
      end
    end
  end

  def destroy
    if @cart_item.destroy
      flash[:notice] = 'Product removed from cart!'
    else
      flash[:alert] = 'Failed to remove product from cart.'
    end

    respond_to do |format|
      format.turbo_stream do
        redirect_to cart_path
      end
    end
  end

  private

  def set_cart_item
    @cart_item = current_user.cart_items.find(params[:id])
  end

  def set_cart
    @cart = current_user.cart
  end
end
