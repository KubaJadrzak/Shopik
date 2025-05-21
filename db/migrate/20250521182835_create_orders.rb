class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true, null: true
      t.string :order_number, null: false
      t.string :email, null: false
      t.string :status, null: false
      t.string :payment_status, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.text :shipping_address, null: false
      t.timestamps
    end

    add_index :orders, :order_number, unique: true
  end
end
