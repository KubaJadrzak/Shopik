# frozen_string_literal: true

class AddKindToPayment < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :kind, :integer, null: false
  end
end
