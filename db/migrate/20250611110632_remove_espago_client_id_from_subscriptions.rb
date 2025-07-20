class RemoveEspagoClientIdFromSubscriptions < ActiveRecord::Migration[8.0]
  def change
    remove_column :subscriptions, :espago_client_id, :integer
  end
end
