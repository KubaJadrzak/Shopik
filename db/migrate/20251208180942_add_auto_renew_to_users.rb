# frozen_string_literal: true

class AddAutoRenewToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :auto_renew, :boolean, null: false, default: false
  end
end
