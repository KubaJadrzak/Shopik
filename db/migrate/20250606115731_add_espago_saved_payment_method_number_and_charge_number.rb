# frozen_string_literal: true

class AddEspagoSavedPaymentMethodNumberAndChargeNumber < ActiveRecord::Migration[8.0]
  def change
    add_column :espago_saved_payment_methods, :uuid, :string, null: false
    add_index :espago_saved_payment_methods, :uuid, unique: true

    add_column :charges, :charge_number, :string, null: false
    add_index :charges, :charge_number, unique: true
  end
end
