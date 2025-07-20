class AddPaymentsToEspagoClients < ActiveRecord::Migration[8.0]
  def change
    add_reference :payments, :espago_client, foreign_key: true
  end
end
