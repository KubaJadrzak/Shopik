class AddStatusToEspagoClients < ActiveRecord::Migration[8.0]
  def change
    add_column :espago_clients, :status, :string, default: 'unverified', null: false
  end
end
