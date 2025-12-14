# frozen_string_literal: true

class RenameEspagoSavedPaymentMethodsToSavedPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    rename_table :espago_saved_payment_methods, :saved_payment_methods
  end
end
