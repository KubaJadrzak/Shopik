# frozen_string_literal: true

class AddEspagoClientIdToPayment < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :espago_client_id, :string, null: true
  end
end
