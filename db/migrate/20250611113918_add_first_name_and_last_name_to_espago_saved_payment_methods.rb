# frozen_string_literal: true

class AddFirstNameAndLastNameToEspagoSavedPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    add_column :espago_saved_payment_methods, :first_name, :string, null: false
    add_column :espago_saved_payment_methods, :last_name, :string, null: false
  end
end
