# frozen_string_literal: true

class MakePaymentsPolymorphic < ActiveRecord::Migration[8.0]
  def change
    add_reference :payments, :payable, polymorphic: true, index: true

    remove_column :payments, :order_id
    remove_column :payments, :subscription_id
  end
end
