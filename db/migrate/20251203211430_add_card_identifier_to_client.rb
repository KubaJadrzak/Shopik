class AddCardIdentifierToClient < ActiveRecord::Migration[8.0]
  def change
    add_column :saved_payment_methods, :card_identifier, :string

    add_index :saved_payment_methods, :card_identifier
  end
end
