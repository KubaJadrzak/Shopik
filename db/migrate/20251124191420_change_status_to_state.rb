# frozen_string_literal: true

class ChangeStatusToState < ActiveRecord::Migration[8.0]
  def change
    rename_column :orders, :status, :state
    rename_column :subscriptions, :status, :state
    rename_column :saved_payment_methods, :status, :state
  end
end
