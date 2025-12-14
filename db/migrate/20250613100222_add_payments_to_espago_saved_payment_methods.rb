# frozen_string_literal: true

class AddPaymentsToEspagoSavedPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    add_reference :payments, :espago_saved_payment_method, foreign_key: true
  end
end
