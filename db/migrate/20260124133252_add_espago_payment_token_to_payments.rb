# frozen_string_literal: true

class AddEspagoPaymentTokenToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :espago_payment_token, :string, null: true
  end
end
