# frozen_string_literal: true

class AddNotNullToSubscriptionUuid < ActiveRecord::Migration[8.0]
  def change
    change_column_null :subscriptions, :uuid, false
  end
end
