class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_item, only: [:destroy]
  before_action :set_cart, only: [:destroy]

  def create
    @product = Product.find(params[:product_id])
    @cart_item = current_user.cart.cart_items.find_by(product_id: @product.id)

    success = if @cart_item
                @cart_item.increment(:quantity)
                @cart_item.save
              else
                current_user.cart.cart_items.create(product: @product, quantity: 1).persisted?
              end

    respond_to do |format|
      if success
        flash.now[:notice] = "#{@product.title} added to cart!"
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('flash', partial: 'shared/flash')
        end
        format.html { redirect_to products_path, notice: "#{@product.title} added to cart!" }
      else
        flash.now[:alert] = "Failed to add #{@product.title} to cart."
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('flash', partial: 'shared/flash')
        end
        format.html { redirect_to products_path, alert: "Failed to add #{@product.title} to cart." }
      end
    end
  end

  def destroy
    if @cart_item.destroy
      flash.now[:notice] = 'Cart Item deleted'

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('flash', partial: 'shared/flash'),
            turbo_stream.remove("cart_item_#{@cart_item.id}"),
            turbo_stream.replace('cart_total_price', partial: 'carts/total_price',
                                                     locals:  { price: @cart.total_price },),
          ]
        end
        format.html { redirect_to cart_path, notice: 'Cart Item deleted' }
      end
    else
      flash.now[:alert] = 'Failed to delete Cart Item'

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'flash',
            partial: 'shared/flash',
          )
        end
        format.html { redirect_to cart_path, alert: 'Failed to delete Cart Item' }
      end
    end
  end

  private

  def set_cart_item
    @cart_item = current_user.cart.cart_items.find(params[:id])
  end

  def set_cart
    @cart = current_user.cart
  end
end
