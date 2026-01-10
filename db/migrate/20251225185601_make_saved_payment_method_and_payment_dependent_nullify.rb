# frozen_string_literal: true

class MakeSavedPaymentMethodAndPaymentDependentNullify < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :payments, :saved_payment_methods

    add_foreign_key :payments, :saved_payment_methods,
                    on_delete: :nullify
  end
end
