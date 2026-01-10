# frozen_string_literal: true

class AddCurrencyAndDescriptionToPayment < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :currency, :string, null: false, default: 'USD'
  end
end
