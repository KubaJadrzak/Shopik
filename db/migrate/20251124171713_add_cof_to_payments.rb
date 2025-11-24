class AddCofToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :cof, :integer, null: true
  end
end
