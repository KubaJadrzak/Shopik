class AddSubscriptionNumberToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :subscription_number, :string
    add_index  :subscriptions, :subscription_number, unique: true
  end
end
