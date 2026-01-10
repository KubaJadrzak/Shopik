# frozen_string_literal: true

class RemoveAutoRenewFromSubscriptions < ActiveRecord::Migration[8.0]
  def change
    remove_column :subscriptions, :auto_renew
  end
end
