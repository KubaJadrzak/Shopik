class AddCardIdentifierToClient < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :card_identifier, :string

    add_index :clients, :card_identifier
  end
end
