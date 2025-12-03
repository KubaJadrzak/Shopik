class RemoveUnnecessaryIds < ActiveRecord::Migration[8.0]
  def change
    remove_column :clients, :client_id
    remove_column :payments, :payment_id
  end
end
