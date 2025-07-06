class AddPrimaryFieldToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :primary, :boolean, default: false, null: false

    Client.update_all(primary: false)
  end
end
