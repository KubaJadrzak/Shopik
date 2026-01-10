# frozen_string_literal: true

class AddResponseToPayment < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :response, :string, null: true
  end
end
