class RenameReferenceToEspagoClientsOnPayments < ActiveRecord::Migration[8.0]
  def change
    rename_column :payments, :espago_client_id, :client_id
    rename_index :payments, 'index_payments_on_espago_client_id', 'index_payments_on_client_id'
  end
end
