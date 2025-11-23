# frozen_string_literal: true

class AddSubscriptionNumberToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :uuid, :string
    add_index  :subscriptions, :uuid, unique: true
  end
end
