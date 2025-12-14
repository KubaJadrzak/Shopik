# frozen_string_literal: true

class AddYearAndMonthToSavedPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    add_column :saved_payment_methods, :month, :integer, null: false
    add_column :saved_payment_methods, :year, :integer, null: false
  end
end
