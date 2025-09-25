# frozen_string_literal: true
# typed: true

class ProductsController < ApplicationController

  def index
    @products = Product.all
  end
end
