# typed: strict
# frozen_string_literal: true

class ResignOrderJob < ApplicationJob
  queue_as :default

  #:  -> void
  def perform
    handle_resigned_orders
  end

  private

  #: -> void
  def handle_resigned_orders
    ::Order.should_be_resigned.find_each do |order|
      order.state = 'Payment Resigned'

      order.save(validate: false)
    end
  end
end
