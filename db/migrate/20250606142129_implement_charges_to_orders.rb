# frozen_string_literal: true

class ImplementChargesToOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_null :charges, :subscription_id, true

    add_reference :charges, :order, foreign_key: true, index: true, null: true

    remove_column :orders, :payment_id, :string
  end
end
