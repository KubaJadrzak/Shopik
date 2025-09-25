# frozen_string_literal: true

class AddMembershipPriceToProducs < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :membership_price, :decimal, null: true
  end
end
