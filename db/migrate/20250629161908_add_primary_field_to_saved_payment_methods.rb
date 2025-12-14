# frozen_string_literal: true

class AddPrimaryFieldToSavedPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    add_column :saved_payment_methods, :primary, :boolean, default: false, null: false

    SavedPaymentMethod.update_all(primary: false)
  end
end
