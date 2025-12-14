# frozen_string_literal: true

class AddStatusToEspagoSavedPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    add_column :espago_saved_payment_methods, :status, :string, default: 'unverified', null: false
  end
end
