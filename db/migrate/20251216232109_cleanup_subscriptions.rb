class CleanupSubscriptions < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :subscriptions, :saved_payment_methods
    remove_column :subscriptions, :espago_saved_payment_method_id
    change_column_default :subscriptions, :state, 'New'
  end
end
