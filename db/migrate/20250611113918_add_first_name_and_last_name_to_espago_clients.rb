class AddFirstNameAndLastNameToEspagoClients < ActiveRecord::Migration[8.0]
  def change
    add_column :espago_clients, :first_name, :string, null: false
    add_column :espago_clients, :last_name, :string, null: false
  end
end
