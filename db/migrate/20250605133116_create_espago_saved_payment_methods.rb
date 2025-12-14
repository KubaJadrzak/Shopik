# frozen_string_literal: true

class CreateEspagoSavedPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :espago_saved_payment_methods do |t|
      t.references :user, null: false, foreign_key: true

      t.string :client_id, null: false

      t.string :company
      t.string :last4

      t.timestamps
    end

    add_index :espago_saved_payment_methods, :client_id, unique: true
  end
end
