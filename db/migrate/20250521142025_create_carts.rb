# frozen_string_literal: true

class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.references :user, foreign_key: true, null: true
      t.timestamps
    end
  end
end
