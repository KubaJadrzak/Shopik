class AddEspagoClientIdToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :espago_client_id, :string, null: false
  end
end
