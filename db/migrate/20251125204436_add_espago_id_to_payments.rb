# frozen_string_literal: true

class AddEspagoIdToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :espago_payment_id, :string, null: true
  end
end
