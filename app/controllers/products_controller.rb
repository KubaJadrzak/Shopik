# typed: strict

class ProductsController < ApplicationController
  extend T::Sig

  sig { returns(T.nilable(T::Array[Product])) }
  attr_accessor :products

  sig { void }
  def index
    @products = Product.all
  end
end
