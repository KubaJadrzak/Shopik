# typed: strict

class ProductsController < ApplicationController
  extend T::Sig

  sig { returns(T.nilable(Product::PrivateRelation)) }
  attr_accessor :products

  sig { void }
  def index
    @products = Product.all
  end
end
