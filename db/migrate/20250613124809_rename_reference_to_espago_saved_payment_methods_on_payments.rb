# frozen_string_literal: true

class RenameReferenceToEspagoSavedPaymentMethodsOnPayments < ActiveRecord::Migration[8.0]
  def change
    rename_column :payments, :espago_saved_payment_method_id, :saved_payment_method_id
    rename_index :payments, 'index_payments_on_espago_saved_payment_method_id', 'index_payments_on_saved_payment_method_id'
  end
end
