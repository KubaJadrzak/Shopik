# typed: strict
# frozen_string_literal: true

class ResignOrderJob < ApplicationJob
  queue_as :default

  #: (Integer) -> void
  def perform(user_id)
    @user = User.find(user_id) #: ::User?
    return unless @user

    handle_resigned_orders
  end

  private

  #: -> void
  def handle_resigned_orders
    return unless @user

    # Fix for weird sorbet behaviour,
    # missing method awaiting on ActiveRecord::Relation
    orders = @user.orders #: as untyped


    orders.should_be_resigned.find_each do |order|
      order.state = 'Payment Resigned'

      order.save(validate: false)
    end
  end
end
