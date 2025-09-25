# frozen_string_literal: true
# typed: true

class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart, only: [:show]

  private

  def set_cart
    @cart = Cart.includes(cart_items: :product).find_by(user_id: current_user.id)
  end
end
