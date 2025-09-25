# frozen_string_literal: true

class SetAutoRenewDefaultToFalseOnSubscriptions < ActiveRecord::Migration[8.0]
  def change
    change_column :subscriptions, :auto_renew, :boolean, default: false
  end
end
