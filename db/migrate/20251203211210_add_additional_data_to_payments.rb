class AddAdditionalDataToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :card_identifier, :string
    add_column :payments, :transaction_id, :string

    add_index :payments, :card_identifier
  end
end
