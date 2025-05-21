class CartsController < ApplicationController
  before_action :set_cart, only: [:show]

  private

  def set_cart
    @cart = Cart.includes(cart_items: :product).find_by(user_id: current_user.id)
  end
end
