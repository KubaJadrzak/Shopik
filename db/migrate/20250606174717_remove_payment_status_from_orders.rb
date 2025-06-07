class RemovePaymentStatusFromOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :payment_status, :string
  end
end
