class AddPaymentIdToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :payment_id, :string
  end
end
