class CreateEspagoClients < ActiveRecord::Migration[8.0]
  def change
    create_table :espago_clients do |t|
      t.references :user, null: false, foreign_key: true

      t.string :client_id, null: false

      t.string :company
      t.string :last4

      t.timestamps
    end

    add_index :espago_clients, :client_id, unique: true
  end
end
