class RemoveUnnecessaryIds < ActiveRecord::Migration[8.0]
  def change
    remove_column :saved_payment_methods, :client_id
    remove_column :payments, :payment_id
  end
end
