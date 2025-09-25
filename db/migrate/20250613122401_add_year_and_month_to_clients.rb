# frozen_string_literal: true

class AddYearAndMonthToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :month, :integer, null: false
    add_column :clients, :year, :integer, null: false
  end
end
