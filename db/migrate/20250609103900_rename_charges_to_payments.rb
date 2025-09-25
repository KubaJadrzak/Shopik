# frozen_string_literal: true

class RenameChargesToPayments < ActiveRecord::Migration[8.0]
  def change
    rename_table :charges, :payments
    rename_column :payments, :charge_number, :payment_number
    rename_index :payments, 'index_charges_on_charge_number', 'index_payments_on_payment_number'
  end
end
