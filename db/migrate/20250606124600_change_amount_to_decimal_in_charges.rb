# frozen_string_literal: true

class ChangeAmountToDecimalInCharges < ActiveRecord::Migration[8.0]
  def change
    change_column :charges, :amount, :decimal, precision: 10, scale: 2, null: false
  end
end
