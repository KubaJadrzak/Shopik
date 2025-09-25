# frozen_string_literal: true

class AddPriceToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :price, :decimal
  end
end
